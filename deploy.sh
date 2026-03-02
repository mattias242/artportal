#!/usr/bin/env bash
set -euo pipefail

NAS="mattiaswahlberg@neomeda-nas.lan"
APP_DIR="/volume2/web/artportal"
COMPOSE="/var/packages/ContainerManager/target/usr/bin/docker-compose"
DOCKER="/var/packages/ContainerManager/target/usr/bin/docker"

echo "==> Syncar filer till NAS..."
rsync -avz --delete \
  --exclude '.git' --exclude '.DS_Store' --exclude '.venv' \
  --exclude '__pycache__' --exclude '.env' --exclude '.claude' \
  ./ "$NAS:$APP_DIR/"

echo "==> Bygger och startar container..."
ssh "$NAS" "cd $APP_DIR && $COMPOSE up -d --build"

echo "==> Klar! Status:"
ssh "$NAS" "$DOCKER ps --filter name=artportal"
