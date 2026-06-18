# AoE2DEWarWagers HD Parity Execution

Date: June 18, 2026

## Goal

Mirror the current AoE2HDBets product feature surface into AoE2DEWarWagers
without changing the HD canon or collapsing the two products into one
deployment.

## Preserved DE boundaries

- Public site: `aoe2dewarwagers.com`
- Replay API: `api-prodn.aoe2dewarwagers.com`
- Web/API binds: `127.0.0.1:4000` and `127.0.0.1:4400`
- Session, watcher protocol, package identity, services, and release artifacts
  remain DE-specific
- DE replay-folder discovery and DE runtime metadata enrichment remain in the
  DE watcher
- WoloChain mainnet RPC/REST remain shared infrastructure, not HD product
  ownership

## Mirrored feature baseline

- Kingdom, Champions, Nations, Forum, Wolomania, and PWA/footer surfaces
- Advanced lobby ticker, Watch & Chat arena, market tile, and recent-match
  improvements
- Advanced player command-center profiles and replay archive
- Mainnet WOLO transfer indexing, staking derivation, reward activity, custody
  balances, payout guards, and transaction diagnostics
- Expanded admin command tower, media assets, watcher funnel, wallet-friction,
  settlement, and WoloChain activity rails
- First-party browser streaming and watcher-native rolling WebM streaming
- Watcher `1.5.0` finality-aware upload behavior, telemetry, backpressure, and
  display-first capture modes
- API replay-finality contract and DE parser fallback hardening

## Verification gate

- Web: `npx prisma generate`
- Web: `npx tsc --noEmit --pretty false`
- Web: `npm run test:mainnet-staking`
- Web: `npm run build`
- API: `.venv-codex/bin/pytest -q tests/test_replay_upload_metadata.py`
- Watcher: `npm test`

The broad legacy API suite is not a release gate until its missing
`tests/recs/small.mgz` fixture and async pytest plugin are restored.

## Deployment sequence

1. Build and sync watcher `1.5.0` packages into the DE download directory.
2. Push the watcher, API, and web repositories.
3. Pull API and web `main` on the VPS.
4. Apply API Alembic and web Prisma migrations.
5. Build the web app.
6. Restart `aoe2dewarwagers-api.service` and
   `aoe2dewarwagers-web.service`.
7. Verify public routes, replay API health, lobby/betting/staking payloads,
   stream routes, watcher release metadata, and watcher artifact downloads.
