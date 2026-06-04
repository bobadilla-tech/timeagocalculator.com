#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../docker"

docker compose -f compose.yml pull
docker compose -f compose.yml up -d --build
docker compose -f compose.yml exec web bin/rails db:migrate
echo "Deploy complete."
