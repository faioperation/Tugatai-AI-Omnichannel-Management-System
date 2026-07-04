#!/bin/sh
set -e

echo "🚚 --- STARTING BACKEND BOOTSTRAP LIFECYCLE ---"

# Step 1: Wait for Postgres Database to accept connections
echo "⏳ Checking database availability..."

until pg_isready -h postgres -p 5432 -U "${POSTGRES_USER:-roberto_user}" > /dev/null 2>&1; do
  echo "⌛ Postgres is not ready yet - sleeping for 2 seconds..."
  sleep 2
done

echo "✅ Database is online and reachable!"

# Step 2: Sync Prisma schema directly to database
echo "⚙️ Syncing Prisma schema..."

if npx prisma db push; then
  echo "✅ Prisma schema synced successfully!"
else
  echo "❌ Prisma schema sync failed! Aborting startup."
  exit 1
fi

# Step 3: Run database seeding idempotently
echo "🌱 Seeding database..."

if node src/app/prisma/seed.js; then
  echo "✅ Seeding phase completed successfully!"
else
  echo "⚠️ Database seeding returned a non-zero exit status, check logs for details."
fi

# Step 4: Boot app server
echo "🚀 Booting Node.js Express server..."

exec node src/server.js