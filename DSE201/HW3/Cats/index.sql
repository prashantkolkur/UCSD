CREATE INDEX idx_likes ON likes (user_id, video_id);

CREATE INDEX idx_friend ON friend (user_id);

CREATE INDEX idx_watch ON watch (user_id);
