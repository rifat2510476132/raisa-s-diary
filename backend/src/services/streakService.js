import { query } from '../config/database.js';

export async function updateStreak(userId) {
  const today = new Date().toISOString().split('T')[0];
  const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0];

  const result = await query('SELECT * FROM streaks WHERE user_id = $1', [userId]);
  let streak = result.rows[0];

  if (!streak) {
    await query(
      `INSERT INTO streaks (user_id, current_streak, longest_streak, last_entry_date, total_entries)
       VALUES ($1, 1, 1, $2, 1)`,
      [userId, today]
    );
    return { current_streak: 1, longest_streak: 1, total_entries: 1, is_new: true };
  }

  let { current_streak, longest_streak, last_entry_date, total_entries } = streak;

  if (last_entry_date === today) {
    total_entries += 1;
    await query(
      `UPDATE streaks SET total_entries = $1, updated_at = NOW() WHERE user_id = $2`,
      [total_entries, userId]
    );
    return { current_streak, longest_streak, total_entries, already_wrote_today: true };
  }

  if (last_entry_date === yesterday) {
    current_streak += 1;
  } else {
    current_streak = 1;
  }

  longest_streak = Math.max(longest_streak, current_streak);
  total_entries += 1;

  await query(
    `UPDATE streaks SET current_streak = $1, longest_streak = $2,
     last_entry_date = $3, total_entries = $4, updated_at = NOW()
     WHERE user_id = $5`,
    [current_streak, longest_streak, today, total_entries, userId]
  );

  return { current_streak, longest_streak, total_entries, streak_extended: true };
}

const ACHIEVEMENTS = [
  { code: 'first_entry', title: 'First Heartbeat', minEntries: 1 },
  { code: 'streak_3', title: '3 Day Flame', minStreak: 3 },
  { code: 'streak_7', title: 'Week of Trust', minStreak: 7 },
  { code: 'streak_30', title: 'Moonlit Loyalty', minStreak: 30 },
  { code: 'entries_50', title: 'Fifty Whispers', minEntries: 50 },
];

export async function checkAchievements(userId, streakData) {
  const unlocked = [];

  for (const ach of ACHIEVEMENTS) {
    const qualifies =
      (ach.minStreak && streakData.current_streak >= ach.minStreak) ||
      (ach.minEntries && streakData.total_entries >= ach.minEntries);

    if (!qualifies) continue;

    const result = await query(
      `INSERT INTO achievements (user_id, achievement_code, title)
       VALUES ($1, $2, $3) ON CONFLICT (user_id, achievement_code) DO NOTHING
       RETURNING *`,
      [userId, ach.code, ach.title]
    );

    if (result.rows.length) {
      unlocked.push(result.rows[0]);
      await query(
        `INSERT INTO notifications (user_id, title, body, type)
         VALUES ($1, $2, $3, 'achievement')`,
        [userId, 'Achievement Unlocked! 🏆', `You earned: ${ach.title}`]
      );
    }
  }

  return unlocked;
}

export async function getStreak(userId) {
  const result = await query('SELECT * FROM streaks WHERE user_id = $1', [userId]);
  return result.rows[0] || { current_streak: 0, longest_streak: 0, total_entries: 0 };
}

export async function getAchievements(userId) {
  const result = await query(
    'SELECT * FROM achievements WHERE user_id = $1 ORDER BY unlocked_at DESC',
    [userId]
  );
  return result.rows;
}
