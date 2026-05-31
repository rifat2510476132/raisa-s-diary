import * as notificationService from '../services/notificationService.js';

export async function list(req, res) {
  const unreadOnly = req.query.unread === 'true';
  const notifications = await notificationService.getNotifications(req.user.id, { unreadOnly });
  res.json({ success: true, data: notifications });
}

export async function markRead(req, res) {
  await notificationService.markRead(req.user.id, req.params.id);
  res.json({ success: true });
}

export async function markAllRead(req, res) {
  await notificationService.markAllRead(req.user.id);
  res.json({ success: true });
}

export async function registerDevice(req, res) {
  const { token, platform } = req.body;
  await notificationService.registerDeviceToken(req.user.id, token, platform);
  res.json({ success: true });
}
