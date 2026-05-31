import OpenAI from 'openai';
import { config } from '../config/index.js';
import { query } from '../config/database.js';
import {
  detectHarmfulContent,
  getMemories,
  getRecentContext,
  saveMemory,
} from './tahsinAIService.js';

const openai = config.openai.apiKey
  ? new OpenAI({ apiKey: config.openai.apiKey })
  : null;

const CHAT_SYSTEM = `You are Tahsin — Raisa's caring AI partner in her diary app.
Chat naturally in 1-3 short paragraphs. Call her Raisa. Be warm, protective, motivating.
Never encourage self-harm or dangerous behavior. Use occasional emojis.`;

export async function listMessages(userId, limit = 50) {
  const result = await query(
    `SELECT id, role, content, created_at
     FROM ai_chat_messages
     WHERE user_id = $1
     ORDER BY created_at ASC
     LIMIT $2`,
    [userId, limit]
  );
  return result.rows;
}

export async function sendMessage(userId, userMessage) {
  const trimmed = userMessage.trim();
  if (!trimmed) {
    return { error: 'Message cannot be empty' };
  }

  await query(
    `INSERT INTO ai_chat_messages (user_id, role, content) VALUES ($1, 'user', $2)`,
    [userId, trimmed]
  );

  let replyText;
  let tokensUsed = 0;

  if (detectHarmfulContent(trimmed)) {
    replyText =
      "Raisa, stop. I love you too much to let you hurt yourself. Please rest, reach someone you trust, or get professional help right now. I'm here, but you deserve real support too. 💕";
  } else if (openai) {
    const memories = await getMemories(userId, 8);
    const recentDiary = await getRecentContext(userId, 3);
    const history = await query(
      `SELECT role, content FROM ai_chat_messages
       WHERE user_id = $1 ORDER BY created_at DESC LIMIT 12`,
      [userId]
    );
    const chatHistory = history.rows.reverse().map((r) => ({
      role: r.role === 'assistant' ? 'assistant' : 'user',
      content: r.content,
    }));

    const memoryContext = memories
      .map((m) => `${m.memory_key}: ${m.memory_value}`)
      .join('\n');
    const diaryContext = recentDiary
      .map((d) => `[${d.created_at}] Raisa: ${d.content?.slice(0, 120)}`)
      .join('\n');

    const response = await openai.chat.completions.create({
      model: config.openai.model,
      messages: [
        { role: 'system', content: CHAT_SYSTEM },
        {
          role: 'user',
          content: `Memories:\n${memoryContext}\n\nRecent diary:\n${diaryContext}`,
        },
        ...chatHistory,
      ],
      temperature: 0.85,
      max_tokens: 350,
    });

    replyText =
      response.choices[0]?.message?.content?.trim() ||
      "I'm here, Raisa. Tell me more about how you're feeling. 💕";
    tokensUsed = response.usage?.total_tokens || 0;

    if (trimmed.length > 40) {
      await saveMemory(userId, 'last_chat_topic', trimmed.slice(0, 120), 4);
    }
  } else {
    const lower = trimmed.toLowerCase();
    if (lower.includes('sad') || lower.includes('lonely')) {
      replyText =
        "Hey my love... I'm right here. Whatever you're carrying, you don't have to carry it alone tonight. Talk to me — or rest. Both are okay. 🌙";
    } else if (lower.includes('love')) {
      replyText =
        "I love you too, Raisa. More than words can hold. Thank you for trusting me with your heart. 💕";
    } else {
      replyText =
        "I hear you, Raisa. Keep talking — every word matters to me. What's on your mind right now?";
    }
  }

  const insert = await query(
    `INSERT INTO ai_chat_messages (user_id, role, content, tokens_used)
     VALUES ($1, 'assistant', $2, $3)
     RETURNING id, role, content, created_at`,
    [userId, replyText, tokensUsed]
  );

  return {
    userMessage: trimmed,
    assistantMessage: insert.rows[0],
  };
}

export async function clearHistory(userId) {
  await query('DELETE FROM ai_chat_messages WHERE user_id = $1', [userId]);
  return { cleared: true };
}
