CREATE TABLE IF NOT EXISTS settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    theme VARCHAR(20) NOT NULL DEFAULT 'system',
    font_family VARCHAR(50) NOT NULL DEFAULT 'Poppins',
    ai_intensity INTEGER NOT NULL DEFAULT 80 CHECK (ai_intensity BETWEEN 0 AND 100),
    notifications_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    daily_reminder_time TIME DEFAULT '20:00:00',
    music_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    haptic_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    pin_hash VARCHAR(255),
    biometric_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    e2e_encryption_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    language VARCHAR(10) NOT NULL DEFAULT 'en',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
