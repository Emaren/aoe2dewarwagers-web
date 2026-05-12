/*
  Warnings:

  - You are about to alter the column `label` on the `tournament_matches` table. The data in that column could be lost. The data in that column will be cast from `Text` to `VarChar(80)`.
  - You are about to alter the column `status` on the `tournament_matches` table. The data in that column could be lost. The data in that column will be cast from `Text` to `VarChar(20)`.
  - A unique constraint covering the columns `[shared_lobby_message_id]` on the table `direct_messages` will be added. If there are existing duplicate values, this will fail.

*/
-- DropForeignKey
ALTER TABLE "tournament_matches" DROP CONSTRAINT IF EXISTS "tournament_matches_player_one_entry_id_fkey";

-- DropForeignKey
ALTER TABLE "tournament_matches" DROP CONSTRAINT IF EXISTS "tournament_matches_player_two_entry_id_fkey";

-- DropForeignKey
ALTER TABLE "tournament_matches" DROP CONSTRAINT IF EXISTS "tournament_matches_source_game_stats_id_fkey";

-- DropForeignKey
ALTER TABLE "tournament_matches" DROP CONSTRAINT IF EXISTS "tournament_matches_tournament_id_fkey";

-- DropForeignKey
ALTER TABLE "tournament_matches" DROP CONSTRAINT IF EXISTS "tournament_matches_winner_entry_id_fkey";

-- DropIndex
DROP INDEX IF EXISTS "uq_direct_messages_shared_lobby_message_id";

-- DropIndex
DROP INDEX IF EXISTS "ix_user_activity_events_type_created_at";

-- DropIndex
DROP INDEX IF EXISTS "ix_user_activity_events_user_created_at";

-- AlterTable
ALTER TABLE "bet_markets" ALTER COLUMN "updated_at" DROP DEFAULT;

-- AlterTable
ALTER TABLE "bet_wagers" ALTER COLUMN "updated_at" DROP DEFAULT;

-- AlterTable
ALTER TABLE "community_request_comments" ALTER COLUMN "updated_at" DROP DEFAULT;

-- AlterTable
ALTER TABLE "community_request_votes" ALTER COLUMN "updated_at" DROP DEFAULT;

-- AlterTable
ALTER TABLE "community_requests" ALTER COLUMN "updated_at" DROP DEFAULT;

-- AlterTable
ALTER TABLE "direct_conversations" ALTER COLUMN "updated_at" DROP DEFAULT;

-- AlterTable
ALTER TABLE "scheduled_matches" ALTER COLUMN "updated_at" DROP DEFAULT;

-- AlterTable
ALTER TABLE "tournament_matches" ALTER COLUMN "round" SET DEFAULT 1,
ALTER COLUMN "position" SET DEFAULT 1,
ALTER COLUMN "label" SET DATA TYPE VARCHAR(80),
ALTER COLUMN "status" SET DATA TYPE VARCHAR(20),
ALTER COLUMN "scheduled_at" SET DATA TYPE TIMESTAMP(6),
ALTER COLUMN "completed_at" SET DATA TYPE TIMESTAMP(6),
ALTER COLUMN "created_at" SET DATA TYPE TIMESTAMP(6),
ALTER COLUMN "updated_at" DROP DEFAULT,
ALTER COLUMN "updated_at" SET DATA TYPE TIMESTAMP(6);

-- AlterTable
ALTER TABLE "user_appearance_preferences" ALTER COLUMN "updated_at" DROP DEFAULT;

-- CreateIndex
CREATE UNIQUE INDEX IF NOT EXISTS "uq_direct_messages_shared_lobby_message_id" ON "direct_messages"("shared_lobby_message_id");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "ix_user_activity_events_user_created_at" ON "user_activity_events"("user_id", "created_at");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "ix_user_activity_events_type_created_at" ON "user_activity_events"("type", "created_at");

