#!/bin/bash

set -e

echo "========================================"
echo "🧹 Cleaning Docker"
echo "========================================"

echo ""

docker image prune -f

docker builder prune -f

docker container prune -f

echo ""

docker system df

echo ""

echo "✅ Cleanup completed."