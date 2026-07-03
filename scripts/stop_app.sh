#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# stop_app.sh  (Ubuntu)
# CodeDeploy ApplicationStop hook
# Gracefully stops running containers before new deployment
# ─────────────────────────────────────────────────────────────────────────────
set -e

APP_DIR=/home/ubuntu/simple-project
echo "===== [ApplicationStop] Stopping running containers ====="

if [ -f "$APP_DIR/docker-compose.prod.yml" ]; then
  cd $APP_DIR
  docker-compose -f docker-compose.prod.yml down --remove-orphans || true
  echo "✅ Containers stopped"
else
  echo "⚠️  No existing deployment found — skipping stop"
fi

# Clean up dangling images to free disk space
docker image prune -f || true

echo "===== [ApplicationStop] Done ====="
