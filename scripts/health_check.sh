#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# health_check.sh  (Ubuntu)
# CodeDeploy ApplicationStart hook
# Polls backend and frontend health endpoints — fails deploy if unhealthy
# ─────────────────────────────────────────────────────────────────────────────
set -e

echo "===== [ApplicationStart] Running health checks (Ubuntu) ====="

MAX_RETRIES=12
WAIT_SECONDS=10

# ── Backend health check ──────────────────────────────────────────────────────
echo "→ Checking backend (port 5000)..."
for i in $(seq 1 $MAX_RETRIES); do
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5000/health || echo "000")
  if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Backend healthy (attempt $i)"
    break
  fi
  if [ $i -eq $MAX_RETRIES ]; then
    echo "❌ Backend health check FAILED after $MAX_RETRIES attempts"
    docker logs simple_backend --tail 50 || true
    exit 1
  fi
  echo "  ⏳ Not ready yet (HTTP $HTTP_CODE) — waiting ${WAIT_SECONDS}s... ($i/$MAX_RETRIES)"
  sleep $WAIT_SECONDS
done

# ── Frontend health check ─────────────────────────────────────────────────────
echo "→ Checking frontend (port 80)..."
for i in $(seq 1 $MAX_RETRIES); do
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:80 || echo "000")
  if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Frontend healthy (attempt $i)"
    break
  fi
  if [ $i -eq $MAX_RETRIES ]; then
    echo "❌ Frontend health check FAILED after $MAX_RETRIES attempts"
    docker logs simple_frontend --tail 50 || true
    exit 1
  fi
  echo "  ⏳ Not ready yet (HTTP $HTTP_CODE) — waiting ${WAIT_SECONDS}s... ($i/$MAX_RETRIES)"
  sleep $WAIT_SECONDS
done

echo "🎉 All health checks passed! Deployment successful."
echo "===== [ApplicationStart] Done ====="
