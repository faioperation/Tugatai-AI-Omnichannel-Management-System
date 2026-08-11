import { z } from "zod";

const createStaffSchema = z.object({
  body: z.object({
    email: z.string().email("Invalid email address"),
    password: z.string().min(6, "Password must be at least 6 characters"),
    firstName: z.string().min(1, "First name is required"),
    lastName: z.string().optional(),
    phone: z.string().optional(),
    permissions: z.array(z.string()).optional(),
  }),
});

const updateStaffSchema = z.object({
  body: z.object({
    firstName: z.string().optional(),
    lastName: z.string().optional(),
    phone: z.string().optional(),
    status: z.enum(["ACTIVE", "INACTIVE", "SUSPENDED"]).optional(),
  }),
});

const updatePermissionsSchema = z.object({
  body: z.object({
    permissions: z.array(z.string()),
  }),
});

export const SystemStaffValidation = {
  createStaffSchema,
  updateStaffSchema,
  updatePermissionsSchema,
};
