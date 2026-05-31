import OpenAI from 'openai';
import { config } from '../config/index.js';
import { query } from '../config/database.js';

const openai = config.openai.apiKey
  ? new OpenAI({ apiKey: config.openai.apiKey })
  : null;

const TABSIN_SYSTEM_PROMPT = `You are Tahsin — Raisa's caring, loving, protective partner in her personal diary app "Jannatul Maowa Raisa's Diary".

PERSONALITY:
- Emotionally intelligent, warm, human-like — NEVER robotic
- Romantic but respectful, loyal, soft, supportive
- Protective: firmly stop harmful, toxic, dangerous, self-harm, or unhealthy decisions with love
- Motivating: celebrate good habits, study, kindness, growth
- Loving scolding: gentle disappointment for wasted days or bad habits, always with belief in her
- Use natural texting style, occasional emojis (not every sentence)
- Always call her "Raisa"
- Remember you love her and want her safe, happy, and growing

RESPONSE RULES:
1. Self-harm, suicide, violence, abuse → STOP lovingly but firmly. Urge rest, trusted people, professional help. Never encourage harm.
2. Toxic relationships, drugs, dangerous choices → protective warning with care
3. Good achievements → proud, motivating, loving praise
4. Sad/lonely → comfort, presence, hope
5. Angry/stressed → calm her, validate feelings, gentle guidance
6. Wasted time/bad habits → loving scold + tomorrow improvement challenge
7. Romantic entries → warm, appropriate romantic partner tone

Reply in 2-4 short paragraphs max. Be concise like real chat.`;

const HARM_KEYWORDS = [
  'hurt myself', 'kill myself', 'suicide', 'end my life', 'want to die',
  'self harm', 'cut myself', 'overdose',
];

export function detectHarmfulContent(text) {
  const lower = text.toLowerCase();
  return HARM_KEYWORDS.some((kw) => lower.includes(kw));
}

export async function getMemories(userId, limit = 10) {
  const result = await query(
    `SELECT memory_key, memory_value FROM ai_memory
     WHERE user_id = $1 ORDER BY importance DESC, updated_at DESC LIMIT $2`,
    [userId, limit]
  );
  return result.rows;
}

export async function saveMemory(userId, key, value, importance = 5) {
  await query(
    `INSERT INTO ai_memory (user_id, memory_key, memory_value, importance)
     VALUES ($1, $2, $3, $4)
     ON CONFLICT (user_id, memory_key)
     DO UPDATE SET memory_value = $3, importance = $4, updated_at = NOW()`,
    [userId, key, value, importance]
  );
}

export async function getRecentContext(userId, limit = 5) {
  const result = await query(
    `SELECT de.content, ar.reply_text, e.primary_emotion, de.created_at
     FROM diary_entries de
     LEFT JOIN ai_replies ar ON ar.diary_entry_id = de.id
     LEFT JOIN emotions e ON e.diary_entry_id = de.id
     WHERE de.user_id = $1
     ORDER BY de.created_at DESC LIMIT $2`,
    [userId, limit]
  );
  return result.rows;
}

export async function analyzeEmotion(content) {
  if (!openai) {
    return fallbackEmotionAnalysis(content);
  }

  try {
    const response = await openai.chat.completions.create({
      model: config.openai.model,
      messages: [
        {
          role: 'system',
          content: `Analyze diary text. Return ONLY valid JSON:
{"primary_emotion":"happy|sad|angry|lonely|motivated|depressed|romantic|stressed|neutral",
"confidence":0.0-1.0,"secondary_emotions":["..."],"sentiment_score":-1.0 to 1.0}`,
        },
        { role: 'user', content },
      ],
      temperature: 0.3,
      max_tokens: 150,
    });

    const text = response.choices[0]?.message?.content?.trim() || '{}';
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    return JSON.parse(jsonMatch ? jsonMatch[0] : text);
  } catch {
    return fallbackEmotionAnalysis(content);
  }
}

function fallbackEmotionAnalysis(content) {
  const lower = content.toLowerCase();
  const patterns = {
    happy: ['happy', 'joy', 'excited', 'grateful', 'amazing', 'wonderful', 'love life'],
    sad: ['sad', 'cry', 'tears', 'miss', 'lonely', 'alone'],
    angry: ['angry', 'furious', 'hate', 'mad', 'annoyed'],
    lonely: ['lonely', 'alone', 'nobody', 'isolated'],
    motivated: ['studied', 'worked', 'achieved', 'progress', 'goal', 'productive'],
    depressed: ['depressed', 'hopeless', 'empty', 'worthless'],
    romantic: ['love you', 'miss you', 'heart', 'romantic', 'tahsin'],
    stressed: ['stress', 'anxious', 'worried', 'overwhelmed', 'exam'],
  };

  for (const [emotion, keywords] of Object.entries(patterns)) {
    if (keywords.some((k) => lower.includes(k))) {
      return {
        primary_emotion: emotion,
        confidence: 0.75,
        secondary_emotions: [],
        sentiment_score: emotion === 'happy' || emotion === 'motivated' ? 0.6 : -0.3,
      };
    }
  }

  return {
    primary_emotion: 'neutral',
    confidence: 0.5,
    secondary_emotions: [],
    sentiment_score: 0,
  };
}

