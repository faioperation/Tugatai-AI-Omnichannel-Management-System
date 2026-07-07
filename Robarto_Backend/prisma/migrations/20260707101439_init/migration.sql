-- CreateEnum
CREATE TYPE "UserStatus" AS ENUM ('ACTIVE', 'INACTIVE', 'SUSPENDED', 'PENDING');

-- CreateEnum
CREATE TYPE "BusinessStatus" AS ENUM ('ACTIVE', 'INACTIVE', 'SUSPENDED', 'PENDING');

-- CreateEnum
CREATE TYPE "RoleName" AS ENUM ('SYSTEM_OWNER', 'BUSINESS_OWNER', 'BRANCH_MANAGER', 'CUSTOMER');

-- CreateEnum
CREATE TYPE "DemoBookingStatus" AS ENUM ('PENDING', 'CALLED', 'FAILED');

-- CreateEnum
CREATE TYPE "PlanName" AS ENUM ('NORMAL', 'MEDIUM', 'PREMIUM');

-- CreateEnum
CREATE TYPE "PlanType" AS ENUM ('YEARLY', 'MONTHLY');

-- CreateEnum
CREATE TYPE "BusinessPlanType" AS ENUM ('MONTHLY', 'YEARLY');

-- CreateEnum
CREATE TYPE "SubscriptionStatus" AS ENUM ('ACTIVE', 'CANCELED', 'PAST_DUE', 'INACTIVE', 'UNPAID');

-- CreateEnum
CREATE TYPE "SubscriptionBillingCycle" AS ENUM ('MONTHLY', 'YEARLY');

-- CreateEnum
CREATE TYPE "BranchManagerStatus" AS ENUM ('ACTIVE', 'INACTIVE', 'SUSPENDED');

-- CreateEnum
CREATE TYPE "BusinessType" AS ENUM ('ORDER_BOOKING', 'APPOINTMENT_BOOKING', 'PARCEL_DELIVERY');

-- CreateEnum
CREATE TYPE "FeatureName" AS ENUM ('ORDER_BOOKING', 'APPOINTMENT_BOOKING', 'PARCEL_DELIVERY');

-- CreateEnum
CREATE TYPE "LeadStatus" AS ENUM ('COLD', 'WARM', 'BOOKED', 'HOT');

-- CreateEnum
CREATE TYPE "PaymentStatus" AS ENUM ('PENDING', 'COMPLETED', 'FAILED', 'REFUNDED');

-- CreateEnum
CREATE TYPE "BookingStatus" AS ENUM ('PENDING', 'CONFIRMED', 'PROCESSING', 'CHECKED_IN', 'PICKUP_PENDING', 'PICKED_UP', 'IN_TRANSIT', 'OUT_FOR_DELIVERY', 'READY', 'IN_PROGRESS', 'COMPLETED', 'DELIVERED', 'RETURNED', 'RESCHEDULED', 'NO_SHOW', 'ON_HOLD', 'CANCELLED', 'REJECTED', 'REFUNDED', 'FAILED');

-- CreateEnum
CREATE TYPE "SourceEnum" AS ENUM ('WEBSITE', 'SOCIAL_MEDIA', 'REFERRAL', 'COLD_CALL', 'OTHER', 'WHATSAPP', 'MESSENGER', 'INSTAGRAM');

-- CreateEnum
CREATE TYPE "WhatsappAccountStatus" AS ENUM ('ACTIVE', 'INACTIVE', 'DISCONNECTED');

-- CreateEnum
CREATE TYPE "WhatsappMessageDirection" AS ENUM ('INCOMING', 'OUTGOING');

-- CreateEnum
CREATE TYPE "WhatsappMessageStatus" AS ENUM ('SENT', 'DELIVERED', 'READ', 'FAILED');

