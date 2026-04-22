# AoE2DEWarWagers Operator Runbook

This is the DE production runbook. Do not use the older AoE2HDBets paths or service names for DE deploys.

## Production Truth

- SSH alias from the MBP: `hel1`
- DE API repo: `/mnt/HC_Volume_105319120/www-moved/AoE2DEWarWagers/api-prodn`
- DE web repo: `/mnt/HC_Volume_105319120/www-moved/AoE2DEWarWagers/app-prodn`
- DE API service: `aoe2dewarwagers-api.service`
- DE web service: `aoe2dewarwagers-web.service`
- DE API bind: `127.0.0.1:4400`
- DE web bind: `127.0.0.1:4000`
- API env file: `/etc/aoe2dewarwagers/aoe2dewarwagers-api.env`
- Web env file: `/etc/aoe2dewarwagers/aoe2dewarwagers-web.env`

## Deploy API

```bash
ssh hel1
cd /mnt/HC_Volume_105319120/www-moved/AoE2DEWarWagers/api-prodn
git status --short
git pull --ff-only origin main
venv/bin/python -m py_compile routes/replay_routes_async.py utils/replay_parser.py
sudo systemctl restart aoe2dewarwagers-api.service
systemctl is-active aoe2dewarwagers-api.service
journalctl -u aoe2dewarwagers-api.service -n 60 --no-pager
```

## Deploy Web

```bash
ssh hel1
cd /mnt/HC_Volume_105319120/www-moved/AoE2DEWarWagers/app-prodn
git status --short
git pull --ff-only origin main
npm run build
sudo systemctl restart aoe2dewarwagers-web.service
systemctl is-active aoe2dewarwagers-web.service
journalctl -u aoe2dewarwagers-web.service -n 60 --no-pager
```

## Publish Watcher Binaries

Build locally:

```bash
cd /Users/tonyblum/projects/AoE2DEWarWagers/aoe2de-watcher
rm -rf dist
npm ci
npm test
npm run dist:mac
npm run dist:manual-zip
```

Sync into the local web download rail:

```bash
cd /Users/tonyblum/projects/AoE2DEWarWagers/app-prodn
npm run watcher:sync
```

Publish to DE prod:

```bash
rsync -avh /Users/tonyblum/projects/AoE2DEWarWagers/app-prodn/public/downloads/ \
  hel1:/mnt/HC_Volume_105319120/www-moved/AoE2DEWarWagers/app-prodn/public/downloads/
```

Verify on prod:

```bash
ssh hel1
cd /mnt/HC_Volume_105319120/www-moved/AoE2DEWarWagers/app-prodn/public/downloads
ls -lh
sha256sum "AoE2DEWarWagers Watcher-1.1.1-arm64.dmg" "AoE2DEWarWagers-watcher-direct.zip"
cat latest-mac.yml
```

## Smoke SQL Setup

Use this on `hel1` to load the DE DB URL into `psql` without printing secrets:

```bash
sudo bash -lc '
set -a
. /etc/aoe2dewarwagers/aoe2dewarwagers-api.env
set +a
DB_URL="${DATABASE_URL/postgresql+asyncpg/postgresql}"
psql "$DB_URL" -P pager=off -x -c "select now();"
'
```

## Quick Final State Checks

Use this to classify the three final replay states quickly:

```bash
sudo bash -lc '
set -a
. /etc/aoe2dewarwagers/aoe2dewarwagers-api.env
set +a
DB_URL="${DATABASE_URL/postgresql+asyncpg/postgresql}"
psql "$DB_URL" -P pager=off -x -c "
select id, replay_hash, original_filename, parse_reason, winner,
       jsonb_array_length(players::jsonb) as players_count,
       key_events::jsonb->>$$player_extraction_source$$ as player_source,
       key_events::jsonb->>$$trusted_player_data$$ as trusted_player_data,
       key_events::jsonb->>$$replay_parser_trust$$ as replay_parser_trust,
       key_events::jsonb->>$$bet_arming_eligible$$ as bet_arming_eligible,
       key_events::jsonb->$$watcher_metadata$$->$$local_player$$ as local_player,
       key_events::jsonb->$$watcher_metadata$$->$$game_version$$ as watcher_game_version
from game_stats
where is_final = true
order by coalesce(played_on, timestamp, created_at) desc
limit 20;
"
'
```

Interpretation:

- `watcher_final_unparsed`: parser-blind final with no useful watcher enrichment. Expect `winner = Unknown`, `players_count = 0`, `player_source = no_players`, and no linked bet market.
- `watcher_final_metadata`: parser-blind final enriched by watcher runtime context. Expect `watcher_metadata.local_player` and/or `watcher_metadata.game_version`, `replay_parser_trust = false`, and `bet_arming_eligible = false`.
- Parser-trusted final: any final row with parser-trusted player data. Expect `parse_reason` outside `watcher_final_unparsed` / `watcher_final_metadata`, `players_count >= 2`, `player_source` not `no_players`, and `replay_parser_trust` not `false`.

API shortcut for a known hash:

```bash
python3 - <<'PY'
import json
import subprocess

hash_value = "REPLAY_HASH"
data = json.loads(subprocess.check_output(
    ["curl", "-fsS", "https://api-prodn.aoe2dewarwagers.com/api/game_stats"],
    text=True,
))
row = next((item for item in data if item.get("replay_hash") == hash_value), None)
events = (row or {}).get("key_events") or {}
metadata = events.get("watcher_metadata") or {}
print({
    "found": bool(row),
    "id": row and row.get("id"),
    "parse_reason": row and row.get("parse_reason"),
    "players_count": len(row.get("players") if isinstance(row.get("players"), list) else []),
    "player_source": events.get("player_extraction_source"),
    "replay_parser_trust": events.get("replay_parser_trust"),
    "bet_arming_eligible": events.get("bet_arming_eligible"),
    "local_player": metadata.get("local_player"),
    "watcher_game_version": metadata.get("game_version"),
})
PY
```

