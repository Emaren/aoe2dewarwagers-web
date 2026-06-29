# AoE2DEWarWagers HD Parity Execution

Date: June 28, 2026

## Goal

Mirror the current AoE2HDBets product feature surface into AoE2DEWarWagers
without changing the canonical HD checkout or collapsing the two products into
one deployment.

## Canonical range

- DE parity base: AoE2HDBets web commit `7d97e73`
- Canonical target audited for this refresh: `2ce3cee`
- Ported delta: 86 commits across 70 tracked web files

## Preserved DE boundaries

- Public site: `aoe2dewarwagers.com`
- Replay API: `api-prodn.aoe2dewarwagers.com`
- Web/API binds: `127.0.0.1:4000` and `127.0.0.1:4400`
- VPS web path:
  `/mnt/HC_Volume_105319120/www-moved/AoE2DEWarWagers/app-prodn`
- Service: `aoe2dewarwagers-web.service`
- Session, watcher protocol, release artifacts, and DE replay parsing remain
  DE-specific.
- Structured challenge funding uses `source_app=aoe2dewarwagers` and
  `aoe2dewarwagers:challenge-<id>:v1` settlement ids so HD and DE deposits do
  not collide on the shared WoloChain rail.
- Staking deposit classification uses the existing
  `AoE2DEWarWagers staking deposit` memo.
- Network-restricted production reads WoloChain through
  `WOLO_INTERNAL_RPC_URL=http://127.0.0.1:27657` and
  `WOLO_INTERNAL_REST_URL=http://127.0.0.1:1318`; browser-facing endpoints
  remain the public RPC/REST domains.

## Mirrored feature delta

- Basic, Advanced, and Extreme Challenge composer with structured signed
  funding memos, server-provided escrow address, WoloChain deposit proof, and
  automatic eligible title stakes.
- App-side verified title transfer and payout preparation while chain-backed
  custody remains an explicit WoloChain intent.
- Operator-reserve versus user-liability staking classification, a 10,000 WOLO
  reserve policy, safer unstake funding math, and public activity filtering.
- WoloChain wallet, network-holder, explorer, and visual polish.
- Lobby chat full-history filters, Apple-style reactions, stable history
  scrolling, Recent Match Feed backfill, and full leaderboard hydration.
- Profile Basic/Advanced/Extreme routing and the cinematic Extreme warrior
  profile.
- Stronger media-asset operator controls.
- Cinematic championship payout cards and belt-pedestal presentation.
- `/zodiac` Deathmatch recruitment, training, messaging, and replay-review
  funnel, rebranded for AoE2 DE.

## Verification gate

```bash
npx prisma generate
npx tsc --noEmit --pretty false
npm run test:mainnet-staking
npm run test:staking-reserve
npm run test:challenge
npm run test:zodiac
npm run build
```

Production smoke targets:

- `/`, `/lobby`, `/challenge`, `/profile`, `/champions`, `/zodiac`
- `/staking`, `/wolo`, `/admin/media-assets`, `/admin/trophies`
- `/api/lobby`, `/api/challenges`, `/api/staking/config`,
  `/api/staking/activity`, `/api/wolo/network`

The DE schema also includes
`20260629_040500_add_precise_staking_reward_columns`, which closes the missing
schema-history gap for `reward_uwolo` and `micro_reward_carry_uwolo`.

## Deployment

Push DE `main`, then on the VPS:

```bash
cd /mnt/HC_Volume_105319120/www-moved/AoE2DEWarWagers/app-prodn
git pull --ff-only origin main
npx prisma migrate deploy
npm run build
sudo systemctl restart aoe2dewarwagers-web.service
systemctl is-active aoe2dewarwagers-web.service
```

## Completion record

Complete. Commits `4e09a83`, `eff8fd8`, and `58f9536` were pushed and deployed
to `aoe2dewarwagers.com`. Prisma reports 47 applied migrations, both DE web and
API services are active, the WoloChain node reports advancing consensus, and
the listed public route/API smoke targets return successfully with no fresh
application errors in the web service journal.
