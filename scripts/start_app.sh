#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# start_app.sh  (Ubuntu)
# CodeDeploy AfterInstall hook
# Pulls latest images from ECR and starts containers via Docker Compose
# ─────────────────────────────────────────────────────────────────────────────
set -e

APP_DIR=/home/ubuntu/simple-project
ENV_FILE=$APP_DIR/scripts/deploy.env

echo "===== [AfterInstall] Starting application (Ubuntu) ====="

# Load deploy environment variables written by CodeBuild
if [ -f "$ENV_FILE" ]; then
  echo "→ Loading deploy environment from $ENV_FILE"
  source $ENV_FILE
else
  echo "❌ ERROR: deploy.env not found at $ENV_FILE"
  exit 1
fi

# Ensure Docker daemon is running
systemctl start docker || true
sleep 2

# ── Login to ECR ──────────────────────────────────────────────────────────────
echo "→ Logging into ECR..."
aws ecr get-login-password --region $AWS_DEFAULT_REGION \
  | docker login --username AWS --password-stdin \
    $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com

# ── Pull latest images from ECR ───────────────────────────────────────────────
echo "→ Pulling images from ECR (tag: $IMAGE_TAG)..."
docker pull $FRONTEND_URI:$IMAGE_TAG
docker pull $BACKEND_URI:$IMAGE_TAG

# Tag as 'current' so docker-compose.prod.yml can use simple names
docker tag $FRONTEND_URI:$IMAGE_TAG simple-project-frontend:current
docker tag $BACKEND_URI:$IMAGE_TAG  simple-project-backend:current
echo "✅ Images pulled"

# ── Load DB credentials from EC2 /etc/environment ────────────────────────────
if [ -f /etc/environment ]; then
  source /etc/environment
fi

# ── Fix ownership ─────────────────────────────────────────────────────────────
chown -R ubuntu:ubuntu $APP_DIR

# ── Start containers ──────────────────────────────────────────────────────────
echo "→ Starting containers with Docker Compose..."
cd $APP_DIR

export FRONTEND_IMAGE=$FRONTEND_URI:$IMAGE_TAG
export BACKEND_IMAGE=$BACKEND_URI:$IMAGE_TAG

docker-compose -f docker-compose.prod.yml up -d --force-recreate --remove-orphans

echo "✅ Containers started successfully"
echo "===== [AfterInstall] Done ====="