## Smoke: Unparsed Final Persistence

Reference live sample as of April 22, 2026:

- `game_stats.id = 14`
- `replay_hash = 2321363894f0a4f1d88875509859303cf48e649fe21b0cca9ca20d083b19b1cf`
- `parse_reason = watcher_final_unparsed`

SQL check:

```bash
sudo bash -lc '
set -a
. /etc/aoe2dewarwagers/aoe2dewarwagers-api.env
set +a
DB_URL="${DATABASE_URL/postgresql+asyncpg/postgresql}"
psql "$DB_URL" -P pager=off -x -c "
select id, replay_hash, original_filename, user_uid, parse_source, parse_reason,
       is_final, winner, jsonb_array_length(players::jsonb) as players_count,
       key_events::jsonb->>$$player_extraction_source$$ as player_source,
       left(key_events::jsonb->>$$player_extraction_error$$, 180) as player_error,
       key_events::jsonb->>$$trusted_player_data$$ as trusted_player_data,
       key_events::jsonb->>$$final_unparsed$$ as final_unparsed
from game_stats
where replay_hash = $$2321363894f0a4f1d88875509859303cf48e649fe21b0cca9ca20d083b19b1cf$$
  and is_final = true;
"
'
```

Expected:

- `parse_reason = watcher_final_unparsed`
- `winner = Unknown`
- `players_count = 0`
- `player_source = no_players`
- `trusted_player_data = false`
- `final_unparsed = true`

## Smoke: Feed Visibility

```bash
python3 - <<'PY'
import json
import subprocess

hash_value = "2321363894f0a4f1d88875509859303cf48e649fe21b0cca9ca20d083b19b1cf"
checks = [
    ("api_game_stats", "https://api-prodn.aoe2dewarwagers.com/api/game_stats", lambda data: data),
    ("web_game_stats", "https://aoe2dewarwagers.com/api/game_stats", lambda data: data),
    ("web_lobby_recentMatches", "https://aoe2dewarwagers.com/api/lobby", lambda data: data.get("recentMatches", [])),
]

for label, url, extractor in checks:
    data = json.loads(subprocess.check_output(["curl", "-fsS", url], text=True))
    match = next((row for row in extractor(data) if row.get("replay_hash") == hash_value), None)
    print(label, "FOUND" if match else "MISSING", match and {
        "id": match.get("id"),
        "parse_reason": match.get("parse_reason"),
        "winner": match.get("winner"),
        "players_count": len(match.get("players") if isinstance(match.get("players"), list) else []),
        "player_source": (match.get("key_events") or {}).get("player_extraction_source"),
    })
PY
```

Expected: all three checks print `FOUND`.

## Smoke: Does Not Arm Bets

```bash
curl -fsS https://aoe2dewarwagers.com/api/bets | python3 -m json.tool >/tmp/de-bets.json

sudo bash -lc '
set -a
. /etc/aoe2dewarwagers/aoe2dewarwagers-api.env
set +a
DB_URL="${DATABASE_URL/postgresql+asyncpg/postgresql}"
psql "$DB_URL" -P pager=off -x -c "
select count(*) as linked_market_count
from bet_markets
where linked_game_stats_id = 14;
"
'
```

Expected: `linked_market_count = 0`.

## Smoke: Same-Hash Trusted Upgrade Path

Use a throwaway replay hash for this test. The expected behavior is:

1. Final upload initially stores a row as `watcher_final_unparsed`.
2. A later final upload for the same `replay_hash` with trusted player data refreshes that same final row.
3. The latest `replay_parse_attempts.status` becomes `duplicate_final_refreshed`.
4. The final row no longer has `parse_reason = watcher_final_unparsed`; it has trusted players and winner metadata.
5. Delete the throwaway row afterward if it used synthetic trusted data.

SQL verification shape:

```sql
select id, replay_hash, original_filename, parse_reason, is_final, winner,
       jsonb_array_length(players::jsonb) as players_count,
       key_events::jsonb->>$$player_extraction_source$$ as player_source,
       key_events::jsonb->>$$trusted_player_data$$ as trusted_player_data,
       key_events::jsonb->>$$postgame_available$$ as postgame_available
from game_stats
where replay_hash = $$THROWAWAY_HASH$$ and is_final = true;

select status, detail, game_stats_id
from replay_parse_attempts
where replay_hash = $$THROWAWAY_HASH$$
order by id desc
limit 3;
```

Cleanup shape:

```sql
delete from replay_parse_attempts where replay_hash = $$THROWAWAY_HASH$$;
delete from game_stats where replay_hash = $$THROWAWAY_HASH$$;
```

## Parse Reason Meanings

- `watcher_live_iteration`: A watcher live/non-final upload parsed successfully enough to store a live iteration. This can power live-session surfaces and may later be superseded by a final upload.
- `watcher_live_pending_parse`: A watcher live/non-final upload arrived before the replay was parseable. The API stores a placeholder live row instead of dropping the event, preserving the active session shell until a later live parse can replace it.
- `watcher_final_unparsed`: A watcher final upload was received and stored, but DE replay parsing did not produce trusted player data, a winner, or reliable completion evidence. The row should appear in match feeds as an unparsed final, but it must not arm betting markets until a later trusted parse refreshes the same final row.
