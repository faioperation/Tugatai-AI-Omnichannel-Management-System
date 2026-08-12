import prisma from "./client.js";
import bcrypt from "bcrypt";
import { envVars } from "../config/env.js";

export const seedDatabase = async () => {
  try {
    const ownerEmail = "system@admin.com";
    
    // Check if seed data already exists
    const existingOwner = await prisma.user.findUnique({
      where: { email: ownerEmail },
    });

    if (existingOwner) {
      console.log("Primary seed data already exists, checking for new seed updates...");
    }
    console.log("--- Starting seed process ---");

    // Seed Permissions
    const permissionsData = [
      { name: "DASHBOARD_OVERVIEW", description: "View system dashboard overview" },
      { name: "TENANT_CREATE", description: "Create and onboard new tenants/businesses" },
      { name: "TENANT_UPDATE", description: "Update tenant/business details" },
      { name: "TENANT_VIEW", description: "View tenant/business details" },
      { name: "TENANT_DELETE", description: "Delete tenant/business" },
      { name: "ALL_USER_VIEW", description: "View all system users" },
      { name: "DEMO_BOOKING_VIEW", description: "View demo bookings" },
      { name: "DEMO_BOOKING_UPDATE", description: "Update demo bookings" },
      { name: "CHATBOT_AGENT_VIEW", description: "View chatbot agent details" },
      { name: "CHATBOT_AGENT_KNOWLEDGE_BASE_UPLOAD", description: "Upload knowledge base files" },
      { name: "CHATBOT_AGENT_KNOWLEDGE_UPDATE", description: "Update chatbot agent knowledge base" },
      { name: "VOICE_AGENT_VIEW", description: "View voice agent details" },
      { name: "VOICE_AGENT_CREATE", description: "Create voice agent" },
      { name: "VOICE_AGENT_UPDATE", description: "Update voice agent" },
      { name: "VOICE_AGENT_TWILIO_NUMBER_ADD", description: "Add Twilio phone number for voice agent" },
      { name: "CHANGE_SUBSCRIPTION_PRICING", description: "Change subscription pricing" },
      { name: "ACCESS_BILLING_SECRETS", description: "Access billing secrets" },
      { name: "SYSTEM_SETTINGS", description: "System settings management" },
      { name: "MANAGE_STAFF_PERMISSIONS", description: "Manage staff users and permissions" },
    ];

    const createdPermissions = [];
    for (const perm of permissionsData) {
      const p = await prisma.permission.upsert({
        where: { name: perm.name },
        update: {},
        create: perm,
      });
      createdPermissions.push(p);
    }

    // Seed Roles
    const rolesData = [
      { name: "SYSTEM_OWNER", description: "System Owner Role" },
      { name: "SYSTEM_STAFF", description: "System Staff Role" },
      { name: "BUSINESS_OWNER", description: "Business Owner Role" },
      { name: "BRANCH_MANAGER", description: "Branch Manager Role" },
      { name: "CUSTOMER", description: "Customer Role" },
    ];

    const createdRoles = {};
    for (const role of rolesData) {
      const r = await prisma.role.upsert({
        where: { name: role.name },
        update: {},
        create: role,
      });
      createdRoles[role.name] = r;
    }

    // Attach all permissions to SYSTEM_OWNER role
    const systemOwnerRole = createdRoles["SYSTEM_OWNER"];
    for (const p of createdPermissions) {
      await prisma.rolePermission.upsert({
        where: {
          roleId_permissionId: {
            roleId: systemOwnerRole.id,
            permissionId: p.id,
          },
        },
        update: {},
        create: {
          roleId: systemOwnerRole.id,
          permissionId: p.id,
        },
      });
    }

    // Seed System Owner User
    const passwordHash = await bcrypt.hash(
      "11",
      Number(envVars?.BCRYPT_SALT_ROUND || 10)
    );
    
    if (!existingOwner) {
      const owner = await prisma.user.create({
        data: {
          email: ownerEmail,
          passwordHash,
          firstName: "System",
          lastName: "Owner",
          status: "ACTIVE",
          isVerified: true,
        },
      });

      await prisma.userRole.create({
        data: {
          userId: owner.id,
          roleId: systemOwnerRole.id,
        },
      });

      console.log("Primary seed created successfully");
    }

    // Seed new users as requested
    const newPasswordHash = await bcrypt.hash(
      "123456",
      Number(envVars?.BCRYPT_SALT_ROUND || 10)
    );

    const usersToSeed = [
      { email: "systemowner@test.com", firstName: "System", lastName: "Owner", roleName: "SYSTEM_OWNER" },
      { email: "businessowner@test.com", firstName: "Business", lastName: "Owner", roleName: "BUSINESS_OWNER" }
    ];

    for (const u of usersToSeed) {
      let existingUser = await prisma.user.findUnique({ where: { email: u.email } });
      if (!existingUser) {
        const createdUser = await prisma.user.create({
          data: {
            email: u.email,
            passwordHash: newPasswordHash,
            firstName: u.firstName,
            lastName: u.lastName,
            status: "ACTIVE",
            isVerified: true,
          },
        });
        await prisma.userRole.create({
          data: {
            userId: createdUser.id,
            roleId: createdRoles[u.roleName].id,
          },
        });
        console.log(`Seeded user ${u.email}`);
      }
    }
  } catch (error) {
    console.error("❌ Error seeding database:", error);
    throw error;
  }
};

// Auto-run if executed directly as a script
if (import.meta.url === `file://${process.argv[1]}` || process.argv[1]?.endsWith('seed.js')) {
  console.log("Running prisma seed script directly...");
  seedDatabase()
    .then(async () => {
      console.log("Seeding complete. Disconnecting Prisma...");
      await prisma.$disconnect();
      process.exit(0);
    })
    .catch(async (e) => {
      console.error("Seeding failed:", e);
      await prisma.$disconnect();
      process.exit(1);
    });
}
