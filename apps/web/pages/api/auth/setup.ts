import { NextApiRequest, NextApiResponse } from "next";
import z from "zod";

import { isPasswordValid } from "@calcom/lib/auth";
import { hashPassword } from "@calcom/lib/auth";
import { HttpError } from "@calcom/lib/http-error";
import { defaultHandler, defaultResponder } from "@calcom/lib/server";
import slugify from "@calcom/lib/slugify";
import { IdentityProvider } from "@calcom/lib/utils/types/IdentityProvider";
import prisma from "@calcom/prisma";

const querySchema = z.object({
  username: z
    .string()
    .refine((val) => val.trim().length >= 1, { message: "Please enter at least one character" }),
  full_name: z.string().min(3, "Please enter at least 3 characters"),
  email_address: z.string().email({ message: "Please enter a valid email" }),
  password: z.string().refine((val) => isPasswordValid(val.trim()), {
    message:
      "The password must be a minimum of 7 characters long containing at least one number and have a mixture of uppercase and lowercase letters",
  }),
});

async function handler(req: NextApiRequest, res: NextApiResponse) {
  const userCount = await prisma.user.count();
  if (userCount !== 0) {
    throw new HttpError({ statusCode: 400, message: "No setup needed." });
  }

  const parsedQuery = querySchema.safeParse(req.body);
  if (!parsedQuery.success) {
    throw new HttpError({ statusCode: 422, message: parsedQuery.error.message });
  }

  const username = slugify(parsedQuery.data.username.trim());
  const userEmail = parsedQuery.data.email_address.toLowerCase();

  const hashedPassword = await hashPassword(parsedQuery.data.password);

  await prisma.user.create({
    data: {
      username,
      email: userEmail,
      password: hashedPassword,
      role: "ADMIN",
      name: parsedQuery.data.full_name,
      emailVerified: new Date(),
      locale: "en", // TODO: We should revisit this
      plan: "PRO",
      identityProvider: "CAL",
    },
  });

  return { message: "First admin user created successfuly." };
}

export default defaultHandler({
  POST: Promise.resolve({ default: defaultResponder(handler) }),
});
