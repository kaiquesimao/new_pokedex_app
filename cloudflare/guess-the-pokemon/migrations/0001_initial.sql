PRAGMA foreign_keys = ON;

CREATE TABLE public_players (
  user_id TEXT PRIMARY KEY,
  display_name TEXT,
  avatar_url TEXT,
  is_anonymous INTEGER NOT NULL DEFAULT 0 CHECK (is_anonymous IN (0, 1)),
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

CREATE TABLE game_sessions (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  current_target_id INTEGER NOT NULL CHECK (current_target_id > 0),
  last_answer_was_correct INTEGER NOT NULL DEFAULT 0 CHECK (last_answer_was_correct IN (0, 1)),
  state TEXT NOT NULL DEFAULT 'active' CHECK (state IN ('active', 'completed', 'expired')),
  score INTEGER NOT NULL DEFAULT 0 CHECK (score >= 0),
  current_round INTEGER NOT NULL DEFAULT 0 CHECK (current_round >= 0),
  started_at TEXT NOT NULL,
  expires_at TEXT NOT NULL,
  completed_at TEXT,
  FOREIGN KEY (user_id) REFERENCES public_players(user_id)
);

CREATE TABLE accepted_results (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  session_id TEXT NOT NULL UNIQUE,
  score INTEGER NOT NULL CHECK (score >= 0),
  achieved_at TEXT NOT NULL,
  created_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES public_players(user_id),
  FOREIGN KEY (session_id) REFERENCES game_sessions(id)
);

CREATE TABLE weekly_records (
  user_id TEXT NOT NULL,
  week_key TEXT NOT NULL,
  score INTEGER NOT NULL CHECK (score >= 0),
  achieved_at TEXT NOT NULL,
  accepted_result_id TEXT NOT NULL,
  PRIMARY KEY (user_id, week_key),
  FOREIGN KEY (user_id) REFERENCES public_players(user_id),
  FOREIGN KEY (accepted_result_id) REFERENCES accepted_results(id)
);

CREATE TABLE global_records (
  user_id TEXT PRIMARY KEY,
  score INTEGER NOT NULL CHECK (score >= 0),
  achieved_at TEXT NOT NULL,
  accepted_result_id TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES public_players(user_id),
  FOREIGN KEY (accepted_result_id) REFERENCES accepted_results(id)
);

CREATE INDEX weekly_records_order_idx ON weekly_records (week_key, score DESC, achieved_at ASC, user_id ASC);
CREATE INDEX global_records_order_idx ON global_records (score DESC, achieved_at ASC, user_id ASC);
