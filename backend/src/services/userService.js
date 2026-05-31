import { query } from '../config/database.js';
import { AppError } from '../utils/errors.js';
import * as authService from './authService.js';

export async function getUserById(userId) {
  return authService.getProfile(userId);
}

export async function updateProfile(userId, { displayName, avatarUrl }) {
  const fields = [];
  const values = [];
  let i = 1;

  if (displayName !== undefined) {
    fields.push(`display_name = $${i++}`);
    values.push(displayName.trim().slice(0, 100));
  }
  if (avatarUrl !== undefined) {
    fields.push(`avatar_url = $${i++}`);
    values.push(avatarUrl);
  }

  if (fields.length === 0) {
    throw new AppError('No fields to update', 400, 'VALIDATION');
  }

  values.push(userId);
  await query(
    `UPDATE users SET ${fields.join(', ')}, updated_at = NOW() WHERE id = $${i}`,
    values
  );

  return getUserById(userId);
}

export async function updateRelationshipLevel(userId) {
  const result = await query(
    `SELECT COUNT(*)::int AS entries FROM diary_entries WHERE user_id = $1`,
    [userId]
  );
  const entries = result.rows[0].entries;
  let level = 1;
  if (entries >= 50) level = 5;
  else if (entries >= 30) level = 4;
  else if (entries >= 15) level = 3;
  else if (entries >= 5) level = 2;

  await query('UPDATE users SET relationship_level = $1 WHERE id = $2', [level, userId]);
  return level;
}

export async function registerDeviceToken(userId, token, platform = 'android') {
  await query(
    `INSERT INTO device_tokens (user_id, token, platform)
     VALUES ($1, $2, $3)
     ON CONFLICT (user_id, token) DO NOTHING`,
    [userId, token, platform]
  );
  return { registered: true };
}
