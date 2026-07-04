#!/bin/sh
# wait-for-it.sh

set -e

host="$1"
shift
cmd="$@"

until pg_isready -h "$host" -U "${POSTGRES_USER:-roberto_user}"; do
  >&2 echo "PostgreSQL on $host is unavailable - sleeping"
  sleep 1
done

>&2 echo "PostgreSQL on $host is up - executing command"
exec $cmd
