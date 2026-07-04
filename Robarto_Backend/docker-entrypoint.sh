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

# Step 2: Apply database migrations in production mode
echo "⚙️  Applying database migrations..."
if npx prisma migrate deploy; then
  echo "✅ Database migrations applied successfully!"
else
  echo "❌ Database migration failed! Aborting startup."
  exit 1
fi

# Step 3: Run database seeding idempotently
echo "🌱 Seeding database..."
if node src/app/prisma/seed.js; then
  echo "✅ Seeding phase completed successfully!"
else
  echo "⚠️  Database seeding returned a non-zero exit status, check logs for details."
fi

# Step 4: Boot app server
echo "🚀 Booting Node.js Express server..."
exec node src/server.js
