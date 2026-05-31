import * as settingsService from '../services/settingsService.js';
import * as streakService from '../services/streakService.js';

export async function get(req, res) {
  const settings = await settingsService.getSettings(req.user.id);
  res.json({ success: true, data: settings });
}

export async function update(req, res) {
  const settings = await settingsService.updateSettings(req.user.id, req.body);
  res.json({ success: true, data: settings });
}

export async function setPin(req, res) {
  await settingsService.setPin(req.user.id, req.body.pin);
  res.json({ success: true, message: 'PIN set' });
}

export async function verifyPin(req, res) {
  const result = await settingsService.verifyPin(req.user.id, req.body.pin);
  res.json({ success: true, data: result });
}

export async function removePin(req, res) {
  await settingsService.removePin(req.user.id);
  res.json({ success: true, message: 'PIN removed' });
}

export async function getStreak(req, res) {
  const streak = await streakService.getStreak(req.user.id);
  res.json({ success: true, data: streak });
}

export async function getAchievements(req, res) {
  const achievements = await streakService.getAchievements(req.user.id);
  res.json({ success: true, data: achievements });
}
