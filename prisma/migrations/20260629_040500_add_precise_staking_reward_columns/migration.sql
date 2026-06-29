-- Persist precise staking reward dust and per-user carry used by the
-- mainnet staking ledger. Existing whole-WOLO allocations are backfilled.

ALTER TABLE "staking_positions"
    ADD COLUMN IF NOT EXISTS "micro_reward_carry_uwolo" BIGINT NOT NULL DEFAULT 0;

ALTER TABLE "staking_reward_allocations"
    ADD COLUMN IF NOT EXISTS "reward_uwolo" BIGINT NOT NULL DEFAULT 0;

UPDATE "staking_reward_allocations"
SET "reward_uwolo" = "reward_wolo"::BIGINT * 1000000
WHERE "reward_uwolo" = 0
  AND "reward_wolo" > 0;
