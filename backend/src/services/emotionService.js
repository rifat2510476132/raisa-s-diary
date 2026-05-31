import { query } from '../config/database.js';
import * as diaryService from './diaryService.js';

export async function getStats(userId, days = 30) {
  return diaryService.getEmotionStats(userId, days);
}

export async function getRecentEmotions(userId, limit = 20) {
  const result = await query(
    `SELECT e.id, e.primary_emotion, e.confidence, e.sentiment_score, e.analyzed_at,
            de.id AS diary_entry_id, de.title, de.created_at AS entry_created_at
     FROM emotions e
     JOIN diary_entries de ON de.id = e.diary_entry_id
     WHERE e.user_id = $1
     ORDER BY e.analyzed_at DESC
     LIMIT $2`,
    [userId, limit]
  );
  return result.rows;
}

export async function getEmotionByEntry(userId, entryId) {
  const result = await query(
    `SELECT e.* FROM emotions e
     JOIN diary_entries de ON de.id = e.diary_entry_id
     WHERE e.diary_entry_id = $1 AND de.user_id = $2`,
    [entryId, userId]
  );
  if (!result.rows.length) return null;
  return result.rows[0];
}
