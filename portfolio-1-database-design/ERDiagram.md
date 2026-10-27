// Database Schema: portfolio

Table player {
  player_id bigint [pk]
  handle text [unique]
  joined_at timestamptz
}

Table game {
  game_id bigint [pk]
  title text
  release_date date
  is_active boolean
}

Table score_entry {
  score_entry_id bigint [pk]
  player_id bigint
  game_id bigint
  score integer
  achieved_at timestamptz
  is_current boolean
}

// Relationships (Foreign Keys)
Ref: player.player_id < score_entry.player_id
Ref: game.game_id < score_entry.game_id
