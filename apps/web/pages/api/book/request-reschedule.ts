import {
  Attendee,
  Booking,
  BookingReference,
  BookingStatus,
  EventType,
  User
} from "@prisma/client";
import { WebhookTriggerEvents } from "@calcom/lib/utils/types/WebhookTriggerEvents";
import type { NextApiRequest, NextApiResponse } from "next";
import { getSession } from "next-auth/react";
import type { TFunction } from "next-i18next";
import { z, ZodError } from "zod";

import { getCalendar } from "@calcom/app-store/_utils/getCalendar";
import { CalendarEventBuilder } from "@calcom/core/builders/CalendarEvent/builder";
import { CalendarEventDirector } from "@calcom/core/builders/CalendarEvent/director";
import { deleteMeeting } from "@calcom/core/videoClient";
import dayjs from "@calcom/dayjs";
import { sendRequestRescheduleEmail } from "@calcom/emails";
import { isPrismaObjOrUndefined } from "@calcom/lib";
import { getTranslation } from "@calcom/lib/server/i18n";
import prisma from "@calcom/prisma";
import type { CalendarEvent, Person } from "@calcom/types/Calendar";

import sendPayload from "@lib/webhooks/sendPayload";
import getWebhooks from "@lib/webhooks/subscriptions";

export type RescheduleResponse = Booking & {
  attendees: Attendee[];
};
export type PersonAttendeeCommonFields = Pick<
  User,
  "id" | "email" | "name" | "locale" | "timeZone" | "username"
>;

const rescheduleSchema = z.object({
  bookingId: z.string(),
  rescheduleReason: z.string().optional(),
});

const findUserDataByUserId = async (userId: number) => {
  return await prisma.user.findUniqueOrThrow({
    where: {
      id: userId,
    },
    select: {
      id: true,
      name: true,
      username: true,
      email: true,
      timeZone: true,
      locale: true,
      credentials: true,
      destinationCalendar: true,
      teams: true,
    },
  });
};

