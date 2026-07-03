#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# install_dependencies.sh  (Ubuntu)
# CodeDeploy BeforeInstall hook
# Ensures Docker, Docker Compose, and AWS CLI are installed on Ubuntu EC2
# ─────────────────────────────────────────────────────────────────────────────
set -e

echo "===== [BeforeInstall] Installing dependencies (Ubuntu) ====="

# ── Install Docker if missing ─────────────────────────────────────────────────
if ! command -v docker &> /dev/null; then
  echo "→ Installing Docker..."
  apt-get update -y
  apt-get install -y ca-certificates curl gnupg lsb-release

  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null

  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin
  systemctl start docker
  systemctl enable docker
  usermod -aG docker ubuntu
  echo "✅ Docker installed"
else
  echo "✅ Docker already installed: $(docker --version)"
fi

# ── Install Docker Compose if missing ────────────────────────────────────────
if ! command -v docker-compose &> /dev/null; then
  echo "→ Installing Docker Compose..."
  curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64" \
    -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
  echo "✅ Docker Compose installed"
else
  echo "✅ Docker Compose already installed: $(docker-compose --version)"
fi

# ── Install AWS CLI if missing ────────────────────────────────────────────────
if ! command -v aws &> /dev/null; then
  echo "→ Installing AWS CLI..."
  apt-get install -y unzip
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
  unzip -q /tmp/awscliv2.zip -d /tmp
  /tmp/aws/install
  rm -rf /tmp/aws /tmp/awscliv2.zip
  echo "✅ AWS CLI installed"
else
  echo "✅ AWS CLI already installed: $(aws --version)"
fi

# ── Ensure Docker is running ──────────────────────────────────────────────────
systemctl start docker || true

echo "===== [BeforeInstall] Done ====="