-- RenameForeignKey
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = '"direct_messages"'::regclass
      AND conname = 'fk_direct_messages_shared_lobby_message_id'
  ) THEN
    ALTER TABLE "direct_messages" RENAME CONSTRAINT "fk_direct_messages_shared_lobby_message_id" TO "direct_messages_shared_lobby_message_id_fkey";
  ELSIF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = '"direct_messages"'::regclass
      AND conname = 'direct_messages_shared_lobby_message_id_fkey'
  ) THEN
    ALTER TABLE "direct_messages" ADD CONSTRAINT "direct_messages_shared_lobby_message_id_fkey" FOREIGN KEY ("shared_lobby_message_id") REFERENCES "chat_messages"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
  END IF;
END $$;

-- RenameForeignKey
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = '"user_activity_events"'::regclass
      AND conname = 'fk_user_activity_events_user_id'
  ) THEN
    ALTER TABLE "user_activity_events" RENAME CONSTRAINT "fk_user_activity_events_user_id" TO "user_activity_events_user_id_fkey";
  ELSIF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = '"user_activity_events"'::regclass
      AND conname = 'user_activity_events_user_id_fkey'
  ) THEN
    ALTER TABLE "user_activity_events" ADD CONSTRAINT "user_activity_events_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
  END IF;
END $$;

-- RenameForeignKey
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = '"user_appearance_preferences"'::regclass
      AND conname = 'fk_user_appearance_preferences_user_id'
  ) THEN
    ALTER TABLE "user_appearance_preferences" RENAME CONSTRAINT "fk_user_appearance_preferences_user_id" TO "user_appearance_preferences_user_id_fkey";
  ELSIF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = '"user_appearance_preferences"'::regclass
      AND conname = 'user_appearance_preferences_user_id_fkey'
  ) THEN
    ALTER TABLE "user_appearance_preferences" ADD CONSTRAINT "user_appearance_preferences_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
  END IF;
END $$;

-- AddForeignKey
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = '"tournament_matches"'::regclass
      AND conname = 'tournament_matches_tournament_id_fkey'
  ) THEN
    ALTER TABLE "tournament_matches" ADD CONSTRAINT "tournament_matches_tournament_id_fkey" FOREIGN KEY ("tournament_id") REFERENCES "tournaments"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
  END IF;
END $$;

-- AddForeignKey
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = '"tournament_matches"'::regclass
      AND conname = 'tournament_matches_source_game_stats_id_fkey'
  ) THEN
    ALTER TABLE "tournament_matches" ADD CONSTRAINT "tournament_matches_source_game_stats_id_fkey" FOREIGN KEY ("source_game_stats_id") REFERENCES "game_stats"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
  END IF;
END $$;

-- AddForeignKey
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = '"tournament_matches"'::regclass
      AND conname = 'tournament_matches_player_one_entry_id_fkey'
  ) THEN
    ALTER TABLE "tournament_matches" ADD CONSTRAINT "tournament_matches_player_one_entry_id_fkey" FOREIGN KEY ("player_one_entry_id") REFERENCES "tournament_entries"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
  END IF;
END $$;

-- AddForeignKey
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = '"tournament_matches"'::regclass
      AND conname = 'tournament_matches_player_two_entry_id_fkey'
  ) THEN
    ALTER TABLE "tournament_matches" ADD CONSTRAINT "tournament_matches_player_two_entry_id_fkey" FOREIGN KEY ("player_two_entry_id") REFERENCES "tournament_entries"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
  END IF;
END $$;

-- AddForeignKey
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = '"tournament_matches"'::regclass
      AND conname = 'tournament_matches_winner_entry_id_fkey'
  ) THEN
    ALTER TABLE "tournament_matches" ADD CONSTRAINT "tournament_matches_winner_entry_id_fkey" FOREIGN KEY ("winner_entry_id") REFERENCES "tournament_entries"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
  END IF;
END $$;
