-- CreateEnum
CREATE TYPE "WhatsappConnectionType" AS ENUM ('META_CLOUD_API', 'QR_CODE');

-- AlterTable
ALTER TABLE "whatsapp_accounts" ADD COLUMN     "connection_type" "WhatsappConnectionType" NOT NULL DEFAULT 'META_CLOUD_API',
ADD COLUMN     "instance_name" TEXT,
ADD COLUMN     "qr_code" TEXT,
ALTER COLUMN "waba_id" DROP NOT NULL,
ALTER COLUMN "phone_number_id" DROP NOT NULL,
ALTER COLUMN "phone_number" DROP NOT NULL,
ALTER COLUMN "access_token" DROP NOT NULL;

-- CreateIndex
CREATE UNIQUE INDEX "whatsapp_accounts_business_id_instance_name_key" ON "whatsapp_accounts"("business_id", "instance_name");
