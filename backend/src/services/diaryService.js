import { query } from '../config/database.js';
import { AppError } from '../utils/errors.js';
import * as tahsinAI from './tahsinAIService.js';
import * as streakService from './streakService.js';

export async function createEntry(userId, { title, content, moodSticker, mediaIds = [] }) {
  const wordCount = content.trim().split(/\s+/).filter(Boolean).length;

  const settings = await query(
    'SELECT ai_intensity FROM settings WHERE user_id = $1',
    [userId]
  );
  const aiIntensity = settings.rows[0]?.ai_intensity ?? 80;

  const profile = await query('SELECT display_name FROM users WHERE id = $1', [userId]);
  const displayName = profile.rows[0]?.display_name || 'Raisa';

  const entryResult = await query(
    `INSERT INTO diary_entries (user_id, title, content, mood_sticker, word_count)
     VALUES ($1, $2, $3, $4, $5) RETURNING *`,
    [userId, title || null, content, moodSticker || null, wordCount]
  );

  const entry = entryResult.rows[0];

  const emotion = await tahsinAI.analyzeEmotion(content);

  await query(
    `INSERT INTO emotions (diary_entry_id, user_id, primary_emotion, confidence, secondary_emotions, sentiment_score)
     VALUES ($1, $2, $3, $4, $5, $6)`,
    [
      entry.id,
      userId,
      emotion.primary_emotion,
      emotion.confidence,
      JSON.stringify(emotion.secondary_emotions || []),
      emotion.sentiment_score,
    ]
  );

  const tahsinReply = await tahsinAI.generateTahsinReply({
    userId,
    displayName,
    diaryContent: content,
    emotion,
    aiIntensity,
  });

  const replyResult = await query(
    `INSERT INTO ai_replies (diary_entry_id, user_id, reply_text, reply_type, tokens_used, model)
     VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
    [
      entry.id,
      userId,
      tahsinReply.replyText,
      tahsinReply.replyType,
      tahsinReply.tokensUsed,
      process.env.OPENAI_MODEL || 'gpt-4o-mini',
    ]
  );

  if (mediaIds.length) {
    await query(
      `UPDATE media_files SET diary_entry_id = $1
       WHERE id = ANY($2::uuid[]) AND user_id = $3`,
      [entry.id, mediaIds, userId]
    );
  }

  await updateMoodCalendar(userId, emotion);
  const streak = await streakService.updateStreak(userId);
  await streakService.checkAchievements(userId, streak);

  const relationshipBump = emotion.primary_emotion === 'motivated' ? 1 : 0;
  if (relationshipBump) {
    await query(
      `UPDATE users SET relationship_level = LEAST(relationship_level + 1, 100) WHERE id = $1`,
      [userId]
    );
  }

  return {
    entry,
    emotion,
    tahsinReply: replyResult.rows[0],
    streak,
  };
}

async function updateMoodCalendar(userId, emotion) {
  const today = new Date().toISOString().split('T')[0];
  await query(
    `INSERT INTO mood_calendar (user_id, mood_date, dominant_emotion, entry_count, mood_score)
     VALUES ($1, $2, $3, 1, $4)
     ON CONFLICT (user_id, mood_date)
     DO UPDATE SET
       entry_count = mood_calendar.entry_count + 1,
       dominant_emotion = $3,
       mood_score = (COALESCE(mood_calendar.mood_score, 0) + $4) / 2`,
    [userId, today, emotion.primary_emotion, emotion.sentiment_score || 0]
  );
}

export async function getEntries(userId, { page = 1, limit = 20 } = {}) {
  const offset = (page - 1) * limit;
  const result = await query(
    `SELECT de.*, e.primary_emotion, e.confidence, e.sentiment_score,
            ar.reply_text, ar.reply_type, ar.created_at as reply_at
     FROM diary_entries de
     LEFT JOIN emotions e ON e.diary_entry_id = de.id
     LEFT JOIN ai_replies ar ON ar.diary_entry_id = de.id
     WHERE de.user_id = $1
     ORDER BY de.created_at DESC
     LIMIT $2 OFFSET $3`,
    [userId, limit, offset]
  );

  const countResult = await query(
    'SELECT COUNT(*) FROM diary_entries WHERE user_id = $1',
    [userId]
  );

  return {
    entries: result.rows,
    total: parseInt(countResult.rows[0].count, 10),
    page,
    limit,
  };
}

export async function getEntry(userId, entryId) {
  const result = await query(
    `SELECT de.*, e.primary_emotion, e.confidence, e.secondary_emotions, e.sentiment_score,
            ar.id as reply_id, ar.reply_text, ar.reply_type, ar.voice_url
     FROM diary_entries de
     LEFT JOIN emotions e ON e.diary_entry_id = de.id
     LEFT JOIN ai_replies ar ON ar.diary_entry_id = de.id
     WHERE de.id = $1 AND de.user_id = $2`,
    [entryId, userId]
  );

  if (!result.rows.length) {
    throw new AppError('Diary entry not found', 404, 'NOT_FOUND');
  }

  const media = await query(
    'SELECT * FROM media_files WHERE diary_entry_id = $1',
    [entryId]
  );

  return { ...result.rows[0], media: media.rows };
}

export async function deleteEntry(userId, entryId) {
  const result = await query(
    'DELETE FROM diary_entries WHERE id = $1 AND user_id = $2 RETURNING id',
    [entryId, userId]
  );
  if (!result.rows.length) {
    throw new AppError('Diary entry not found', 404, 'NOT_FOUND');
  }
  return { deleted: true };
}

export async function getEmotionStats(userId, days = 30) {
  const safeDays = Math.min(Math.max(parseInt(days, 10) || 30, 1), 365);

  const result = await query(
    `SELECT primary_emotion, COUNT(*) as count,
            AVG(confidence) as avg_confidence,
            AVG(sentiment_score) as avg_sentiment,
            DATE(analyzed_at) as date
     FROM emotions
     WHERE user_id = $1 AND analyzed_at >= NOW() - make_interval(days => $2)
     GROUP BY primary_emotion, DATE(analyzed_at)
     ORDER BY date DESC`,
    [userId, safeDays]
  );

  const summary = await query(
    `SELECT primary_emotion, COUNT(*) as count
     FROM emotions WHERE user_id = $1
     AND analyzed_at >= NOW() - make_interval(days => $2)
     GROUP BY primary_emotion`,
    [userId, safeDays]
  );

  return { timeline: result.rows, summary: summary.rows };
}

export async function getMoodCalendar(userId, year, month) {
  const result = await query(
    `SELECT mood_date, dominant_emotion, entry_count, mood_score
     FROM mood_calendar
     WHERE user_id = $1
     AND EXTRACT(YEAR FROM mood_date) = $2
     AND EXTRACT(MONTH FROM mood_date) = $3`,
    [userId, year, month]
  );
  return result.rows;
}
