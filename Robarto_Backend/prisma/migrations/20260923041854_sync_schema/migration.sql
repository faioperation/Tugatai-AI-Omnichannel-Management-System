-- AlterEnum
ALTER TYPE "RoleName" ADD VALUE 'SYSTEM_STAFF';

-- AlterTable
ALTER TABLE "agents" ADD COLUMN     "product_file" TEXT;

-- AlterTable
ALTER TABLE "appointment_bookings" ADD COLUMN     "calender_date" TEXT,
ADD COLUMN     "calender_time" TEXT,
ADD COLUMN     "product_name" TEXT;

-- AlterTable
ALTER TABLE "campaigns" ADD COLUMN     "countries" TEXT[] DEFAULT ARRAY[]::TEXT[],
ADD COLUMN     "product_types" TEXT[] DEFAULT ARRAY[]::TEXT[];

-- AlterTable
ALTER TABLE "conversations" ADD COLUMN     "continue_ai" BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN     "seen" BOOLEAN NOT NULL DEFAULT true;

-- AlterTable
ALTER TABLE "crm_leads" ADD COLUMN     "product_type" TEXT;

-- AlterTable
ALTER TABLE "messages" ADD COLUMN     "continue_ai" BOOLEAN NOT NULL DEFAULT true;

-- AlterTable
ALTER TABLE "notifications" ADD COLUMN     "booking_id" TEXT;

-- AlterTable
ALTER TABLE "order_bookings" ADD COLUMN     "calender_date" TEXT,
ADD COLUMN     "calender_time" TEXT;

-- AlterTable
ALTER TABLE "order_details" ADD COLUMN     "address" TEXT;

-- AlterTable
ALTER TABLE "parcel_deliveries" ADD COLUMN     "calender_date" TEXT,
ADD COLUMN     "calender_time" TEXT;

-- AlterTable
ALTER TABLE "parcel_details" ADD COLUMN     "pickup_date" TEXT,
ADD COLUMN     "pickup_time" TEXT,
ADD COLUMN     "receiver_name" TEXT,
ADD COLUMN     "receiver_phone" TEXT;

-- AlterTable
ALTER TABLE "whatsapp_conversations" ADD COLUMN     "continue_ai" BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN     "seen" BOOLEAN NOT NULL DEFAULT true;

-- AlterTable
ALTER TABLE "whatsapp_messages" ADD COLUMN     "continue_ai" BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN     "location" JSONB;

-- CreateTable
CREATE TABLE "user_permissions" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "permission_id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_permissions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "webhook_urls" (
    "id" TEXT NOT NULL,
    "business_id" TEXT NOT NULL,
    "branch_id" TEXT,
    "token" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "webhook_urls_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "user_permissions_user_id_permission_id_key" ON "user_permissions"("user_id", "permission_id");

-- CreateIndex
CREATE UNIQUE INDEX "webhook_urls_token_key" ON "webhook_urls"("token");

-- AddForeignKey
ALTER TABLE "user_permissions" ADD CONSTRAINT "user_permissions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_permissions" ADD CONSTRAINT "user_permissions_permission_id_fkey" FOREIGN KEY ("permission_id") REFERENCES "permissions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "additional_details" ADD CONSTRAINT "additional_details_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "webhook_urls" ADD CONSTRAINT "webhook_urls_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "webhook_urls" ADD CONSTRAINT "webhook_urls_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "branches"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "agents" ADD CONSTRAINT "agents_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;
