CREATE TABLE "game_watch_streams" (
  "id" SERIAL NOT NULL,
  "session_key" VARCHAR(255) NOT NULL,
  "provider" VARCHAR(24) NOT NULL,
  "role" VARCHAR(24) NOT NULL,
  "label" VARCHAR(80) NOT NULL,
  "url" VARCHAR(500) NOT NULL,
  "embed_id" VARCHAR(255),
  "player_label" VARCHAR(80),
  "is_primary" BOOLEAN NOT NULL DEFAULT false,
  "status" VARCHAR(24) NOT NULL DEFAULT 'live',
  "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP(6) NOT NULL,

  CONSTRAINT "game_watch_streams_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "ix_game_watch_streams_session_primary"
  ON "game_watch_streams"("session_key", "is_primary");

CREATE INDEX "ix_game_watch_streams_session_status"
  ON "game_watch_streams"("session_key", "status");

CREATE INDEX "ix_game_watch_streams_provider"
  ON "game_watch_streams"("provider");
