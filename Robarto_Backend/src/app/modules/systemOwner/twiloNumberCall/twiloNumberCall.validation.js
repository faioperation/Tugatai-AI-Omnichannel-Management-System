import { z } from "zod";

const setupTwilioSchema = z.object({
  body: z.object({
    twilio_sid: z.string({
      required_error: "twilio_sid is required",
    }),
    twilio_auth_token: z.string({
      required_error: "twilio_auth_token is required",
    }),
    twilio_number: z.string({
      required_error: "twilio_number is required",
    }),
    transfer_number: z.string({
      required_error: "transfer_number is required",
    }),
    vapiId: z.string().optional(),
    assistant_id: z.string().optional(),
  }).refine(data => data.vapiId || data.assistant_id, {
    message: "Either vapiId or assistant_id is required",
    path: ["vapiId"],
  }),
});

const teardownTelephonySchema = z.object({
  body: z.object({
    phone_number_id: z.string().optional().nullable(),
    transfer_tool_id: z.string().optional().nullable(),
    assistant_id: z.string().optional().nullable(),
  }).refine(data => data.phone_number_id || data.transfer_tool_id, {
    message: "Either phone_number_id or transfer_tool_id must be provided",
    path: ["phone_number_id"],
  }),
});

export const TwiloNumberCallValidation = {
  setupTwilioSchema,
  teardownTelephonySchema,
};
