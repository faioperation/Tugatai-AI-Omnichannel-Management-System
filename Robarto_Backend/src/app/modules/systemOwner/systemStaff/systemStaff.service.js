import prisma from "../../../prisma/client.js";
import bcrypt from "bcrypt";
import { envVars } from "../../../config/env.js";
import {
  ASSIGNABLE_STAFF_PERMISSIONS,
  RESTRICTED_SYSTEM_PERMISSIONS,
} from "../../../constant/permissions.js";

const resolveAndValidatePermissions = async (permissionInputs = []) => {
  if (!permissionInputs || permissionInputs.length === 0) {
    return [];
  }

  // Find DB permissions by ID or by Name
  const dbPermissions = await prisma.permission.findMany({
    where: {
      OR: [
        { id: { in: permissionInputs } },
        { name: { in: permissionInputs } },
      ],
    },
  });

  if (dbPermissions.length !== permissionInputs.length) {
    throw new Error("One or more permission IDs/names provided do not exist in database");
  }

  for (const perm of dbPermissions) {
    if (RESTRICTED_SYSTEM_PERMISSIONS.includes(perm.name)) {
      throw new Error(`Restricted permission '${perm.name}' cannot be assigned to System Staff`);
    }
    if (!ASSIGNABLE_STAFF_PERMISSIONS.includes(perm.name)) {
      throw new Error(`Permission '${perm.name}' is not assignable to System Staff`);
    }
  }

  return dbPermissions;
};

const createStaff = async (payload) => {
  const { email, password, firstName, lastName, phone, permissions = [] } = payload;

  // Check if user already exists
  const existingUser = await prisma.user.findUnique({
    where: { email },
  });

  if (existingUser) {
    throw new Error("User with this email already exists");
  }

  // Validate initial permissions (supports IDs or Names)
  const dbPermissions = await resolveAndValidatePermissions(permissions);

  // Get SYSTEM_STAFF role ID
  const staffRole = await prisma.role.findUnique({
    where: { name: "SYSTEM_STAFF" },
  });

  if (!staffRole) {
    throw new Error("SYSTEM_STAFF role does not exist in database. Please run seed script.");
  }

  const passwordHash = await bcrypt.hash(
    password,
    Number(envVars.BCRYPT_SALT_ROUND || 10)
  );

  // Execute in transaction
  const result = await prisma.$transaction(async (tx) => {
    const user = await tx.user.create({
      data: {
        email,
        passwordHash,
        firstName,
        lastName,
        phone,
        status: "ACTIVE",
        isVerified: true,
      },
    });

    await tx.userRole.create({
      data: {
        userId: user.id,
        roleId: staffRole.id,
      },
    });

    for (const perm of dbPermissions) {
      await tx.userPermission.create({
        data: {
          userId: user.id,
          permissionId: perm.id,
        },
      });
    }

    return user;
  });

  return getStaffById(result.id);
};

const getAllStaff = async () => {
  const staffRole = await prisma.role.findUnique({
    where: { name: "SYSTEM_STAFF" },
  });

  if (!staffRole) return [];

  const staffUsers = await prisma.user.findMany({
    where: {
      roles: {
        some: {
          roleId: staffRole.id,
        },
      },
      deletedAt: null,
    },
    select: {
      id: true,
      email: true,
      firstName: true,
      lastName: true,
      phone: true,
      status: true,
      isVerified: true,
      createdAt: true,
      updatedAt: true,
      roles: {
        select: {
          role: {
            select: {
              name: true,
            },
          },
        },
      },
      userPermissions: {
        select: {
          permission: {
            select: {
              id: true,
              name: true,
              description: true,
            },
          },
        },
      },
    },
    orderBy: {
      createdAt: "desc",
    },
  });

  return staffUsers.map((user) => ({
    ...user,
    roles: user.roles.map((r) => r.role.name),
    permissions: user.userPermissions.map((up) => up.permission),
  }));
};

const getStaffById = async (id) => {
  const staffRole = await prisma.role.findUnique({
    where: { name: "SYSTEM_STAFF" },
  });

  const user = await prisma.user.findFirst({
    where: {
      id,
      roles: {
        some: {
          roleId: staffRole?.id,
        },
      },
      deletedAt: null,
    },
    select: {
      id: true,
      email: true,
      firstName: true,
      lastName: true,
      phone: true,
      status: true,
      isVerified: true,
      createdAt: true,
      updatedAt: true,
      roles: {
        select: {
          role: {
            select: {
              name: true,
            },
          },
        },
      },
      userPermissions: {
        select: {
          permission: {
            select: {
              id: true,
              name: true,
              description: true,
            },
          },
        },
      },
    },
  });

  if (!user) {
    throw new Error("System Staff user not found");
  }

  return {
    ...user,
    roles: user.roles.map((r) => r.role.name),
    permissions: user.userPermissions.map((up) => up.permission),
  };
};

const updateStaff = async (id, payload) => {
  await getStaffById(id); // Ensures user exists and is a staff

  const updatedUser = await prisma.user.update({
    where: { id },
    data: payload,
  });

  return getStaffById(updatedUser.id);
};

const updateStaffPermissions = async (id, permissions) => {
  await getStaffById(id); // Ensures user exists and is a staff

  // Validate and resolve permissions (supports IDs or Names)
  const dbPermissions = await resolveAndValidatePermissions(permissions);

  // Atomically replace user permissions
  await prisma.$transaction(async (tx) => {
    // Delete existing permissions for this user
    await tx.userPermission.deleteMany({
      where: { userId: id },
    });

    // Create new permissions
    for (const perm of dbPermissions) {
      await tx.userPermission.create({
        data: {
          userId: id,
          permissionId: perm.id,
        },
      });
    }
  });

  return getStaffById(id);
};

const getAllAssignablePermissions = async () => {
  const permissions = await prisma.permission.findMany({
    where: {
      name: { in: ASSIGNABLE_STAFF_PERMISSIONS },
    },
    select: {
      id: true,
      name: true,
      description: true,
    },
  });

  return permissions;
};

const getMyPermissions = async (userId) => {
  const userPermissions = await prisma.userPermission.findMany({
    where: { userId },
    include: { permission: true },
  });

  return userPermissions.map((up) => up.permission);
};

const deleteStaff = async (id) => {
  await getStaffById(id); // Ensures user exists and is a active staff

  const deletedUser = await prisma.user.update({
    where: { id },
    data: {
      deletedAt: new Date(),
      status: "INACTIVE",
    },
  });

  return deletedUser;
};

export const SystemStaffService = {
  createStaff,
  getAllStaff,
  getStaffById,
  updateStaff,
  deleteStaff,
  updateStaffPermissions,
  getAllAssignablePermissions,
  getMyPermissions,
};
