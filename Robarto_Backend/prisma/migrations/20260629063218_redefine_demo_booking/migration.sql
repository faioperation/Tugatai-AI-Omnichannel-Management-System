/*
  Warnings:

  - You are about to drop the column `credits` on the `demo_booking` table. All the data in the column will be lost.
  - You are about to drop the column `date` on the `demo_booking` table. All the data in the column will be lost.
  - You are about to drop the column `mobile_number` on the `demo_booking` table. All the data in the column will be lost.
  - Added the required column `description` to the `demo_booking` table without a default value. This is not possible if the table is not empty.
  - Added the required column `name` to the `demo_booking` table without a default value. This is not possible if the table is not empty.
  - Added the required column `subject` to the `demo_booking` table without a default value. This is not possible if the table is not empty.
  - Made the column `email` on table `demo_booking` required. This step will fail if there are existing NULL values in that column.

*/
-- AlterEnum
ALTER TYPE "DemoBookingStatus" ADD VALUE 'FAILED';

-- DropIndex
DROP INDEX "demo_booking_email_key";

-- AlterTable
ALTER TABLE "demo_booking" DROP COLUMN "credits",
DROP COLUMN "date",
DROP COLUMN "mobile_number",
ADD COLUMN     "description" TEXT NOT NULL,
ADD COLUMN     "name" TEXT NOT NULL,
ADD COLUMN     "subject" TEXT NOT NULL,
ALTER COLUMN "email" SET NOT NULL;
