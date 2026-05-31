import * as userService from '../services/userService.js';

export async function getMe(req, res) {
  const profile = await userService.getUserById(req.user.id);
  res.json({ success: true, data: profile });
}

export async function updateMe(req, res) {
  const profile = await userService.updateProfile(req.user.id, {
    displayName: req.body.displayName,
    avatarUrl: req.body.avatarUrl,
  });
  res.json({ success: true, data: profile });
}

export async function registerDevice(req, res) {
  const { token, platform } = req.body;
  const result = await userService.registerDeviceToken(req.user.id, token, platform);
  res.json({ success: true, data: result });
}