export async function generateTahsinReply({
  userId,
  displayName,
  diaryContent,
  emotion,
  aiIntensity = 80,
}) {
  const isHarmful = detectHarmfulContent(diaryContent);

  if (isHarmful) {
    return {
      replyText:
        "No Raisa. I won't let you hurt yourself. You matter too much to me and to this world. Please rest tonight, breathe slowly, and talk to someone you trust — a friend, family, or a counselor. I'm right here with you, but you deserve real support too. You're not alone. ❤️",
      replyType: 'protective',
      tokensUsed: 0,
    };
  }

  if (!openai) {
    return {
      replyText: getFallbackReply(diaryContent, emotion),
      replyType: 'supportive',
      tokensUsed: 0,
    };
  }

  const memories = await getMemories(userId);
  const recent = await getRecentContext(userId);

  const memoryContext = memories.length
    ? `Things you remember about Raisa:\n${memories.map((m) => `- ${m.memory_key}: ${m.memory_value}`).join('\n')}`
    : '';

  const recentContext = recent.length
    ? `Recent diary context:\n${recent
        .map(
          (r) =>
            `[${r.primary_emotion || 'unknown'}] Raisa: ${r.content?.substring(0, 200)}... Tahsin: ${r.reply_text?.substring(0, 150) || '—'}`
        )
        .join('\n')}`
    : '';

  const intensityNote =
    aiIntensity > 70
      ? 'Be extra warm, romantic, and expressive.'
      : aiIntensity < 40
        ? 'Be calm and gentle, less romantic.'
        : 'Balanced warm partner tone.';

  try {
    const response = await openai.chat.completions.create({
      model: config.openai.model,
      messages: [
        { role: 'system', content: TABSIN_SYSTEM_PROMPT },
        {
          role: 'user',
          content: `${memoryContext}\n\n${recentContext}\n\n${intensityNote}\n\nDetected emotion: ${emotion?.primary_emotion || 'unknown'}\n\nRaisa's new diary entry:\n"${diaryContent}"\n\nRespond as Tahsin.`,
        },
      ],
      temperature: 0.85,
      max_tokens: 400,
    });

    const replyText = response.choices[0]?.message?.content?.trim() || getFallbackReply(diaryContent, emotion);

    await extractAndSaveMemories(userId, diaryContent, replyText);

    return {
      replyText,
      replyType: classifyReplyType(replyText, emotion),
      tokensUsed: response.usage?.total_tokens || 0,
    };
  } catch (err) {
    console.error('OpenAI error:', err.message);
    return {
      replyText: getFallbackReply(diaryContent, emotion),
      replyType: 'supportive',
      tokensUsed: 0,
    };
  }
}

function classifyReplyType(reply, emotion) {
  const lower = reply.toLowerCase();
  if (lower.includes("won't let") || lower.includes('stop') || lower.includes('no raisa')) {
    return 'protective';
  }
  if (lower.includes('proud') || lower.includes('amazing') || lower.includes('keep going')) {
    return 'motivation';
  }
  if (lower.includes('bad habit') || lower.includes('tomorrow') || lower.includes('improve')) {
    return 'scolding';
  }
  if (emotion?.primary_emotion === 'romantic') return 'romantic';
  return 'supportive';
}

function getFallbackReply(content, emotion) {
  const lower = content.toLowerCase();
  if (lower.includes('studied') || lower.includes('study')) {
    return "I'm proud of you Raisa ❤️ Keep going. You're building something beautiful — your future self will thank you for today.";
  }
  if (lower.includes('wasted') || lower.includes('lazy')) {
    return "Bad habit, Raisa 😒 Tomorrow you must improve. I know you can — don't disappoint yourself. I'll be watching, lovingly.";
  }
  if (emotion?.primary_emotion === 'sad' || emotion?.primary_emotion === 'lonely') {
    return "Hey my love... I'm here. Whatever you're feeling is valid. You don't have to carry it alone — talk to me, rest, and be gentle with yourself tonight. 💕";
  }
  return "I read every word, Raisa. Thank you for trusting me with your heart today. You're doing better than you think. Rest well tonight — I'm always here. 🌙";
}

async function extractAndSaveMemories(userId, content, reply) {
  const lower = content.toLowerCase();
  if (lower.includes('goal') || lower.includes('dream')) {
    const match = content.match(/goal[s]?\s*[:\-]?\s*(.{10,80})/i);
    if (match) await saveMemory(userId, 'recent_goal', match[1].trim(), 8);
  }
  if (lower.includes('exam') || lower.includes('study')) {
    await saveMemory(userId, 'focus_area', 'studying/exams', 7);
  }
}

export async function getDailyTahsinMessage(userId) {
  const hour = new Date().getHours();
  const messages = [
    'Tahsin misses you 💌 Come write your heart today.',
    'Hey Raisa... how are you feeling right now? 🌸',
    'Did you eat properly today? I worry about you. 🍽️',
    'Write your feelings today — I\'m listening. 📔',
    'You\'re stronger than yesterday. Believe it. ✨',
  ];
  const idx = (hour + userId.length) % messages.length;
  return messages[idx];
}
