# Netlify তে Web হিসেবে Share করা 🇧🇩

Raisa's Diary এখন **Flutter Web** হিসেবে Netlify-তে deploy করা যায়।

## গুরুত্বপূর্ণ

| অংশ | কোথায় host |
|-----|-------------|
| **App (UI)** | Netlify (static web) |
| **API + Database** | Render / Railway / VPS (Netlify শুধু frontend) |

Web app কাজ করতে **backend চালু** থাকতে হবে এবং Netlify-তে `API_BASE_URL` সেট করতে হবে।

---

## পদ্ধতি ১ — GitHub + Netlify (স্বয়ংক্রিয়)

### ১. Backend deploy করুন (একবার)

উদাহরণ: [Render](https://render.com) এ Node app:

- Build: `npm install`
- Start: `npm start`
- Env: `DATABASE_URL`, `JWT_SECRET`, `OPENAI_API_KEY`
- API URL হবে: `https://raisa-diary-api.onrender.com`

Backend `.env` এ Netlify URL যোগ করুন:

```env
CORS_ORIGINS=https://your-app-name.netlify.app
FRONTEND_URL=https://your-app-name.netlify.app
```

### ২. GitHub-এ push করুন

```powershell
git add .
git commit -m "Add Netlify web deploy"
git push
```

### ৩. Netlify সাইট বানান

1. [app.netlify.com](https://app.netlify.com) → **Add new site** → **Import from Git**
2. Repository select করুন
3. Settings (অটো `netlify.toml` থেকে আসবে):

| Setting | Value |
|---------|--------|
| Build command | `bash scripts/netlify-build.sh` |
| Publish directory | `frontend/build/web` |

4. **Environment variables** (Site settings → Environment variables):

| Key | Value |
|-----|--------|
| `API_BASE_URL` | `https://YOUR-API.onrender.com/api` |

5. **Deploy site**

কিছুক্ষণ পর লিংক পাবেন: `https://random-name.netlify.app`

### ৪. Site name customize

Netlify → Domain settings → `raisa-diary.netlify.app` (বা নিজের নাম)

---

## পদ্ধতি ২ — Local build + Drag & Drop (দ্রুত)

Flutter ইনস্টল থাকলে:

```powershell
cd frontend
flutter config --enable-web
flutter pub get
flutter build web --release --dart-define=API_BASE_URL=https://YOUR-API.onrender.com/api
```

তারপর [app.netlify.com/drop](https://app.netlify.com/drop) এ **`frontend\build\web`** ফোল্ডার drag করুন।

অথবা:

```powershell
.\scripts\build-web-local.ps1 -ApiUrl "https://YOUR-API.onrender.com/api"
```

---

## Netlify CLI

```powershell
npm install -g netlify-cli
netlify login
cd frontend
flutter build web --release --dart-define=API_BASE_URL=https://YOUR-API.onrender.com/api
netlify deploy --prod --dir=build/web
```

---

## সমস্যা সমাধান

| সমস্যা | সমাধান |
|--------|--------|
| সাদা স্ক্রিন | Browser console দেখুন; `API_BASE_URL` ঠিক আছে কিনা |
| Login fail / CORS | Backend-এ `CORS_ORIGINS` এ Netlify URL দিন |
| Build fail | Netlify build log; Flutter install সময় লাগতে পারে (~10 মিনিট প্রথমবার) |
| Tahsin reply নেই | Backend-এ `OPENAI_API_KEY` সেট করুন |

---

## শেয়ার করার লিংক

Deploy হলে যেকোনো ব্রাউজারে খুলুন:

`https://YOUR-SITE.netlify.app`

মোবাইলে **Add to Home Screen** করলে app-এর মতো লাগবে (PWA)।
