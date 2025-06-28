-- PostgreSQL schema for Tic Tac Toe Game Database
-- This schema defines tables: users, games, moves, leaderboard, with all necessary constraints.

-- USERS TABLE
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(32) NOT NULL UNIQUE,
    email VARCHAR(128) NOT NULL UNIQUE,
    password_hash VARCHAR(128) NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

-- GAMES TABLE
CREATE TABLE IF NOT EXISTS games (
    id SERIAL PRIMARY KEY,
    player_x INTEGER NOT NULL,
    player_o INTEGER NOT NULL,
    start_time TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    end_time TIMESTAMP WITHOUT TIME ZONE,
    status VARCHAR(20) NOT NULL CHECK (status IN ('active', 'completed', 'abandoned')),
    winner INTEGER, -- Can be NULL (draw or ongoing); references users(id)
    FOREIGN KEY (player_x) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (player_o) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (winner) REFERENCES users(id)
);

-- MOVES TABLE
CREATE TABLE IF NOT EXISTS moves (
    id SERIAL PRIMARY KEY,
    game_id INTEGER NOT NULL,
    player_id INTEGER NOT NULL,
    move_number INTEGER NOT NULL,
    x INTEGER NOT NULL CHECK (x >= 0 AND x <= 2),
    y INTEGER NOT NULL CHECK (y >= 0 AND y <= 2),
    timestamp TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE,
    FOREIGN KEY (player_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE (game_id, move_number), -- Enforces move order
    UNIQUE (game_id, x, y)         -- Only one move per cell per game
);

-- LEADERBOARD TABLE
-- This could also be computed dynamically, but for efficient querying we maintain it
CREATE TABLE IF NOT EXISTS leaderboard (
    player_id INTEGER PRIMARY KEY,
    wins INTEGER NOT NULL DEFAULT 0,
    losses INTEGER NOT NULL DEFAULT 0,
    draws INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (player_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Index for efficient leaderboard lookup by wins
CREATE INDEX IF NOT EXISTS idx_leaderboard_wins ON leaderboard (wins DESC);

-- Ensure combination of users in games is not duplicated (optional)
CREATE UNIQUE INDEX IF NOT EXISTS idx_games_unique_players ON games
    (player_x, player_o, start_time);

-- (Optional) Additional constraints such as banning duplicate usernames/emails
-- are already handled by unique constraints in "users" table.

-- End of Tic Tac Toe schema
