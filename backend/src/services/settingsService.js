import bcrypt from 'bcryptjs';
import { query } from '../config/database.js';

export async function getSettings(userId) {
  const result = await query('SELECT * FROM settings WHERE user_id = $1', [userId]);
  return result.rows[0];
}

export async function updateSettings(userId, updates) {
  const allowed = [
    'theme', 'font_family', 'ai_intensity', 'notifications_enabled',
    'daily_reminder_time', 'music_enabled', 'haptic_enabled',
    'biometric_enabled', 'language',
  ];

  const sets = [];
  const values = [];
  let i = 1;

  for (const key of allowed) {
    if (updates[key] !== undefined) {
      sets.push(`${key} = $${i++}`);
      values.push(updates[key]);
    }
  }

  if (!sets.length) return getSettings(userId);

  values.push(userId);
  const result = await query(
    `UPDATE settings SET ${sets.join(', ')}, updated_at = NOW()
     WHERE user_id = $${i} RETURNING *`,
    values
  );

  return result.rows[0];
}

export async function setPin(userId, pin) {
  const hash = await bcrypt.hash(pin, 10);
  await query('UPDATE settings SET pin_hash = $1 WHERE user_id = $2', [hash, userId]);
  return { pinSet: true };
}

export async function verifyPin(userId, pin) {
  const result = await query('SELECT pin_hash FROM settings WHERE user_id = $1', [userId]);
  const hash = result.rows[0]?.pin_hash;
  if (!hash) return { valid: true, noPin: true };
  const valid = await bcrypt.compare(pin, hash);
  return { valid };
}

export async function removePin(userId) {
  await query('UPDATE settings SET pin_hash = NULL WHERE user_id = $1', [userId]);
  return { pinRemoved: true };
}
