import * as emotionService from '../services/emotionService.js';

export async function getStats(req, res) {
  const days = parseInt(req.query.days || '30', 10);
  const stats = await emotionService.getStats(req.user.id, days);
  res.json({ success: true, data: stats });
}

export async function getRecent(req, res) {
  const limit = parseInt(req.query.limit || '20', 10);
  const emotions = await emotionService.getRecentEmotions(req.user.id, limit);
  res.json({ success: true, data: emotions });
}

export async function getByEntry(req, res) {
  const emotion = await emotionService.getEmotionByEntry(req.user.id, req.params.entryId);
  res.json({ success: true, data: emotion });
}
