import { WebhookTriggerEvents } from "@calcom/lib/utils/types/WebhookTriggerEvents";
import prisma from "@calcom/prisma";

export type GetSubscriberOptions = {
  userId: number;
  eventTypeId: number;
  triggerEvent: typeof WebhookTriggerEvents;
};

/** @deprecated use `packages/lib/webhooks/subscriptions.tsx` */
const getWebhooks = async (options: GetSubscriberOptions) => {
  const { userId, eventTypeId } = options;
  const allWebhooks = await prisma.webhook.findMany({
    where: {
      OR: [
        {
          userId,
        },
        {
          eventTypeId,
        },
      ],
      AND: {
        eventTriggers: {
          array_contains: options.triggerEvent,
        },
        active: {
          equals: true,
        },
      },
    },
    select: {
      id: true,
      subscriberUrl: true,
      payloadTemplate: true,
      appId: true,
      secret: true,
    },
  });

  return allWebhooks;
};

export default getWebhooks;
