# Deployment Guide — Hetzner VPS

## Maintainer trick

```sh
cd ~/server/timeagocalculator.com && git pull && cd infra/docker && docker compose -f compose.yml up -d --build
```

Or use the deploy script:

```sh
~/server/timeagocalculator.com/infra/scripts/deploy.sh
```

---

## Architecture

```
User → Caddy (TLS + gzip + HSTS) → Rails (port 3000) → PostgreSQL + Redis
```

**Docker services (`infra/docker/compose.yml`):**

| Service | Image | Role |
|---------|-------|------|
| `web` | local Dockerfile | Rails app |
| `sidekiq` | local Dockerfile | Background jobs |
| `postgres` | postgres:17-alpine | Database |
| `redis` | redis:7-alpine | Cache / queues |
| `caddy` | caddy:2-alpine | Reverse proxy + auto-HTTPS |

Caddy config: `infra/caddy/Caddyfile`
- Redirects `www` → apex
- HSTS, X-Frame-Options, Referrer-Policy headers

---

## Pre-Deployment Checklist

- [ ] Hetzner VPS created and accessible via SSH
- [ ] `timeagocalculator.com` A records pointed to VPS IP in Cloudflare
- [ ] `apps/web/config/master.key` backed up offline
- [ ] SSH key added to GitHub

---

## Part 1: VPS Setup (Hetzner)

### 1.1 Create VPS

- **Server Type:** CX22 (2 vCPU, 4 GB RAM) — ~€4.35/month
- **OS:** Ubuntu 24.04 LTS
- **Location:** Falkenstein (fsn1) or Ashburn (ash)
- **Backups:** Enable

### 1.2 Initial Setup

```bash
ssh root@YOUR_VPS_IP
apt update && apt upgrade -y
```

### 1.3 Install Docker

```bash
curl -fsSL https://get.docker.com | sh
docker --version
docker compose version
```

### 1.4 Firewall

```bash
apt install ufw -y
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable
```

### 1.5 Create Deploy User

```bash
adduser deploy
usermod -aG docker deploy
su - deploy
```

### 1.6 Clone Repository

```bash
git clone git@github.com:bobadilla-tech/timeagocalculator.com.git ~/server/timeagocalculator.com
cd ~/server/timeagocalculator.com
```

---

## Part 2: Environment Configuration

### 2.1 Create `.env`

```bash
cd ~/server/timeagocalculator.com/infra/docker
cp .env.example .env
nano .env
chmod 600 .env
```

Fill in:

```bash
POSTGRES_PASSWORD=<strong random password>
RAILS_MASTER_KEY=<32-char hex — see below>
SECRET_KEY_BASE=<generate below>
```

**Important:** `RAILS_MASTER_KEY` is read from `.env` by the container — the file `apps/web/config/master.key` is NOT mounted or copied into the image. Get the value from your local machine:

```bash
# On your local Mac:
cat /path/to/timeagocalculator.com/apps/web/config/master.key
# e.g. af6670a8dd3a8f878c7b759e9f26f112  (32 hex chars)
```

Paste that exact value into `.env`. Verify length:

```bash
grep RAILS_MASTER_KEY .env | cut -d= -f2 | wc -c
# Must print 33 (32 chars + newline)
```

### 2.2 Generate `SECRET_KEY_BASE`

```bash
openssl rand -hex 64
```

---

## Part 3: DNS (Cloudflare)

Domain `timeagocalculator.com` is on Cloudflare.

1. Go to [dash.cloudflare.com](https://dash.cloudflare.com) → `timeagocalculator.com` → DNS
2. Add:

| Type | Name | Content | Proxy status |
|------|------|---------|--------------|
| A | `@` | `YOUR_VPS_IP` | Proxied ☁️ |
| A | `www` | `YOUR_VPS_IP` | Proxied ☁️ |

Cloudflare proxy is fine — Let's Encrypt HTTP-01 challenge works through it. Wait ~1 min for propagation before deploying.

---

## Part 4: Deploy

```bash
cd ~/server/timeagocalculator.com/infra/docker
docker compose -f compose.yml up -d --build
```

The `bin/docker-entrypoint` runs `db:prepare` (create + migrate + seed) automatically on first start.

### Check status

```bash
docker compose -f compose.yml ps
docker compose -f compose.yml logs -f web
docker compose -f compose.yml logs caddy
```

### Verify SSL

After ~30 seconds Caddy fetches the certificate:

```bash
curl -I https://timeagocalculator.com/up
# HTTP/2 200
```

---

## Part 5: Post-Deployment

### Smoke test

```bash
curl https://timeagocalculator.com/up
docker compose -f compose.yml logs web | tail -50
```

### Set up automatic backups

```bash
nano /home/deploy/backup-db.sh
```

```bash
#!/usr/bin/env bash
set -euo pipefail
BACKUP_DIR="$HOME/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
mkdir -p "$BACKUP_DIR"

docker compose -f "$HOME/server/timeagocalculator.com/infra/docker/compose.yml" \
  exec -T postgres pg_dump -U postgres web_production \
  > "$BACKUP_DIR/backup_$TIMESTAMP.sql"

find "$BACKUP_DIR" -name "backup_*.sql" -mtime +14 -delete
echo "Backup done: backup_$TIMESTAMP.sql"
```

```bash
chmod +x /home/deploy/backup-db.sh
crontab -e
# Add: 0 3 * * * /home/deploy/backup-db.sh >> /home/deploy/backup.log 2>&1
```

---

## Part 6: Updating Production

```bash
cd ~/server/timeagocalculator.com
git pull
cd infra/docker
docker compose -f compose.yml up -d --build
```

Migrations run automatically on container start.

### Restart without rebuild

```bash
docker compose -f compose.yml restart web
```

### Clean rebuild

```bash
docker compose -f compose.yml build --no-cache web
docker compose -f compose.yml up -d
```

### Wipe database ⚠️ destructive

```bash
docker compose -f compose.yml down -v
docker compose -f compose.yml up -d --build
```

---

## Part 7: Monitoring

```bash
docker compose -f compose.yml stats
docker compose -f compose.yml logs -f
docker compose -f compose.yml logs -f web
df -h
```

---

## Troubleshooting

### Rails won't start

```bash
docker compose -f compose.yml logs web
```

- `RAILS_MASTER_KEY` wrong → check `.env` matches `apps/web/config/master.key`
- `DATABASE_URL` issues → service name in compose is `postgres` not `db`

### Caddy can't get SSL certificate

```bash
docker compose -f compose.yml logs caddy
dig timeagocalculator.com        # verify DNS propagated
```

Confirm UFW allows 80 and 443. Wait 2–3 min after DNS propagation.

### Database connection errors

```bash
docker compose -f compose.yml ps postgres
docker compose -f compose.yml logs postgres
docker compose -f compose.yml restart postgres
```
