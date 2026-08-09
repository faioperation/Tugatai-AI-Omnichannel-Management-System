import { z } from "zod";

const generateWebhookUrlSchema = z.object({
  body: z.object({
    businessId: z.string().optional(),
    branchId: z.string().optional(),
  }),
});

const sendWebhookMessageSchema = z.object({
  body: z.object({
    conversationId: z.string({
      required_error: "conversationId is required",
    }),
    message: z.string().optional(),
  }),
  params: z.object({
    token: z.string().optional(),
    businessId: z.string().optional(),
    branchId: z.string().optional(),
  }),
});

export const MessageWebhookValidation = {
  generateWebhookUrlSchema,
  sendWebhookMessageSchema,
};
