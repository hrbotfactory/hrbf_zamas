import * as z from "zod"
import * as imports from "../zod-utils"
import { CompleteUser, UserModel, CompleteEventType, EventTypeModel, CompleteApp, AppModel } from "./index"

// Helper schema for JSON fields
type Literal = boolean | number | string
type Json = Literal | { [key: string]: Json } | Json[]
const literalSchema = z.union([z.string(), z.number(), z.boolean()])
const jsonSchema: z.ZodSchema<Json> = z.lazy(() => z.union([literalSchema, z.array(jsonSchema), z.record(jsonSchema)]))

export const _WebhookModel = z.object({
  id: z.string(),
  userId: z.number().int().nullish(),
  eventTypeId: z.number().int().nullish(),
  subscriberUrl: z.string(),
  payloadTemplate: z.string().nullish(),
  createdAt: z.date(),
  active: z.boolean(),
  eventTriggers: jsonSchema,
  appId: z.string().nullish(),
  secret: z.string().nullish(),
})

export interface CompleteWebhook extends z.infer<typeof _WebhookModel> {
  user?: CompleteUser | null
  eventType?: CompleteEventType | null
  app?: CompleteApp | null
}

/**
 * WebhookModel contains all relations on your model in addition to the scalars
 *
 * NOTE: Lazy required in case of potential circular dependencies within schema
 */
export const WebhookModel: z.ZodSchema<CompleteWebhook> = z.lazy(() => _WebhookModel.extend({
  user: UserModel.nullish(),
  eventType: EventTypeModel.nullish(),
  app: AppModel.nullish(),
}))
