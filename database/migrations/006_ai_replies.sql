CREATE TABLE IF NOT EXISTS ai_replies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    diary_entry_id UUID NOT NULL REFERENCES diary_entries(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reply_text TEXT NOT NULL,
    reply_type VARCHAR(30) NOT NULL DEFAULT 'supportive',
    voice_url TEXT,
    tokens_used INTEGER DEFAULT 0,
    model VARCHAR(50) DEFAULT 'gpt-4o-mini',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ai_replies_entry ON ai_replies(diary_entry_id);
