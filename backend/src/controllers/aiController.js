import * as aiChatService from '../services/aiChatService.js';
import * as tahsinAI from '../services/tahsinAIService.js';

export async function listChat(req, res) {
  const limit = parseInt(req.query.limit || '50', 10);
  const messages = await aiChatService.listMessages(req.user.id, limit);
  res.json({ success: true, data: messages });
}

export async function sendChat(req, res) {
  const { message } = req.body;
  const result = await aiChatService.sendMessage(req.user.id, message || '');
  if (result.error) {
    return res.status(400).json({ success: false, error: { message: result.error } });
  }
  res.status(201).json({ success: true, data: result });
}

export async function clearChat(req, res) {
  const result = await aiChatService.clearHistory(req.user.id);
  res.json({ success: true, data: result });
}

export async function dailyMessage(req, res) {
  const message = await tahsinAI.getDailyTahsinMessage(req.user.id);
  res.json({ success: true, data: { message } });
}
