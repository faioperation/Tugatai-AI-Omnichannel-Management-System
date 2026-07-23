#!/bin/sh
set -e

echo "========================================"
echo "🚀 Starting Robarto Backend"
echo "========================================"

echo "⏳ Waiting for PostgreSQL..."

until pg_isready \
  -h "${DB_HOST:-postgres}" \
  -p "${DB_PORT:-5432}" \
  -U "${POSTGRES_USER:-roberto_user}" > /dev/null 2>&1
do
  echo "⌛ PostgreSQL is unavailable. Retrying..."
  sleep 2
done

echo "✅ PostgreSQL is ready."

echo "⚙️ Running Prisma migrations..."
npx prisma migrate deploy

npx prisma db push

echo "✅ Prisma migrations completed."

if [ "${RUN_SEED}" = "true" ]; then
  echo "🌱 Running database seed..."
  node src/app/prisma/seed.js
  echo "✅ Database seeding completed."
fi

echo "🚀 Starting application..."

exec "$@"