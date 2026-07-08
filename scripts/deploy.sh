#!/bin/bash

set -euo pipefail

SERVICE="${1:-}"

PROJECT_DIR="/opt/omnirraai"

if [ -z "$SERVICE" ]; then
    echo "Usage:"
    echo "./scripts/deploy.sh backend"
    echo "./scripts/deploy.sh voice-ai"
    echo "./scripts/deploy.sh chatbot"
    echo "./scripts/deploy.sh landing"
    echo "./scripts/deploy.sh dashboard"
    echo "./scripts/deploy.sh nginx"
    exit 1
fi

cd "$PROJECT_DIR"

echo "=========================================="
echo "🚀 Deploying: $SERVICE"
echo "=========================================="

case "$SERVICE" in

backend)

    echo "📦 Building Backend..."
    docker compose build backend backend-worker

    echo ""
    echo "🚀 Starting Backend..."
    docker compose up -d backend backend-worker
    ;;

voice-ai)

    echo "📦 Building Voice AI..."
    docker compose build voice-ai

    echo ""
    echo "🚀 Starting Voice AI..."
    docker compose up -d voice-ai
    ;;

chatbot)

    echo "📦 Building Chatbot..."
    docker compose build chatbot

    echo ""
    echo "🚀 Starting Chatbot..."
    docker compose up -d chatbot
    ;;

landing)

    echo "📦 Building Landing..."
    docker compose build landing

    echo ""
    echo "🚀 Starting Landing..."
    docker compose up -d landing
    ;;

dashboard)

    echo "📦 Building Dashboard..."
    docker compose build dashboard

    echo ""
    echo "🚀 Starting Dashboard..."
    docker compose up -d dashboard
    ;;

nginx)

    echo "🧪 Checking Nginx Config..."

    docker compose exec nginx nginx -t

    echo ""

    echo "🔄 Reloading Nginx..."

    docker compose exec nginx nginx -s reload
    ;;

*)

    echo "❌ Invalid service."

    exit 1

    ;;

esac

echo ""
echo "✅ $SERVICE deployment completed."