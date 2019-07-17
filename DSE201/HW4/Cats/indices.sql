CREATE INDEX idx_likes ON likes (user_id, video_id);
CREATE INDEX idx_friend ON friend (user_id);
CREATE INDEX idx_watch ON watch (user_id);

-- Index on precomputed table
CREATE INDEX idx_comman_likes_count_table on comman_likes_count_table(main_user);