#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# ec2_bootstrap.sh  (Ubuntu)
# Run this ONCE on your EC2 Ubuntu instance to prepare it for CodeDeploy
# Usage: sudo bash ec2_bootstrap.sh
# ─────────────────────────────────────────────────────────────────────────────
set -e

echo "===== EC2 Bootstrap for Simple Project (Ubuntu) ====="

# ── Update system ─────────────────────────────────────────────────────────────
apt-get update -y
apt-get upgrade -y

# ── Install dependencies ──────────────────────────────────────────────────────
apt-get install -y \
  curl wget unzip git \
  ca-certificates gnupg lsb-release

# ── Install Docker (official repo) ───────────────────────────────────────────
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
echo "✅ Docker installed: $(docker --version)"

# ── Install Docker Compose v2 ─────────────────────────────────────────────────
curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64" \
  -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
echo "✅ Docker Compose installed: $(docker-compose --version)"

# ── Install AWS CLI v2 ────────────────────────────────────────────────────────
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install
rm -rf /tmp/aws /tmp/awscliv2.zip
echo "✅ AWS CLI installed: $(aws --version)"

# ── Install CodeDeploy Agent (Ubuntu) ────────────────────────────────────────
apt-get install -y ruby-full
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
cd /tmp
wget "https://aws-codedeploy-${REGION}.s3.${REGION}.amazonaws.com/latest/install"
chmod +x ./install
./install auto
systemctl start codedeploy-agent
systemctl enable codedeploy-agent
echo "✅ CodeDeploy agent: $(systemctl is-active codedeploy-agent)"

# ── Create app directory ──────────────────────────────────────────────────────
mkdir -p /home/ubuntu/simple-project
chown -R ubuntu:ubuntu /home/ubuntu/simple-project

echo ""
echo "🎉 EC2 Ubuntu Bootstrap complete!"
echo "   Docker:          $(docker --version)"
echo "   Docker Compose:  $(docker-compose --version)"
echo "   AWS CLI:         $(aws --version)"
echo "   CodeDeploy:      $(systemctl is-active codedeploy-agent)"
