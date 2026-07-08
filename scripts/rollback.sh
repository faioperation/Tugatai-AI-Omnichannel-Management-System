#!/bin/bash

set -e

echo "========================================"
echo "↩️ Rolling Back"
echo "========================================"

cd /opt/omnirraai

git reset --hard HEAD~1

docker compose build

docker compose up -d

echo ""

echo "✅ Rollback completed."