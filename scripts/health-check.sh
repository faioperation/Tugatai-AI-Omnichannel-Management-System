#!/bin/bash

set -e

echo "========================================"
echo "🩺 Running Health Checks"
echo "========================================"

SERVICES=(
    "Backend|http://localhost:8001/health"
    "Voice AI|http://localhost:8002/health"
    "Chatbot|http://localhost:8005/health"
    "Landing|http://localhost:3000"
)

FAILED=0

for SERVICE in "${SERVICES[@]}"; do

    NAME=$(echo "$SERVICE" | cut -d'|' -f1)
    URL=$(echo "$SERVICE" | cut -d'|' -f2)

    echo ""
    echo "Checking $NAME..."

    if curl -fsS "$URL" > /dev/null; then
        echo "✅ $NAME is healthy."
    else
        echo "❌ $NAME failed."

        FAILED=1
    fi

done

echo ""

if [ "$FAILED" -eq 1 ]; then
    echo "❌ One or more services failed."

    exit 1
fi

echo "🎉 All services are healthy."