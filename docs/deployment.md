# Deployment Guide — Hetzner VPS

## Maintainer trick

```sh
cd ~/server/timeagocalculator.com/apps/web && git pull && docker compose up -d --build
```

---

## Architecture

```
User → Caddy (TLS + gzip) → Rails (port 3000) → PostgreSQL + Redis
```

**Docker services (docker-compose.yml):**

| Service | Image | Role |
|---------|-------|------|
| `web`   | local Dockerfile | Rails app |
| `db`    | postgres:16-alpine | Database |
| `redis` | redis:7-alpine | Cache / sessions |
| `caddy` | caddy:2-alpine | Reverse proxy + auto-HTTPS |

Caddy obtains a Let's Encrypt certificate automatically on first boot. No Certbot needed.

---

## Pre-Deployment Checklist

- [ ] Hetzner VPS created and accessible via SSH
- [ ] Domain purchased with an A record pointing to the VPS IP
- [ ] `config/master.key` available (keep offline backup)
- [ ] SSH key added to GitHub (or use HTTPS clone)

---

## Part 1: VPS Setup (Hetzner)

### 1.1 Create VPS

**Recommended:**

- **Server Type:** CX22 (2 vCPU, 4 GB RAM) — ~€4.35/month
- **OS:** Ubuntu 24.04 LTS
- **Location:** Falkenstein (fsn1) or Ashburn (ash) based on audience
- **Backups:** Enable (adds ~20% — worth it)

### 1.2 Initial Server Setup

```bash
ssh root@YOUR_VPS_IP

apt update && apt upgrade -y
```

### 1.3 Install Docker

```bash
curl -fsSL https://get.docker.com | sh

# Verify
docker --version
docker compose version
```

### 1.4 Configure Firewall

```bash
apt install ufw -y

ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw enable

ufw status verbose
```

### 1.5 Create Deploy User (recommended)

```bash
adduser deploy
usermod -aG docker deploy
su - deploy
```

### 1.6 Clone Repository

```bash
# HTTPS
git clone https://github.com/YOUR_ORG/timeagocalculator.com.git ~/server/timeagocalculator.com

# SSH (if deploy key configured)
git clone git@github.com:YOUR_ORG/timeagocalculator.com.git ~/server/timeagocalculator.com

cd ~/server/timeagocalculator.com/apps/web
```

---

## Part 2: Environment Configuration

### 2.1 Create `.env` from the example

```bash
cp .env.production.example .env
nano .env
```

Fill in every value:

```bash
POSTGRES_USER=rails
POSTGRES_PASSWORD=<strong random password>
POSTGRES_DB=timeagocalculator

DATABASE_URL=postgres://rails:<same password>@db:5432/timeagocalculator
REDIS_URL=redis://redis:6379/0

RAILS_MASTER_KEY=<contents of config/master.key>
SECRET_KEY_BASE=<generate below>

RAILS_LOG_LEVEL=info
```

### 2.2 Generate `SECRET_KEY_BASE`

```bash
openssl rand -hex 64
```

### 2.3 Set file permissions

```bash
chmod 600 .env
```

---

## Part 3: Configure Domain

### 3.1 Update Caddyfile

```bash
nano Caddyfile
```

Replace `yourdomain.com` with your actual domain:

```caddyfile
timeagocalculator.com {
    encode gzip
    reverse_proxy web:3000
}
```

### 3.2 DNS

Point an A record to the VPS IP before deploying (Caddy needs to reach Let's Encrypt):

| Type | Name | Content |
|------|------|---------|
| A | @ | YOUR_VPS_IP |
| A | www | YOUR_VPS_IP |

---

## Part 4: Deploy

```bash
cd ~/server/timeagocalculator.com/apps/web

docker compose up -d --build
```

This builds the Rails image, starts all services, and runs `db:prepare` (migrations + seed) automatically via `bin/docker-entrypoint`.

### Check status

```bash
docker compose ps
docker compose logs -f web
docker compose logs caddy
```

### Verify SSL

After ~30 seconds Caddy fetches the certificate automatically:

```bash
curl -I https://yourdomain.com/up
# HTTP/2 200
```

---

## Part 5: Post-Deployment

### 5.1 Smoke test

```bash
# Health check
curl https://yourdomain.com/up

# Check logs for errors
docker compose logs web | tail -50
```

### 5.2 Set up automatic backups

Create the backup script:

```bash
nano /home/deploy/backup-db.sh
```

```bash
#!/usr/bin/env bash
set -euo pipefail
BACKUP_DIR="$HOME/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
mkdir -p "$BACKUP_DIR"

docker compose -f "$HOME/server/timeagocalculator.com/apps/web/docker-compose.yml" \
  exec -T db pg_dump -U "${POSTGRES_USER:-rails}" timeagocalculator \
  > "$BACKUP_DIR/backup_$TIMESTAMP.sql"

# Keep last 14 days
find "$BACKUP_DIR" -name "backup_*.sql" -mtime +14 -delete

echo "Backup done: backup_$TIMESTAMP.sql"
```

```bash
chmod +x /home/deploy/backup-db.sh

# Add to crontab — daily at 3 AM
crontab -e
# Add: 0 3 * * * /home/deploy/backup-db.sh >> /home/deploy/backup.log 2>&1
```

---

## Part 6: Updating Production

Standard update — pulls latest code and rebuilds changed layers only:

```bash
cd ~/server/timeagocalculator.com/apps/web
git pull
docker compose up -d --build
```

Migrations run automatically on container start via `bin/docker-entrypoint` (`db:prepare`).

### Restart without rebuild

```bash
docker compose restart web
```

### Clean rebuild (if Docker cache is stale)

```bash
docker compose build --no-cache web
docker compose up -d
```

### Wipe database and redeploy (destructive — loses all data)

```bash
docker compose down -v   # -v removes volumes
docker compose up -d --build
```

---

## Part 7: Monitoring

```bash
# Live resource usage
docker compose stats

# All service logs
docker compose logs -f

# Web logs only
docker compose logs -f web

# Disk usage
df -h
du -sh /var/lib/docker/volumes/*
```

---

## Troubleshooting

### Rails won't start

```bash
docker compose logs web
```

Common causes:
- **`RAILS_MASTER_KEY` missing or wrong** — check `.env` matches `config/master.key`
- **`DATABASE_URL` wrong** — verify hostname is `db` (the Compose service name)
- **Port conflict** — ensure nothing else uses port 80/443

### Caddy can't get SSL certificate

1. Verify DNS has propagated: `dig yourdomain.com`
2. Confirm ports 80 and 443 are open in UFW
3. Check Caddy logs: `docker compose logs caddy`
4. Wait 2–3 min after DNS propagation for Let's Encrypt to issue

### Database connection errors

```bash
docker compose ps db          # Should be "healthy"
docker compose logs db        # Look for errors
docker compose restart db
```

### Out of disk space

```bash
# Remove unused Docker images/containers
docker system prune -f

# Check volume sizes
du -sh /var/lib/docker/volumes/*
```