const handler = async (
  req: NextApiRequest,
  res: NextApiResponse
): Promise<RescheduleResponse | NextApiResponse | void> => {
  const session = await getSession({ req });
  const {
    bookingId,
    rescheduleReason: cancellationReason,
  }: { bookingId: string; rescheduleReason: string; cancellationReason: string } = req.body;
  let user: Awaited<ReturnType<typeof findUserDataByUserId>>;
  try {
    if (session?.user?.id) {
      user = await findUserDataByUserId(session?.user.id);
    } else {
      return res.status(501).end();
    }

    const bookingToReschedule = await prisma.booking.findFirstOrThrow({
      select: {
        id: true,
        uid: true,
        userId: true,
        title: true,
        description: true,
        startTime: true,
        endTime: true,
        eventTypeId: true,
        eventType: true,
        location: true,
        attendees: true,
        references: true,
        customInputs: true,
        dynamicEventSlugRef: true,
        dynamicGroupSlugRef: true,
        destinationCalendar: true,
      },
      where: {
        uid: bookingId,
        NOT: {
          status: {
            in: [BookingStatus.CANCELLED, BookingStatus.REJECTED],
          },
        },
      },
    });

    if (!bookingToReschedule.userId) {
      throw new Error("Booking to reschedule doesn't have an owner.");
    }
    if (!bookingToReschedule.eventType) {
      throw new Error("EventType not found for current booking.");
    }

    const bookingBelongsToTeam = !!bookingToReschedule.eventType?.teamId;
    if (bookingBelongsToTeam && bookingToReschedule.eventType?.teamId) {
      const userTeamIds = user.teams.map((item) => item.teamId);
      if (userTeamIds.indexOf(bookingToReschedule?.eventType?.teamId) === -1) {
        throw new Error("User isn't a member on the team");
      }
    }
    if (!bookingBelongsToTeam && bookingToReschedule.userId !== user.id) {
      throw new Error("User isn't owner of the current booking");
    }

    if (bookingToReschedule && user) {
      let event: Partial<EventType> = {};
      if (bookingToReschedule.eventTypeId) {
        event = await prisma.eventType.findFirstOrThrow({
          select: {
            title: true,
            users: true,
            schedulingType: true,
            recurringEvent: true,
          },
          where: {
            id: bookingToReschedule.eventTypeId,
          },
        });
      }
      await prisma.booking.update({
        where: {
          id: bookingToReschedule.id,
        },
        data: {
          rescheduled: true,
          cancellationReason,
          status: BookingStatus.CANCELLED,
          updatedAt: dayjs().toISOString(),
        },
      });

      const [mainAttendee] = bookingToReschedule.attendees;
      // @NOTE: Should we assume attendees language?
      const tAttendees = await getTranslation(mainAttendee.locale ?? "en", "common");
      const usersToPeopleType = (
        users: PersonAttendeeCommonFields[],
        selectedLanguage: TFunction
      ): Person[] => {
        return users?.map((user) => {
          return {
            email: user.email || "",
            name: user.name || "",
            username: user?.username || "",
            language: { translate: selectedLanguage, locale: user.locale || "en" },
            timeZone: user?.timeZone,
          };
        });
      };

      const userTranslation = await getTranslation(user.locale ?? "en", "common");
      const [userAsPeopleType] = usersToPeopleType([user], userTranslation);

      const builder = new CalendarEventBuilder();
      builder.init({
        title: bookingToReschedule.title,
        type: event && event.title ? event.title : bookingToReschedule.title,
        startTime: bookingToReschedule.startTime.toISOString(),
        endTime: bookingToReschedule.endTime.toISOString(),
        attendees: usersToPeopleType(
          // username field doesn't exists on attendee but could be in the future
          bookingToReschedule.attendees as unknown as PersonAttendeeCommonFields[],
          tAttendees
        ),
        organizer: userAsPeopleType,
      });

      const director = new CalendarEventDirector();
      director.setBuilder(builder);
      director.setExistingBooking(bookingToReschedule);
      director.setCancellationReason(cancellationReason);
      if (event) {
        await director.buildForRescheduleEmail();
      } else {
        await director.buildWithoutEventTypeForRescheduleEmail();
      }

      // Handling calendar and videos cancellation
      // This can set previous time as available, until virtual calendar is done
      const credentialsMap = new Map();
      user.credentials.forEach((credential) => {
        credentialsMap.set(credential.type, credential);
      });
      const bookingRefsFiltered: BookingReference[] = bookingToReschedule.references.filter(
        (ref) => !!credentialsMap.get(ref.type)
      );
      bookingRefsFiltered.forEach((bookingRef) => {
        if (bookingRef.uid) {
          if (bookingRef.type.endsWith("_calendar")) {
            const calendar = getCalendar(credentialsMap.get(bookingRef.type));

            return calendar?.deleteEvent(
              bookingRef.uid,
              builder.calendarEvent,
              bookingRef.externalCalendarId
            );
          } else if (bookingRef.type.endsWith("_video")) {
            return deleteMeeting(credentialsMap.get(bookingRef.type), bookingRef.uid);
          }
        }
      });

      // Send emails
      await sendRequestRescheduleEmail(builder.calendarEvent, {
        rescheduleLink: builder.rescheduleLink,
      });

      const evt: CalendarEvent = {
        title: bookingToReschedule?.title,
        type: event && event.title ? event.title : bookingToReschedule.title,
        description: bookingToReschedule?.description || "",
        customInputs: isPrismaObjOrUndefined(bookingToReschedule.customInputs),
        startTime: bookingToReschedule?.startTime ? dayjs(bookingToReschedule.startTime).format() : "",
        endTime: bookingToReschedule?.endTime ? dayjs(bookingToReschedule.endTime).format() : "",
        organizer: userAsPeopleType,
        attendees: usersToPeopleType(
          // username field doesn't exists on attendee but could be in the future
          bookingToReschedule.attendees as unknown as PersonAttendeeCommonFields[],
          tAttendees
        ),
        uid: bookingToReschedule?.uid,
        location: bookingToReschedule?.location,
        destinationCalendar:
          bookingToReschedule?.destinationCalendar || bookingToReschedule?.destinationCalendar,
        cancellationReason: `Please reschedule. ${cancellationReason}`, // TODO::Add i18-next for this
      };

      // Send webhook
      //@ts-ignore
      const eventTrigger: WebhookTriggerEvents = "BOOKING_CANCELLED";
      // Send Webhook call if hooked to BOOKING.CANCELLED
      const subscriberOptions = {
        userId: bookingToReschedule.userId,
        eventTypeId: (bookingToReschedule.eventTypeId as number) || 0,
        triggerEvent: eventTrigger,
      };
      const webhooks = await getWebhooks(subscriberOptions);
      const promises = webhooks.map((webhook) =>
        sendPayload(webhook.secret, eventTrigger, new Date().toISOString(), webhook, evt).catch((e) => {
          console.error(
            `Error executing webhook for event: ${eventTrigger}, URL: ${webhook.subscriberUrl}`,
            e
          );
        })
      );
      await Promise.all(promises);
    }

    return res.status(200).json(bookingToReschedule);
  } catch (error) {
    if (error instanceof Error) {
      throw new Error("Error.request.reschedule " + error?.message);
    }
  }
};

function validate(
  handler: (req: NextApiRequest, res: NextApiResponse) => Promise<RescheduleResponse | NextApiResponse | void>
) {
  return async (req: NextApiRequest, res: NextApiResponse) => {
    if (req.method === "POST") {
      try {
        rescheduleSchema.parse(req.body);
      } catch (error) {
        if (error instanceof ZodError && error?.name === "ZodError") {
          return res.status(400).json(error?.issues);
        }
        return res.status(402).end();
      }
    } else {
      return res.status(405).end();
    }
    await handler(req, res);
  };
}

export default validate(handler);
