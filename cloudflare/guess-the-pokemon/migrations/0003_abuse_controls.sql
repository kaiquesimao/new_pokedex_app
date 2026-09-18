ALTER TABLE game_sessions ADD COLUMN publish_count INTEGER NOT NULL DEFAULT 0 CHECK (publish_count >= 0);

CREATE TABLE rate_limit_buckets (
  bucket_key TEXT NOT NULL,
  window_start INTEGER NOT NULL,
  request_count INTEGER NOT NULL CHECK (request_count > 0),
  PRIMARY KEY (bucket_key, window_start)
);

CREATE INDEX rate_limit_buckets_expiry_idx ON rate_limit_buckets (window_start);

CREATE TABLE active_session_slots (
  user_id TEXT NOT NULL,
  slot INTEGER NOT NULL CHECK (slot >= 0),
  session_id TEXT NOT NULL UNIQUE,
  PRIMARY KEY (user_id, slot)
);

INSERT INTO active_session_slots (user_id, slot, session_id)
SELECT user_id, slot - 1, id
FROM (
  SELECT id, user_id,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY started_at, id) AS slot
  FROM game_sessions
  WHERE state = 'active'
)
WHERE slot <= 10;