-- CreateTable
CREATE TABLE "users" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "password_hash" TEXT NOT NULL,
    "first_name" TEXT,
    "last_name" TEXT,
    "profile_picture" TEXT,
    "gender" TEXT,
    "country" TEXT,
    "phone" TEXT,
    "status" "UserStatus" NOT NULL DEFAULT 'ACTIVE',
    "is_verified" BOOLEAN NOT NULL DEFAULT false,
    "forgot_password_status" BOOLEAN NOT NULL DEFAULT false,
    "last_login_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "roles" (
    "id" TEXT NOT NULL,
    "name" "RoleName" NOT NULL,
    "description" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "roles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_roles" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "role_id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_roles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "permissions" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "permissions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "role_permissions" (
    "id" TEXT NOT NULL,
    "role_id" TEXT NOT NULL,
    "permission_id" TEXT NOT NULL,

    CONSTRAINT "role_permissions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "demo_booking" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "subject" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "status" "DemoBookingStatus" NOT NULL DEFAULT 'PENDING',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "demo_booking_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "system_owner_plan" (
    "id" TEXT NOT NULL,
    "name" "PlanName" NOT NULL,
    "price" DECIMAL(65,30) NOT NULL,
    "billing_cycle" "PlanType" NOT NULL DEFAULT 'MONTHLY',
    "plan_list" TEXT[],
    "created_by_id" TEXT,
    "deleted_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "system_owner_plan_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "activity_log" (
    "id" TEXT NOT NULL,
    "activity_name" TEXT,
    "activity_title" TEXT,
    "activity_type" TEXT,
    "mark_as_read" BOOLEAN NOT NULL DEFAULT false,
    "created_by_id" TEXT,
    "deleted_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "activity_log_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SubscriptionPlan" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "description" TEXT,
    "monthlyPrice" DOUBLE PRECISION NOT NULL,
    "yearlyPrice" DOUBLE PRECISION,
    "currency" TEXT NOT NULL DEFAULT 'USD',
    "stripeProductId" TEXT,
    "stripeMonthlyPriceId" TEXT,
    "stripeYearlyPriceId" TEXT,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "createdById" TEXT,

    CONSTRAINT "SubscriptionPlan_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SubscriptionFeature" (
    "id" TEXT NOT NULL,
    "planId" TEXT NOT NULL,
    "key" TEXT NOT NULL,
    "value" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "SubscriptionFeature_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "business_subscriptions" (
    "id" TEXT NOT NULL,
    "business_id" TEXT NOT NULL,
    "plan_id" TEXT NOT NULL,
    "status" "SubscriptionStatus" NOT NULL DEFAULT 'INACTIVE',
    "billing_cycle" "SubscriptionBillingCycle" NOT NULL DEFAULT 'MONTHLY',
    "stripe_customer_id" TEXT,
    "stripe_subscription_id" TEXT,
    "start_date" TIMESTAMP(3) NOT NULL,
    "end_date" TIMESTAMP(3) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "business_subscriptions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "subscription_invoices" (
    "id" TEXT NOT NULL,
    "business_id" TEXT NOT NULL,
    "subscription_id" TEXT NOT NULL,
    "invoice_no" TEXT NOT NULL,
    "amount" DOUBLE PRECISION NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'paid',
    "billing_cycle" "SubscriptionBillingCycle" NOT NULL,
    "stripe_invoice_id" TEXT,
    "invoice_path" TEXT,
    "invoice_url" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "subscription_invoices_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "businesses" (
    "id" TEXT NOT NULL,
    "owner_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "logo" TEXT,
    "email" TEXT,
    "phone" TEXT,
    "country" TEXT,
    "address" TEXT,
    "industry" TEXT,
    "status" "BusinessStatus" NOT NULL DEFAULT 'INACTIVE',
    "description" TEXT,
    "plan_id" TEXT,
    "plan_cycle" "BusinessPlanType" NOT NULL DEFAULT 'MONTHLY',
    "created_by_id" TEXT,
    "credits" INTEGER NOT NULL DEFAULT 0,
    "business_type" "BusinessType",
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "businesses_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "branches" (
    "id" TEXT NOT NULL,
    "business_id" TEXT NOT NULL,
    "manager_id" TEXT,
    "name" TEXT NOT NULL,
    "email" TEXT,
    "phone" TEXT,
    "address" TEXT,
    "created_by" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "branches_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "branch_managers" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "status" "BranchManagerStatus" NOT NULL DEFAULT 'ACTIVE',
    "created_by" TEXT,
    "business_id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "branch_managers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "order_bookings" (
    "id" TEXT NOT NULL,
    "business_id" TEXT NOT NULL,
    "branch_id" TEXT,
    "created_by" TEXT,
    "customer_name" TEXT NOT NULL,
    "customer_number" TEXT NOT NULL,
    "email" TEXT,
    "country" TEXT,
    "product_name" TEXT,
    "price" TEXT NOT NULL,
    "note" TEXT,
    "status" "BookingStatus" NOT NULL DEFAULT 'PENDING',
    "conversation_id" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "order_bookings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "order_details" (
    "id" TEXT NOT NULL,
    "business_id" TEXT NOT NULL,
    "branch_id" TEXT,
    "order_id" TEXT NOT NULL,
    "delivery_date" TEXT,
    "delivery_address" TEXT,
    "product_type" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "order_details_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "appointment_bookings" (
    "id" TEXT NOT NULL,
    "business_id" TEXT NOT NULL,
    "branch_id" TEXT,
    "created_by" TEXT,
    "customer_name" TEXT NOT NULL,
    "customer_number" TEXT NOT NULL,
    "email" TEXT,
    "country" TEXT,
    "price" TEXT NOT NULL,
    "note" TEXT,
    "status" "BookingStatus" NOT NULL DEFAULT 'PENDING',
    "conversation_id" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "appointment_bookings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "appointment_details" (
    "id" TEXT NOT NULL,
    "business_id" TEXT NOT NULL,
    "branch_id" TEXT,
    "appointment_id" TEXT NOT NULL,
    "appointment_date" TEXT,
    "appointment_time" TIMESTAMP(3),
    "platform" TEXT,
    "duration" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "appointment_details_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "parcel_deliveries" (
    "id" TEXT NOT NULL,
    "business_id" TEXT NOT NULL,
    "branch_id" TEXT,
    "created_by" TEXT,
    "customer_name" TEXT NOT NULL,
    "customer_number" TEXT NOT NULL,
    "email" TEXT,
    "country" TEXT,
    "product_name" TEXT,
    "price" TEXT NOT NULL,
    "note" TEXT,
    "status" "BookingStatus" NOT NULL DEFAULT 'PENDING',
    "conversation_id" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "parcel_deliveries_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "parcel_details" (
    "id" TEXT NOT NULL,
    "business_id" TEXT NOT NULL,
    "branch_id" TEXT,
    "parcel_delivery_id" TEXT NOT NULL,
    "pickup_address" TEXT,
    "delivery_date" TEXT,
    "delivery_address" TEXT,
    "product_type" TEXT,
    "product_height" TEXT,
    "product_weight" INTEGER,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "parcel_details_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "features" (
    "id" TEXT NOT NULL,
    "feature_name" "FeatureName" NOT NULL,

    CONSTRAINT "features_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "additional_details" (
    "id" TEXT NOT NULL,
    "business_id" TEXT NOT NULL,
    "branch_id" TEXT,
    "feature_id" TEXT,
    "reference_id" TEXT NOT NULL,
    "key" TEXT NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "additional_details_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payment_details" (
    "id" TEXT NOT NULL,
    "reference_id" TEXT NOT NULL,
    "created_by" TEXT,
    "payment_status" "PaymentStatus" NOT NULL DEFAULT 'PENDING',
    "payment_method" TEXT,
    "transaction_id" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "payment_details_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pricings" (
    "id" TEXT NOT NULL,
    "business_id" TEXT NOT NULL,
    "created_by" TEXT,
    "branch_id" TEXT,
    "rule_name" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "configuration" JSONB NOT NULL,
    "status" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "pricings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "crm_leads" (
    "id" TEXT NOT NULL,
    "business_id" TEXT NOT NULL,
    "created_by" TEXT,
    "branch_id" TEXT,
    "name" TEXT NOT NULL,
    "email" TEXT,
    "phone" TEXT,
    "country" TEXT,
    "source" "SourceEnum",
    "address" TEXT,
    "note" TEXT,
    "status" "LeadStatus" NOT NULL DEFAULT 'COLD',
    "conversation_id" TEXT,
    "metadata" JSONB,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "crm_leads_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "audit_logs" (
    "id" TEXT NOT NULL,
    "business_id" TEXT NOT NULL,
    "user_id" TEXT,
    "action" TEXT NOT NULL,
    "target_table" TEXT NOT NULL,
    "target_id" TEXT NOT NULL,
    "old_values" JSONB,
    "new_values" JSONB,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "social_connections" (
    "id" TEXT NOT NULL,
    "business_id" TEXT NOT NULL,
    "branch_id" TEXT,
    "provider" TEXT NOT NULL,
    "page_id" TEXT NOT NULL,
    "page_name" TEXT NOT NULL,
    "access_token" TEXT NOT NULL,
    "token_expiry" TIMESTAMP(3),
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "ai_reply" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "social_connections_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "conversations" (
    "id" TEXT NOT NULL,
    "business_id" TEXT NOT NULL,
    "branch_id" TEXT,
    "platform" TEXT NOT NULL,
    "customer_id" TEXT NOT NULL,
    "customer_name" TEXT,
    "last_message" TEXT,
    "last_message_at" TIMESTAMP(3),
    "ai_reply" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "conversations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "messages" (
    "id" TEXT NOT NULL,
    "conversation_id" TEXT NOT NULL,
    "senderType" TEXT NOT NULL,
    "sender_id" TEXT NOT NULL,
    "type" TEXT DEFAULT 'text',
    "message_text" TEXT,
    "media_url" TEXT,
    "file_path" TEXT,
    "platform_message_id" TEXT,
    "raw_payload" JSONB,
    "ai_reply" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "messages_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "whatsapp_accounts" (
    "id" TEXT NOT NULL,
    "business_id" TEXT NOT NULL,
    "branch_id" TEXT,
    "waba_id" TEXT NOT NULL,
    "phone_number_id" TEXT NOT NULL,
    "phone_number" TEXT NOT NULL,
    "access_token" TEXT NOT NULL,
    "status" "WhatsappAccountStatus" NOT NULL DEFAULT 'ACTIVE',
    "ai_reply" BOOLEAN NOT NULL DEFAULT true,
    "metadata" JSONB,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "whatsapp_accounts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "whatsapp_contacts" (
    "id" TEXT NOT NULL,
    "business_id" TEXT NOT NULL,
    "whatsapp_account_id" TEXT NOT NULL,
    "wa_user_id" TEXT NOT NULL,
    "name" TEXT,
    "phone_number" TEXT NOT NULL,
    "profile_picture" TEXT,
    "last_message_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "whatsapp_contacts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "whatsapp_conversations" (
    "id" TEXT NOT NULL,
    "business_id" TEXT NOT NULL,
    "whatsapp_account_id" TEXT NOT NULL,
    "contact_id" TEXT NOT NULL,
    "last_message_id" TEXT,
    "unread_count" INTEGER NOT NULL DEFAULT 0,
    "last_message_at" TIMESTAMP(3),
    "ai_reply" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "whatsapp_conversations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "whatsapp_messages" (
    "id" TEXT NOT NULL,
    "business_id" TEXT NOT NULL,
    "whatsapp_account_id" TEXT NOT NULL,
    "conversation_id" TEXT NOT NULL,
    "contact_id" TEXT NOT NULL,
    "meta_message_id" TEXT,
    "direction" "WhatsappMessageDirection" NOT NULL,
    "type" TEXT NOT NULL,
    "text" TEXT,
    "media_url" TEXT,
    "status" "WhatsappMessageStatus",
    "raw_payload" JSONB,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "whatsapp_messages_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "agent_training" (
    "id" TEXT NOT NULL,
    "system_prompt" TEXT,
    "business_information" TEXT,
    "product_information" JSONB,
    "policies_guidelines" JSONB,
    "faq" JSONB,
    "business_id" TEXT NOT NULL,
    "row_text" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "agent_training_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "agents" (
    "id" TEXT NOT NULL,
    "business_id" TEXT NOT NULL,
    "branch_id" TEXT,
    "rules_file" TEXT NOT NULL,
    "vapi_id" TEXT,
    "metadata" JSONB,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "agents_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "chat_summaries" (
    "id" TEXT NOT NULL,
    "conversation_id" TEXT NOT NULL,
    "business_id" TEXT NOT NULL,
    "items" TEXT,
    "pickup_area" TEXT,
    "destination" TEXT,
    "weight" TEXT,
    "pickup_date_time" TEXT,
    "current_status" TEXT,
    "recent_summary" TEXT,
    "booking_info" JSONB,
    "summary" TEXT,
    "key_points" TEXT[],
    "intent" TEXT,
    "confidence" TEXT,
    "reason" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "chat_summaries_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "campaigns" (
    "id" TEXT NOT NULL,
    "business_id" TEXT NOT NULL,
    "branch_id" TEXT,
    "title" TEXT NOT NULL,
    "selected_people" "LeadStatus"[],
    "scheduled_time" TIMESTAMP(3) NOT NULL,
    "end_date" TIMESTAMP(3),
    "message" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'PENDING',
    "is_expire" BOOLEAN NOT NULL DEFAULT true,
    "country" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "campaigns_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notifications" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "role" "RoleName",
    "business_id" TEXT,
    "branch_id" TEXT,
    "user_id" TEXT,
    "is_read" BOOLEAN NOT NULL DEFAULT false,
    "conversation_id" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "notifications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "fcm_tokens" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "token" TEXT NOT NULL,
    "device_type" TEXT NOT NULL DEFAULT 'WEB',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "fcm_tokens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "google_calendar_connections" (
    "id" TEXT NOT NULL,
    "business_id" TEXT NOT NULL,
    "branch_id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "access_token" TEXT NOT NULL,
    "refresh_token" TEXT NOT NULL,
    "token_expiry" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "google_calendar_connections_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "roles_name_key" ON "roles"("name");

-- CreateIndex
CREATE UNIQUE INDEX "user_roles_user_id_role_id_key" ON "user_roles"("user_id", "role_id");

-- CreateIndex
CREATE UNIQUE INDEX "permissions_name_key" ON "permissions"("name");

-- CreateIndex
CREATE UNIQUE INDEX "role_permissions_role_id_permission_id_key" ON "role_permissions"("role_id", "permission_id");

-- CreateIndex
CREATE UNIQUE INDEX "system_owner_plan_name_key" ON "system_owner_plan"("name");

-- CreateIndex
CREATE UNIQUE INDEX "SubscriptionPlan_slug_key" ON "SubscriptionPlan"("slug");

-- CreateIndex
CREATE UNIQUE INDEX "business_subscriptions_stripe_subscription_id_key" ON "business_subscriptions"("stripe_subscription_id");

-- CreateIndex
CREATE UNIQUE INDEX "subscription_invoices_invoice_no_key" ON "subscription_invoices"("invoice_no");

-- CreateIndex
CREATE UNIQUE INDEX "subscription_invoices_stripe_invoice_id_key" ON "subscription_invoices"("stripe_invoice_id");

-- CreateIndex
CREATE UNIQUE INDEX "branch_managers_email_key" ON "branch_managers"("email");

-- CreateIndex
CREATE UNIQUE INDEX "order_details_order_id_key" ON "order_details"("order_id");

-- CreateIndex
CREATE UNIQUE INDEX "appointment_details_appointment_id_key" ON "appointment_details"("appointment_id");

-- CreateIndex
CREATE UNIQUE INDEX "parcel_details_parcel_delivery_id_key" ON "parcel_details"("parcel_delivery_id");

-- CreateIndex
CREATE UNIQUE INDEX "conversations_business_id_platform_customer_id_key" ON "conversations"("business_id", "platform", "customer_id");

-- CreateIndex
CREATE UNIQUE INDEX "messages_platform_message_id_key" ON "messages"("platform_message_id");

-- CreateIndex
CREATE UNIQUE INDEX "whatsapp_accounts_business_id_phone_number_id_key" ON "whatsapp_accounts"("business_id", "phone_number_id");

-- CreateIndex
CREATE UNIQUE INDEX "whatsapp_contacts_business_id_wa_user_id_key" ON "whatsapp_contacts"("business_id", "wa_user_id");

-- CreateIndex
CREATE UNIQUE INDEX "whatsapp_conversations_business_id_contact_id_key" ON "whatsapp_conversations"("business_id", "contact_id");

-- CreateIndex
CREATE UNIQUE INDEX "whatsapp_messages_meta_message_id_key" ON "whatsapp_messages"("meta_message_id");

-- CreateIndex
CREATE UNIQUE INDEX "chat_summaries_conversation_id_key" ON "chat_summaries"("conversation_id");

-- CreateIndex
CREATE UNIQUE INDEX "fcm_tokens_token_key" ON "fcm_tokens"("token");

-- CreateIndex
CREATE UNIQUE INDEX "google_calendar_connections_branch_id_key" ON "google_calendar_connections"("branch_id");

-- AddForeignKey
ALTER TABLE "user_roles" ADD CONSTRAINT "user_roles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_roles" ADD CONSTRAINT "user_roles_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "roles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "role_permissions" ADD CONSTRAINT "role_permissions_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "roles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "role_permissions" ADD CONSTRAINT "role_permissions_permission_id_fkey" FOREIGN KEY ("permission_id") REFERENCES "permissions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "system_owner_plan" ADD CONSTRAINT "system_owner_plan_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "activity_log" ADD CONSTRAINT "activity_log_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SubscriptionPlan" ADD CONSTRAINT "SubscriptionPlan_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SubscriptionFeature" ADD CONSTRAINT "SubscriptionFeature_planId_fkey" FOREIGN KEY ("planId") REFERENCES "SubscriptionPlan"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "business_subscriptions" ADD CONSTRAINT "business_subscriptions_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "business_subscriptions" ADD CONSTRAINT "business_subscriptions_plan_id_fkey" FOREIGN KEY ("plan_id") REFERENCES "SubscriptionPlan"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "subscription_invoices" ADD CONSTRAINT "subscription_invoices_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "subscription_invoices" ADD CONSTRAINT "subscription_invoices_subscription_id_fkey" FOREIGN KEY ("subscription_id") REFERENCES "business_subscriptions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "businesses" ADD CONSTRAINT "businesses_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "businesses" ADD CONSTRAINT "businesses_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "branches" ADD CONSTRAINT "branches_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "branches" ADD CONSTRAINT "branches_manager_id_fkey" FOREIGN KEY ("manager_id") REFERENCES "branch_managers"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "branches" ADD CONSTRAINT "branches_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "branch_managers" ADD CONSTRAINT "branch_managers_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "branch_managers" ADD CONSTRAINT "branch_managers_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_bookings" ADD CONSTRAINT "order_bookings_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_bookings" ADD CONSTRAINT "order_bookings_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "branches"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_bookings" ADD CONSTRAINT "order_bookings_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_details" ADD CONSTRAINT "order_details_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "order_bookings"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "appointment_bookings" ADD CONSTRAINT "appointment_bookings_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "appointment_bookings" ADD CONSTRAINT "appointment_bookings_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "branches"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "appointment_bookings" ADD CONSTRAINT "appointment_bookings_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "appointment_details" ADD CONSTRAINT "appointment_details_appointment_id_fkey" FOREIGN KEY ("appointment_id") REFERENCES "appointment_bookings"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "parcel_deliveries" ADD CONSTRAINT "parcel_deliveries_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "parcel_deliveries" ADD CONSTRAINT "parcel_deliveries_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "branches"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "parcel_deliveries" ADD CONSTRAINT "parcel_deliveries_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "parcel_details" ADD CONSTRAINT "parcel_details_parcel_delivery_id_fkey" FOREIGN KEY ("parcel_delivery_id") REFERENCES "parcel_deliveries"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "additional_details" ADD CONSTRAINT "additional_details_feature_id_fkey" FOREIGN KEY ("feature_id") REFERENCES "features"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "pricings" ADD CONSTRAINT "pricings_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "pricings" ADD CONSTRAINT "pricings_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "pricings" ADD CONSTRAINT "pricings_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "branches"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "crm_leads" ADD CONSTRAINT "crm_leads_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "crm_leads" ADD CONSTRAINT "crm_leads_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "crm_leads" ADD CONSTRAINT "crm_leads_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "branches"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "social_connections" ADD CONSTRAINT "social_connections_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "social_connections" ADD CONSTRAINT "social_connections_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "branches"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "conversations" ADD CONSTRAINT "conversations_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "conversations" ADD CONSTRAINT "conversations_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "branches"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "messages" ADD CONSTRAINT "messages_conversation_id_fkey" FOREIGN KEY ("conversation_id") REFERENCES "conversations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "whatsapp_accounts" ADD CONSTRAINT "whatsapp_accounts_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "whatsapp_accounts" ADD CONSTRAINT "whatsapp_accounts_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "branches"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "whatsapp_contacts" ADD CONSTRAINT "whatsapp_contacts_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "whatsapp_contacts" ADD CONSTRAINT "whatsapp_contacts_whatsapp_account_id_fkey" FOREIGN KEY ("whatsapp_account_id") REFERENCES "whatsapp_accounts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "whatsapp_conversations" ADD CONSTRAINT "whatsapp_conversations_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "whatsapp_conversations" ADD CONSTRAINT "whatsapp_conversations_whatsapp_account_id_fkey" FOREIGN KEY ("whatsapp_account_id") REFERENCES "whatsapp_accounts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "whatsapp_conversations" ADD CONSTRAINT "whatsapp_conversations_contact_id_fkey" FOREIGN KEY ("contact_id") REFERENCES "whatsapp_contacts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "whatsapp_messages" ADD CONSTRAINT "whatsapp_messages_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "whatsapp_messages" ADD CONSTRAINT "whatsapp_messages_whatsapp_account_id_fkey" FOREIGN KEY ("whatsapp_account_id") REFERENCES "whatsapp_accounts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "whatsapp_messages" ADD CONSTRAINT "whatsapp_messages_conversation_id_fkey" FOREIGN KEY ("conversation_id") REFERENCES "whatsapp_conversations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "whatsapp_messages" ADD CONSTRAINT "whatsapp_messages_contact_id_fkey" FOREIGN KEY ("contact_id") REFERENCES "whatsapp_contacts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "chat_summaries" ADD CONSTRAINT "chat_summaries_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "campaigns" ADD CONSTRAINT "campaigns_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "campaigns" ADD CONSTRAINT "campaigns_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "branches"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "branches"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fcm_tokens" ADD CONSTRAINT "fcm_tokens_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "google_calendar_connections" ADD CONSTRAINT "google_calendar_connections_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "google_calendar_connections" ADD CONSTRAINT "google_calendar_connections_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "branches"("id") ON DELETE CASCADE ON UPDATE CASCADE;
