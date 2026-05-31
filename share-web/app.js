const STORE = {
  get(k, d) {
    try { return JSON.parse(localStorage.getItem(k)) ?? d; } catch { return d; }
  },
  set(k, v) { localStorage.setItem(k, JSON.stringify(v)); },
};

function initParticles() {
  const box = document.getElementById('particles');
  for (let i = 0; i < 24; i++) {
    const p = document.createElement('div');
    p.className = 'particle';
    p.style.left = Math.random() * 100 + '%';
    p.style.top = Math.random() * 100 + '%';
    p.style.animationDelay = Math.random() * 8 + 's';
    p.style.opacity = 0.15 + Math.random() * 0.2;
    box.appendChild(p);
  }
}

const App = {
  user: null,
  screen: 'splash',
  mood: null,
  typingTimer: null,

  /** user null/ভাঙা থাকলে crash এড়াতে */
  ensureUser() {
    const saved = STORE.get('user', null);
    if (saved && typeof saved === 'object' && saved.name) {
      this.user = saved;
      return this.user;
    }
    this.autoEnter();
    return this.user;
  },

  displayName() {
    const u = this.user;
    return u && u.name ? u.name : 'Raisa';
  },

  init() {
    initParticles();
    if (STORE.get('dark', false)) document.body.classList.add('dark');
    this.user = STORE.get('user', null);
    if (STORE.get('onboarding') && (!this.user || !this.user.name)) {
      this.ensureUser();
    }
    setTimeout(() => {
      if (!STORE.get('onboarding')) this.go('onboarding');
      else {
        this.ensureUser();
        this.go('home');
      }
    }, 1200);
    this.render();
  },

  go(name) {
    this.screen = name;
    this.render();
    window.scrollTo(0, 0);
  },

  /** সরাসরি Raisa হিসেবে ঢোকে — password/email কিছুই নেই */
  autoEnter() {
    const saved = STORE.get('user', null);
    this.user = saved || {
      name: 'Raisa',
      streak: 0,
      level: 1,
      created: Date.now(),
    };
    STORE.set('user', this.user);
    if (!STORE.get('diaries')) STORE.set('diaries', []);
  },

  logout() {
    this.autoEnter();
    this.go('home');
  },

  saveDiary(content, title, mood) {
    this.ensureUser();
    const emotion = TahsinAI.emotion(content);
    const reply = TahsinAI.reply(content, emotion);
    const entries = STORE.get('diaries', []);
    const entry = {
      id: Date.now().toString(),
      content, title, mood,
      emotion,
      reply,
      at: new Date().toISOString(),
    };
    entries.unshift(entry);
    STORE.set('diaries', entries);

    const today = new Date().toDateString();
    const last = STORE.get('lastWrite', '');
    let streak = this.user.streak || 0;
    if (last !== today) {
      const y = new Date(); y.setDate(y.getDate() - 1);
      streak = last === y.toDateString() ? streak + 1 : 1;
      STORE.set('lastWrite', today);
    }
    this.user.streak = streak;
    this.user.level = Math.min(10, 1 + Math.floor(entries.length / 5));
    STORE.set('user', this.user);
    return entry;
  },

  nav() {
    if (!this.user) return '';
    const tabs = [
      { id: 'home', icon: '♥', label: 'Home' },
      { id: 'diaries', icon: '📔', label: 'Diary' },
      { id: 'insights', icon: '📊', label: 'Insights' },
      { id: 'settings', icon: '⚙', label: 'Settings' },
    ];
  const cur = this.screen;
  if (['onboarding', 'splash', 'write', 'detail'].includes(cur)) return '';
  return `<nav class="nav">${tabs.map((t) =>
    `<button class="${cur === t.id ? 'active' : ''}" onclick="App.go('${t.id}')"><span>${t.icon}</span>${t.label}</button>`
  ).join('')}</nav>`;
  },

  fab() {
    if (['home', 'diaries', 'insights'].includes(this.screen)) {
      return `<button class="fab" onclick="App.go('write')" title="লিখুন">✎</button>`;
    }
    return '';
  },

  render() {
    const app = document.getElementById('app');
    const screens = {
      splash: this.viewSplash(),
      onboarding: this.viewOnboarding(),
      home: this.viewHome(),
      diaries: this.viewDiaries(),
      insights: this.viewInsights(),
      settings: this.viewSettings(),
      write: this.viewWrite(),
      detail: this.viewDetail(),
    };
    app.innerHTML = (screens[this.screen] || '') + this.nav() + this.fab();
  },

  viewSplash() {
    return `<div class="screen active center">
      <div class="avatar" style="width:100px;height:100px;font-size:48px;margin:40px auto 24px">💕</div>
      <h1>Raisa's Diary</h1>
      <p class="mt small">with Tahsin</p>
      <p class="mt">লোড হচ্ছে...</p>
    </div>`;
  },

  viewOnboarding() {
    return `<div class="screen active center">
      <div style="font-size:64px">📔</div>
      <h2 class="mt">আপনার নিরাপদ জায়গা</h2>
      <p class="mt small">মনের কথা লিখুন — Tahsin শুনবে, ভালোবাসবে, রক্ষা করবে।</p>
      <button class="btn mt" onclick="STORE.set('onboarding',true);App.autoEnter();App.go('home')">শুরু করুন 💕</button>
      <p class="mt small">কোনো password লাগবে না</p>
    </div>`;
  },

  viewHome() {
    const u = this.ensureUser();
    const userName = this.displayName();
    const entries = STORE.get('diaries', []).slice(0, 5);
    const msg = TahsinAI.dailyMessage();
    return `<div class="screen active">
      <div class="row mb" style="justify-content:space-between;align-items:center">
        <div><h2>Hello, ${userName} 🌸</h2><p class="small">${new Date().toLocaleDateString('en', { weekday: 'long', month: 'short', day: 'numeric' })}</p></div>
        <span class="streak">🔥 ${u.streak || 0}</span>
      </div>
      <div class="glass row">
        <div class="avatar">💕</div>
        <div><p class="small" style="color:var(--pink)">Tahsin says</p><p>${msg}</p></div>
      </div>
      <div class="glass center small">Relationship Lv.${u.level || 1} 💕</div>
      <p class="mb mt"><b>Recent Diaries</b></p>
      ${entries.length ? entries.map((e) => this.diaryCard(e)).join('') : '<div class="glass center small">এখনো কিছু লেখেন নি — ✎ চাপুন</div>'}
    </div>`;
  },

  diaryCard(e, click = true) {
    const d = new Date(e.at);
    const onclick = click ? `onclick="App.openDetail('${e.id}')"` : '';
    return `<div class="glass diary-item" ${onclick}>
      <span class="tag">${TahsinAI.emoji(e.emotion)} ${e.emotion}</span>
      <span class="small">${d.toLocaleString()}</span>
      <p class="mt">${e.content.substring(0, 120)}${e.content.length > 120 ? '…' : ''}</p>
      <p class="small mt" style="color:var(--pink)">Tahsin: ${e.reply.substring(0, 80)}…</p>
    </div>`;
  },

  viewDiaries() {
    const entries = STORE.get('diaries', []);
    return `<div class="screen active">
      <h2>All Diaries 📔</h2>
      ${entries.length ? entries.map((e) => this.diaryCard(e)).join('') : '<div class="glass center mt">খালি — লিখতে ✎ চাপুন</div>'}
    </div>`;
  },

  viewInsights() {
    const entries = STORE.get('diaries', []);
    const counts = {};
    entries.forEach((e) => { counts[e.emotion] = (counts[e.emotion] || 0) + 1; });
    const keys = Object.keys(counts);
    const max = Math.max(1, ...Object.values(counts));
    const bars = keys.map((k) =>
      `<div style="flex:1;text-align:center"><div class="chart-bar" style="height:${(counts[k] / max) * 100}px;margin:0 auto 8px;width:80%"></div><span>${TahsinAI.emoji(k)}</span></div>`
    ).join('');
    return `<div class="screen active">
      <h2>Emotional Insights</h2>
      <div class="glass">${keys.length ? `<div style="display:flex;align-items:flex-end;gap:8px;min-height:100px">${bars}</div>` : '<p class="center small">আরো লিখলে chart দেখাবে</p>'}</div>
      <div class="glass mt"><p>🔥 Streak: <b>${this.user?.streak || 0}</b> days</p><p class="mt small">Total entries: ${entries.length}</p></div>
    </div>`;
  },

  viewSettings() {
    const dark = STORE.get('dark', false);
    return `<div class="screen active">
      <h2>Settings</h2>
      <div class="glass">
        <label><input type="checkbox" ${dark ? 'checked' : ''} onchange="App.toggleDark(this.checked)" /> Dark mode</label>
      </div>
      <p class="center small mt">ডেটা এই ব্রাউজারে সেভ থাকে 💕<br/><small>v3 — password নেই</small></p>
    </div>`;
  },

  viewWrite() {
    const moods = ['😊', '😢', '😠', '🥰', '😴', '💪', '🌧️', '✨'];
    return `<div class="screen active">
      <div class="row mb" style="justify-content:space-between">
        <h2>Pour your heart</h2>
        <button style="background:none;border:none;font-size:24px;cursor:pointer" onclick="App.go('home')">×</button>
      </div>
      <div style="display:flex;gap:8px;flex-wrap:wrap;margin-bottom:12px">
        ${moods.map((m) => `<div class="mood-btn ${App.mood === m ? 'selected' : ''}" onclick="App.mood='${m}';App.render()">${m}</div>`).join('')}
      </div>
      <input id="wtitle" placeholder="Title (optional)" />
      <textarea id="wcontent" placeholder="Dear Tahsin, today I feel..."></textarea>
      <button class="btn" onclick="App.submitDiary()">Save 💕</button>
      <div id="replyBox"></div>
    </div>`;
  },

  viewDetail() {
    const e = STORE.get('diaries', []).find((x) => x.id === this.detailId);
    if (!e) return `<div class="screen active"><p>Not found</p><button class="btn mt" onclick="App.go('diaries')">Back</button></div>`;
    return `<div class="screen active">
      <button class="btn btn-outline mb" onclick="App.go('diaries')">← Back</button>
      <div class="glass">
        <span class="tag">${TahsinAI.emoji(e.emotion)} ${e.emotion}</span>
        <p class="small mt">${new Date(e.at).toLocaleString()}</p>
        ${e.title ? `<h3 class="mt">${e.title}</h3>` : ''}
        <p class="mt" style="line-height:1.6">${e.content}</p>
      </div>
      <div class="glass row mt">
        <div class="avatar">💕</div>
        <div><b style="color:var(--pink)">Tahsin</b><p id="detailReply" class="mt"></p></div>
      </div>
    </div>`;
  },

  openDetail(id) {
    this.detailId = id;
    this.go('detail');
    setTimeout(() => this.typeText('detailReply', STORE.get('diaries', []).find((x) => x.id === id)?.reply || ''), 100);
  },

  typeText(elId, text) {
    const el = document.getElementById(elId);
    if (!el) return;
    el.classList.add('typing');
    let i = 0;
    el.textContent = '';
    clearInterval(this.typingTimer);
    this.typingTimer = setInterval(() => {
      if (i < text.length) { el.textContent += text[i++]; }
      else { el.classList.remove('typing'); clearInterval(this.typingTimer); }
    }, 22);
  },

  submitDiary() {
    const content = document.getElementById('wcontent').value.trim();
    if (!content) return;
    const entry = this.saveDiary(content, document.getElementById('wtitle').value.trim(), this.mood);
    const box = document.getElementById('replyBox');
    box.innerHTML = `<div class="glass row mt"><div class="avatar">💕</div><div><b style="color:var(--pink)">Tahsin</b><p id="liveReply" class="typing mt"></p></div></div>`;
    this.typeText('liveReply', entry.reply);
    setTimeout(() => this.go('home'), 4500);
  },

  toggleDark(on) {
    STORE.set('dark', on);
    document.body.classList.toggle('dark', on);
  },
};

document.addEventListener('DOMContentLoaded', () => App.init());
