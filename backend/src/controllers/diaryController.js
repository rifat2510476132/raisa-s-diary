import * as diaryService from '../services/diaryService.js';
import * as tahsinAI from '../services/tahsinAIService.js';

export async function createEntry(req, res) {
  const result = await diaryService.createEntry(req.user.id, req.body);
  res.status(201).json({ success: true, data: result });
}

export async function listEntries(req, res) {
  const page = parseInt(req.query.page || '1', 10);
  const limit = parseInt(req.query.limit || '20', 10);
  const result = await diaryService.getEntries(req.user.id, { page, limit });
  res.json({ success: true, data: result });
}

export async function getEntry(req, res) {
  const entry = await diaryService.getEntry(req.user.id, req.params.id);
  res.json({ success: true, data: entry });
}

export async function deleteEntry(req, res) {
  await diaryService.deleteEntry(req.user.id, req.params.id);
  res.json({ success: true, message: 'Entry deleted' });
}

export async function getEmotionStats(req, res) {
  const days = parseInt(req.query.days || '30', 10);
  const stats = await diaryService.getEmotionStats(req.user.id, days);
  res.json({ success: true, data: stats });
}

export async function getMoodCalendar(req, res) {
  const year = parseInt(req.query.year || new Date().getFullYear(), 10);
  const month = parseInt(req.query.month || new Date().getMonth() + 1, 10);
  const calendar = await diaryService.getMoodCalendar(req.user.id, year, month);
  res.json({ success: true, data: calendar });
}

export async function getTahsinMessage(req, res) {
  const message = await tahsinAI.getDailyTahsinMessage(req.user.id);
  res.json({ success: true, data: { message } });
}
