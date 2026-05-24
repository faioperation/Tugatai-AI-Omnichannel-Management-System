import prisma from "../src/app/prisma/client.js";
import bcrypt from "bcrypt";
import { envVars } from "../src/app/config/env.js";

export async function runSeed() {
  const ownerEmail = "system@admin.com";
  
  // Check if seed data already exists
  const existingOwner = await prisma.user.findUnique({
    where: { email: ownerEmail },
  });

  if (existingOwner) {
    console.log("seed data already exist");
    return;
  }

  // Seed Permissions
  const permissionsData = [
    { name: "MANAGE_USERS", description: "Can manage users" },
    { name: "MANAGE_ROLES", description: "Can manage roles and permissions" },
    { name: "MANAGE_BUSINESS", description: "Can manage businesses" },
    { name: "VIEW_DASHBOARD", description: "Can view system dashboard" },
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

  console.log("seed created successfully");
}

// Only run automatically if executed directly (not imported)
if (process.argv[1] && process.argv[1].endsWith('seed.js')) {
  runSeed()
    .catch((e) => {
      console.error(e);
      process.exit(1);
    })
    .finally(async () => {
      await prisma.$disconnect();
    });
}
