# VPS Upgrade Checklist (AoE2DEWarWagers)

Run this from the current VPS layout, not the old `/var/www/app-prodn` / `pm2` shape.

Current web truth:
- SSH alias from MBP: `hel1`
- web repo: `/mnt/HC_Volume_105319120/www-moved/AoE2DEWarWagers/app-prodn`
- web service: `aoe2dewarwagers-web.service`
- web bind: `127.0.0.1:4000`
- web runtime user: `tony`

Current API truth:
- api repo: `/mnt/HC_Volume_105319120/www-moved/AoE2DEWarWagers/api-prodn`
- api service: `aoe2dewarwagers-api.service`
- api bind: `127.0.0.1:4400`

## 1) Pull latest code

```bash
ssh hel1

cd /mnt/HC_Volume_105319120/www-moved/AoE2DEWarWagers/app-prodn && git status --short && git pull --ff-only origin main
cd /mnt/HC_Volume_105319120/www-moved/AoE2DEWarWagers/api-prodn && git status --short && git pull --ff-only origin main
```

## 2) Verify required env vars

### `/etc/aoe2dewarwagers/aoe2dewarwagers-web.env`

- `DATABASE_URL=...`
- `SESSION_SECRET=...`
- `AOE2_BACKEND_UPSTREAM=http://127.0.0.1:4400`
- `ADMIN_TOKEN=...`
- optional: `INTERNAL_API_KEY=...`

### `api-prodn` env file

Verify the actual file in service/config before editing. Do not assume the API still reads the old PM2 path.

- `DATABASE_URL=...`
- `ADMIN_TOKEN=...`
- optional: `INTERNAL_API_KEY=...`
- `AUTO_CREATE_TABLES=false`

## 3) Apply DB migrations (backend)

```bash
cd /mnt/HC_Volume_105319120/www-moved/AoE2DEWarWagers/api-prodn
if [ -f venv/bin/activate ]; then source venv/bin/activate; else source .venv/bin/activate; fi
alembic upgrade head
```

## 4) Rebuild/restart services

```bash
cd /mnt/HC_Volume_105319120/www-moved/AoE2DEWarWagers/app-prodn
npm run build
sudo systemctl restart aoe2dewarwagers-web.service
systemctl is-active aoe2dewarwagers-web.service

cd /mnt/HC_Volume_105319120/www-moved/AoE2DEWarWagers/api-prodn
if [ -f venv/bin/activate ]; then source venv/bin/activate; else source .venv/bin/activate; fi
pip install -r requirements.txt
sudo systemctl restart aoe2dewarwagers-api.service
systemctl is-active aoe2dewarwagers-api.service
```

If `git pull` or `npm run build` fails with `Permission denied`, check ownership drift first:

```bash
ls -l /mnt/HC_Volume_105319120/www-moved/AoE2DEWarWagers/app-prodn/app/api/contact-emaren/attachments/[messageId]/route.ts
ls -ld /mnt/HC_Volume_105319120/www-moved/AoE2DEWarWagers/app-prodn/.next /mnt/HC_Volume_105319120/www-moved/AoE2DEWarWagers/app-prodn/.next/cache
sudo chown -R tony:tony /mnt/HC_Volume_105319120/www-moved/AoE2DEWarWagers/app-prodn
```

## 5) Confirm nginx routing model

- `aoe2dewarwagers.com/*` -> `127.0.0.1:4000` (Next)
- `api-prodn.aoe2dewarwagers.com/*` -> `127.0.0.1:4400` (FastAPI)

Template file:
- `/mnt/HC_Volume_105319120/www-moved/AoE2DEWarWagers/app-prodn/deploy/nginx.conf.example`

Reload nginx:

```bash
sudo nginx -t && sudo systemctl reload nginx
```

## 6) Smoke checks

```bash
# App health path (via rewrite)
curl -I https://aoe2dewarwagers.com/
curl -I https://aoe2dewarwagers.com/lobby
curl -I https://aoe2dewarwagers.com/live-games
curl -I https://aoe2dewarwagers.com/challenge
curl -I https://aoe2dewarwagers.com/contact-emaren

# Traffic endpoint should reject anonymous access
curl -i https://aoe2dewarwagers.com/api/traffic

# Backend traffic endpoint should reject missing admin token
curl -i https://api-prodn.aoe2dewarwagers.com/api/traffic

# Backend traffic endpoint with admin token
curl -i -H "Authorization: Bearer $ADMIN_TOKEN" https://api-prodn.aoe2dewarwagers.com/api/traffic

# Web service logs
journalctl -u aoe2dewarwagers-web.service -n 40 --no-pager
```

For inbox attachment issues, verify the protected binary route directly with a real participant session cookie:

```bash
curl -I --cookie "aoe2dewarwagers_session=..." \
  https://aoe2dewarwagers.com/api/contact-emaren/attachments/<messageId>
```

If logs show `Cannot convert argument to a ByteString`, inspect `Content-Disposition` generation in the attachment route before touching the chat UI.

## 7) Watcher rollout

Set watcher env for users:

- `AOE2_API_BASE_URL=https://api-prodn.aoe2dewarwagers.com`
- optional: `AOE2_UPLOAD_API_KEY=...` (if backend `INTERNAL_API_KEY` enabled)
