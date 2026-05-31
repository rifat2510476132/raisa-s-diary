CREATE TABLE IF NOT EXISTS media_files (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    diary_entry_id UUID REFERENCES diary_entries(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    media_type VARCHAR(20) NOT NULL CHECK (media_type IN ('photo', 'video', 'voice', 'sticker')),
    url TEXT NOT NULL,
    public_id VARCHAR(255),
    duration_seconds INTEGER,
    file_size_bytes BIGINT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_media_entry ON media_files(diary_entry_id);

CREATE TABLE IF NOT EXISTS mood_calendar (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    mood_date DATE NOT NULL,
    dominant_emotion VARCHAR(30),
    entry_count INTEGER NOT NULL DEFAULT 0,
    mood_score DECIMAL(5,2),
    UNIQUE(user_id, mood_date)
);

CREATE INDEX IF NOT EXISTS idx_mood_calendar_user ON mood_calendar(user_id, mood_date DESC);
