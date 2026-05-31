# পুরো Flutter App — Netlify + Render (বাংলা গাইড)

## আগে জানো (২টা জায়গা)

| কোথায় | কী |
|--------|-----|
| **Render** | Backend API + Database (মোবাইল/ওয়েবের ডেটা) |
| **Netlify** | Flutter Web (যা সবাই ব্রাউজারে খুলবে) |

শুধু Netlify দিলে **সাইট খুলবে**, কিন্তু login/diary **কাজ করবে না** যদি backend না থাকে।

---

## অংশ A — Backend (Render) — একবার

1. https://render.com → GitHub login
2. **New +** → **Blueprint** → repo `jannatul-maowa-raisa-diary` select
3. Deploy শেষে API URL নাও, যেমন: `https://raisa-diary-api.onrender.com`
4. **Shell** বা local থেকে: `npm run db:migrate` (database table)
5. Browser-এ খোলো: `https://তোমার-api.onrender.com/api/health` → OK

Render **Environment** এ সেট করো:
- `JWT_SECRET` = লম্বা গুপ্ত শব্দ
- `JWT_REFRESH_SECRET` = আরেকটা
- `OPENAI_API_KEY` = optional

---

## অংশ B — Netlify (Flutter Web)

### ধাপ ১ — Build settings (UI)

**Project configuration** → **Build & deploy** → **Build settings** → **Configure**

| Field | Value |
|-------|--------|
| Base directory | `frontend` |
| Build command | `flutter pub get && flutter build web --release --dart-define=API_BASE_URL=$API_BASE_URL` |
| Publish directory | `build/web` |

Save.

*(রুটে `netlify.toml` থাকলে অনেক কিছু অটো — UI-তেও একই রাখো)*

### ধাপ ২ — Environment variable (খুব জরুরি)

**Project configuration** → **Environment variables** → **Add**

| Key | Value (উদাহরণ) |
|-----|----------------|
| `API_BASE_URL` | `https://raisa-diary-api.onrender.com/api` |

তোমার Render API URL + শেষে `/api`।

### ধাপ ৩ — Flutter Plugin

**Plugins** → Search `flutter` → **Netlify Plugin Flutter** → **Install**

### ধাপ ৪ — Git push

```powershell
cd C:\Users\rifat\Projects\jannatul-maowa-raisa-diary
git add .
git commit -m "Configure full flutter build with netlify plugin"
git push origin main
```

### ধাপ ৫ — Deploy

**Deploys** → **Trigger deploy** → **Deploy project without cache**

প্রথম build **৫–১৫ মিনিট** লাগতে পারে।

---

## সফল হলে

লিংক: `https://raisadiary.netlify.app`

- Register / Login
- Diary লেখা
- Tahsin reply

---

## সমস্যা

| সমস্যা | সমাধান |
|--------|--------|
| Build fail | Deploy log দেখো; Plugin install হয়েছে কি |
| সাদা স্ক্রিন | F12 Console; `API_BASE_URL` ঠিক কি |
| Login fail | Render backend চালু? health URL OK? |
| CORS error | Render-এ `CORS_ORIGINS=https://raisadiary.netlify.app` |
