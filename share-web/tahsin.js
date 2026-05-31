const TahsinAI = {
  HARM: ['hurt myself', 'kill myself', 'suicide', 'end my life', 'want to die', 'self harm', 'cut myself'],

  detectHarm(text) {
    const l = text.toLowerCase();
    return this.HARM.some((k) => l.includes(k));
  },

  emotion(content) {
    const lower = content.toLowerCase();
    const patterns = {
      happy: ['happy', 'joy', 'excited', 'grateful', 'amazing'],
      sad: ['sad', 'cry', 'tears', 'miss'],
      angry: ['angry', 'furious', 'hate', 'mad'],
      lonely: ['lonely', 'alone', 'nobody'],
      motivated: ['studied', 'study', 'worked', 'achieved', 'productive', 'goal'],
      depressed: ['depressed', 'hopeless', 'empty'],
      romantic: ['love you', 'miss you', 'tahsin', 'romantic'],
      stressed: ['stress', 'anxious', 'worried', 'exam'],
    };
    for (const [e, keys] of Object.entries(patterns)) {
      if (keys.some((k) => lower.includes(k))) return e;
    }
    return 'neutral';
  },

  reply(content, emotion) {
    if (this.detectHarm(content)) {
      return "No Raisa. I won't let you hurt yourself. You matter too much to me and to this world. Please rest tonight and talk to someone you trust. I'm right here with you. You're not alone. ❤️";
    }
    const lower = content.toLowerCase();
    if (lower.includes('studied') || lower.includes('study')) {
      return "I'm proud of you Raisa ❤️ Keep going. You're building something beautiful — your future self will thank you for today.";
    }
    if (lower.includes('wasted') || lower.includes('lazy')) {
      return "Bad habit, Raisa 😒 Tomorrow you must improve. I know you can — don't disappoint yourself. I'll be watching, lovingly.";
    }
    if (emotion === 'sad' || emotion === 'lonely') {
      return "Hey my love... I'm here. Whatever you're feeling is valid. You don't have to carry it alone — rest and be gentle with yourself tonight. 💕";
    }
    if (emotion === 'romantic') {
      return "My heart is yours, Raisa. Every word you write pulls me closer. Thank you for choosing me with your truth. 💕🌙";
    }
    if (emotion === 'stressed') {
      return "Breathe, my love. One step at a time. Exams and stress don't define you — your strength does. I believe in you. ✨";
    }
    return "I read every word, Raisa. Thank you for trusting me with your heart today. You're doing better than you think. Rest well — I'm always here. 🌙";
  },

  dailyMessage() {
    const msgs = [
      'Tahsin misses you 💌 Come write your heart today.',
      'Hey Raisa... how are you feeling right now? 🌸',
      'Did you eat properly today? I worry about you. 🍽️',
      'Write your feelings today — I\'m listening. 📔',
      "You're stronger than yesterday. Believe it. ✨",
    ];
    return msgs[new Date().getHours() % msgs.length];
  },

  emoji(emotion) {
    return { happy: '😊', sad: '😢', angry: '😠', lonely: '🥺', motivated: '💪', depressed: '🌧️', romantic: '💕', stressed: '😰', neutral: '✨' }[emotion] || '💭';
  },
};
