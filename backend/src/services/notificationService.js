import { query } from '../config/database.js';

const TAHSIN_MESSAGES = [
  { title: 'Tahsin misses you 💌', body: 'Come write your feelings today, Raisa.' },
  { title: 'Write your heart 📔', body: 'Today deserves a page in your diary.' },
  { title: 'Did you eat? 🍽️', body: 'Tahsin worries when you forget to take care of yourself.' },
  { title: 'Gentle reminder 🌸', body: 'How are you feeling right now?' },
  { title: 'Streak waiting 🔥', body: "Don't break your writing streak — I'm proud of you." },
  { title: 'Good night soon 🌙', body: 'Pour your thoughts before sleep. I\'m here.' },
];

export async function getNotifications(userId, { unreadOnly = false, limit = 50 } = {}) {
  let sql = `SELECT * FROM notifications WHERE user_id = $1`;
  const params = [userId];

  if (unreadOnly) sql += ` AND is_read = FALSE`;
  sql += ` ORDER BY created_at DESC LIMIT $2`;
  params.push(limit);

  const result = await query(sql, params);
  return result.rows;
}

export async function markRead(userId, notificationId) {
  await query(
    `UPDATE notifications SET is_read = TRUE
     WHERE id = $1 AND user_id = $2`,
    [notificationId, userId]
  );
  return { success: true };
}

export async function markAllRead(userId) {
  await query(
    `UPDATE notifications SET is_read = TRUE WHERE user_id = $1`,
    [userId]
  );
  return { success: true };
}

export async function createNotification(userId, { title, body, type = 'reminder' }) {
  const result = await query(
    `INSERT INTO notifications (user_id, title, body, type, sent_at)
     VALUES ($1, $2, $3, $4, NOW()) RETURNING *`,
    [userId, title, body, type]
  );
  return result.rows[0];
}

export async function scheduleDailyReminders() {
  const users = await query(
    `SELECT u.id, s.daily_reminder_time, s.notifications_enabled
     FROM users u
     JOIN settings s ON s.user_id = u.id
     WHERE s.notifications_enabled = TRUE`
  );

  for (const user of users.rows) {
    const msg = TAHSIN_MESSAGES[Math.floor(Math.random() * TAHSIN_MESSAGES.length)];
    await createNotification(user.id, msg);
  }

  return { sent: users.rows.length };
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
