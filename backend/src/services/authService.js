import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import crypto from 'crypto';
import { query } from '../config/database.js';
import { config } from '../config/index.js';
import { AppError } from '../utils/errors.js';

const SALT_ROUNDS = 12;

function signAccessToken(user) {
  return jwt.sign({ email: user.email }, config.jwt.secret, {
    subject: user.id,
    expiresIn: config.jwt.expiresIn,
  });
}

function signRefreshToken(user) {
  return jwt.sign({ type: 'refresh' }, config.jwt.refreshSecret, {
    subject: user.id,
    expiresIn: config.jwt.refreshExpiresIn,
  });
}

async function storeRefreshToken(userId, token) {
  const hash = crypto.createHash('sha256').update(token).digest('hex');
  const expires = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);
  await query(
    `INSERT INTO refresh_tokens (user_id, token_hash, expires_at) VALUES ($1, $2, $3)`,
    [userId, hash, expires]
  );
}

export async function register({ email, password, displayName }) {
  const existing = await query('SELECT id FROM users WHERE email = $1', [email.toLowerCase()]);
  if (existing.rows.length) {
    throw new AppError('Email already registered', 409, 'EMAIL_EXISTS');
  }

  const passwordHash = await bcrypt.hash(password, SALT_ROUNDS);
  const verificationToken = crypto.randomBytes(32).toString('hex');

  const result = await query(
    `INSERT INTO users (email, password_hash, display_name, verification_token)
     VALUES ($1, $2, $3, $4) RETURNING id, email, display_name, email_verified, created_at`,
    [email.toLowerCase(), passwordHash, displayName || 'Raisa', verificationToken]
  );

  const user = result.rows[0];

  await query(
    `INSERT INTO settings (user_id) VALUES ($1)`,
    [user.id]
  );
  await query(
    `INSERT INTO streaks (user_id) VALUES ($1)`,
    [user.id]
  );

  const accessToken = signAccessToken(user);
  const refreshToken = signRefreshToken(user);
  await storeRefreshToken(user.id, refreshToken);

  return {
    user: { ...user, email: user.email },
    accessToken,
    refreshToken,
    verificationToken,
  };
}

export async function login({ email, password }) {
  const result = await query(
    `SELECT id, email, password_hash, display_name, email_verified, avatar_url, relationship_level
     FROM users WHERE email = $1`,
    [email.toLowerCase()]
  );

  if (!result.rows.length) {
    throw new AppError('Invalid email or password', 401, 'INVALID_CREDENTIALS');
  }

  const user = result.rows[0];
  const valid = await bcrypt.compare(password, user.password_hash);
  if (!valid) {
    throw new AppError('Invalid email or password', 401, 'INVALID_CREDENTIALS');
  }

  const accessToken = signAccessToken(user);
  const refreshToken = signRefreshToken(user);
  await storeRefreshToken(user.id, refreshToken);

  delete user.password_hash;
  return { user, accessToken, refreshToken };
}

export async function refreshAccessToken(refreshToken) {
  let payload;
  try {
    payload = jwt.verify(refreshToken, config.jwt.refreshSecret);
  } catch {
    throw new AppError('Invalid refresh token', 401, 'INVALID_REFRESH');
  }

  const hash = crypto.createHash('sha256').update(refreshToken).digest('hex');
  const stored = await query(
    `SELECT id FROM refresh_tokens WHERE user_id = $1 AND token_hash = $2 AND expires_at > NOW()`,
    [payload.sub, hash]
  );

  if (!stored.rows.length) {
    throw new AppError('Refresh token revoked', 401, 'TOKEN_REVOKED');
  }

  const userResult = await query(
    `SELECT id, email, display_name FROM users WHERE id = $1`,
    [payload.sub]
  );

  if (!userResult.rows.length) {
    throw new AppError('User not found', 404, 'USER_NOT_FOUND');
  }

  return { accessToken: signAccessToken(userResult.rows[0]) };
}

export async function requestPasswordReset(email) {
  const result = await query('SELECT id FROM users WHERE email = $1', [email.toLowerCase()]);
  if (!result.rows.length) {
    return { message: 'If email exists, reset link sent' };
  }

  const token = crypto.randomBytes(32).toString('hex');
  const expires = new Date(Date.now() + 3600000);

  await query(
    `UPDATE users SET reset_token = $1, reset_token_expires = $2 WHERE id = $3`,
    [token, expires, result.rows[0].id]
  );

  return { token, userId: result.rows[0].id };
}

export async function resetPassword(token, newPassword) {
  const result = await query(
    `SELECT id FROM users WHERE reset_token = $1 AND reset_token_expires > NOW()`,
    [token]
  );

  if (!result.rows.length) {
    throw new AppError('Invalid or expired reset token', 400, 'INVALID_RESET');
  }

  const hash = await bcrypt.hash(newPassword, SALT_ROUNDS);
  await query(
    `UPDATE users SET password_hash = $1, reset_token = NULL, reset_token_expires = NULL WHERE id = $2`,
    [hash, result.rows[0].id]
  );

  await query('DELETE FROM refresh_tokens WHERE user_id = $1', [result.rows[0].id]);
  return { success: true };
}

export async function verifyEmail(token) {
  const result = await query(
    `UPDATE users SET email_verified = TRUE, verification_token = NULL
     WHERE verification_token = $1 RETURNING id, email`,
    [token]
  );

  if (!result.rows.length) {
    throw new AppError('Invalid verification token', 400, 'INVALID_VERIFICATION');
  }

  return result.rows[0];
}

export async function getProfile(userId) {
  const result = await query(
    `SELECT u.id, u.email, u.display_name, u.avatar_url, u.email_verified,
            u.relationship_level, u.created_at,
            s.theme, s.font_family, s.ai_intensity, s.notifications_enabled,
            s.music_enabled, s.haptic_enabled, s.biometric_enabled,
            st.current_streak, st.longest_streak, st.total_entries
     FROM users u
     LEFT JOIN settings s ON s.user_id = u.id
     LEFT JOIN streaks st ON st.user_id = u.id
     WHERE u.id = $1`,
    [userId]
  );

  if (!result.rows.length) {
    throw new AppError('User not found', 404, 'USER_NOT_FOUND');
  }

  return result.rows[0];
}
