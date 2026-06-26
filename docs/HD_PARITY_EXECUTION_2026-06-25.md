# AoE2DEWarWagers HD Parity Execution

Date: June 25, 2026

## Goal

Mirror the current AoE2HDBets web feature surface into AoE2DEWarWagers while
keeping AoE2HDBets untouched as the canonical HD site and preserving the DE
site, domain, services, watcher identity, API port, and deployment path.

## Preserved DE boundaries

- Public site: `aoe2dewarwagers.com`
- Replay API: `api-prodn.aoe2dewarwagers.com`
- Web/API binds: `127.0.0.1:4000` and `127.0.0.1:4400`
- VPS web path:
  `/mnt/HC_Volume_105319120/www-moved/AoE2DEWarWagers/app-prodn`
- Service: `aoe2dewarwagers-web.service`
- Watcher app, protocol, release files, direct ZIP, and download metadata remain
  `AoE2DEWarWagers`/`aoe2de-watcher` specific.

## Mirrored feature delta

- War Trophy command system, public trophy metadata, tribute queueing, tribute
  proof surfaces, and admin execution controls.
- Event Studio admin tooling and lobby event tile service/API support.
- Advanced bet book detail pages and settled-market trust pages.
- New WoloChain landing composition with live transparency, market pulse, hero,
  settlement, and wallet dashboard tiles.
- Staking activity polish, precise reward ledger handling, staker wallet copy
  controls, and admin feed-view tracking.
- Completed watcher-live outcome surfacing across lobby, live games, bets,
  profiles, and leaderboards.
- Optimized champion/player/lobby/legacy media variants and cache headers for
  public image paths.

## Deployment requirements

- Run `npx prisma migrate deploy` before building/restarting the web service.
- New web migrations:
  - `20260619_210000_add_war_trophy_foundation`
  - `20260620_160000_add_event_studio`
  - `20260621_030000_use_wolomania_champ_webp`
  - `20260621_031000_use_wolomania_webp_assets`
- The trophy tribute queue can be run with
  `npm run trophy:tributes:queue` after deploy when tribute automation is ready
  to be enabled.

## Verification gate

- Web: `npx prisma generate`
- Web: `npx tsc --noEmit --pretty false`
- Web: `npm run test:mainnet-staking`
- Web: `npm run build`
- Production smoke:
  `/`, `/lobby`, `/bets`, `/bets/<settled-market>`, `/champions`,
  `/national-champions`, `/wolochain`, `/staking`, `/watch`, `/download`,
  `/api/lobby`, `/api/bets`, `/api/wolo/osmosis-pulse`,
  `/api/wolo/wallet-dashboard`, and watcher download artifact routes.

## Completion record

In progress.
