CREATE TABLE IF NOT EXISTS emotions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    diary_entry_id UUID NOT NULL REFERENCES diary_entries(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    primary_emotion VARCHAR(30) NOT NULL,
    confidence DECIMAL(5,4) NOT NULL DEFAULT 0.0,
    secondary_emotions JSONB DEFAULT '[]',
    sentiment_score DECIMAL(5,4),
    analyzed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_emotions_user ON emotions(user_id, analyzed_at DESC);
CREATE INDEX IF NOT EXISTS idx_emotions_entry ON emotions(diary_entry_id);
