import * as authService from '../services/authService.js';
import * as emailService from '../services/emailService.js';

export async function register(req, res) {
  const { email, password, displayName } = req.body;
  const result = await authService.register({ email, password, displayName });
  await emailService.sendVerificationEmail(email, result.verificationToken);
  res.status(201).json({
    success: true,
    data: {
      user: result.user,
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
    },
  });
}

export async function login(req, res) {
  const result = await authService.login(req.body);
  res.json({ success: true, data: result });
}

export async function refresh(req, res) {
  const { refreshToken } = req.body;
  const result = await authService.refreshAccessToken(refreshToken);
  res.json({ success: true, data: result });
}

export async function forgotPassword(req, res) {
  const { email } = req.body;
  const result = await authService.requestPasswordReset(email);
  if (result.token) {
    await emailService.sendPasswordResetEmail(email, result.token);
  }
  res.json({ success: true, message: 'If email exists, reset instructions sent' });
}

export async function resetPassword(req, res) {
  const { token, password } = req.body;
  await authService.resetPassword(token, password);
  res.json({ success: true, message: 'Password updated' });
}

export async function verifyEmail(req, res) {
  const user = await authService.verifyEmail(req.params.token);
  res.json({ success: true, data: user });
}

export async function getProfile(req, res) {
  const profile = await authService.getProfile(req.user.id);
  res.json({ success: true, data: profile });
}
