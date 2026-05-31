# Jannatul Maowa Raisa's Diary 💕

An emotional AI-powered personal diary mobile app where **Raisa** writes her heart, and **Tahsin** — a caring, protective AI partner — responds with love, motivation, and gentle guidance.

## Stack

| Layer | Technology |
|-------|------------|
| Mobile | Flutter 3 + Riverpod + Go Router |
| Backend | Node.js + Express |
| Database | PostgreSQL |
| AI | OpenAI API (Tahsin personality) |
| Auth | JWT + refresh tokens |
| Media | Cloudinary (optional) |
| Offline | Hive local storage |

## Project structure

```
jannatul-maowa-raisa-diary/
├── backend/          # Express REST API
├── frontend/         # Flutter mobile app
├── database/         # PostgreSQL schema
├── docs/             # API & deployment guides
└── assets/           # Shared branding assets
```

## Prerequisites

- **Node.js** 18+
- **PostgreSQL** 14+
- **Flutter** 3.16+ ([install](https://docs.flutter.dev/get-started/install))
- **Android Studio** (for APK / emulator)
- **OpenAI API key** (for full Tahsin AI; fallback replies work without it)

## Quick start

### 1. Database

```powershell
# Create database
psql -U postgres -c "CREATE DATABASE raisa_diary;"

# Apply schema
cd C:\Users\rifat\Projects\jannatul-maowa-raisa-diary
psql -U postgres -d raisa_diary -f database\schema.sql
```

Or via Node:

```powershell
cd backend
copy .env.example .env
# Edit .env with DATABASE_URL and secrets
npm install
npm run db:migrate
```

### 2. Backend

```powershell
cd backend
copy .env.example .env
```

Edit `backend\.env`:

```env
DATABASE_URL=postgresql://postgres:YOUR_PASSWORD@localhost:5432/raisa_diary
JWT_SECRET=your-long-random-secret-at-least-32-characters
JWT_REFRESH_SECRET=another-long-random-secret
OPENAI_API_KEY=sk-...
```

Start API:

```powershell
npm run dev
```

Health check: http://localhost:3000/api/health

### 3. Flutter app

```powershell
cd frontend
flutter pub get
```

**API URL for devices:**

| Target | `API_BASE_URL` |
|--------|----------------|
| Android emulator | `http://10.0.2.2:3000/api` (default) |
| Physical phone | `http://YOUR_PC_LAN_IP:3000/api` |

Run with custom API:

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000/api
```

```powershell
flutter run
```

## Build APK (Android)

```powershell
cd frontend
flutter pub get
flutter build apk --release --dart-define=API_BASE_URL=https://your-production-api.com/api
```

Output: `frontend\build\app\outputs\flutter-apk\app-release.apk`

### App bundle (Play Store)

```powershell
flutter build appbundle --release --dart-define=API_BASE_URL=https://your-production-api.com/api
```

## Features implemented

- JWT auth (register, login, refresh, forgot/reset password, email verification hooks)
- Diary CRUD with Tahsin AI replies
- Emotion analysis (OpenAI + keyword fallback)
- Harmful content protection (self-harm detection)
- AI memory & context from recent entries
- Writing streaks & achievements
- Scheduled Tahsin notifications (cron)
- Emotion charts & mood calendar API
- PIN lock UI + biometric unlock (`local_auth`)
- Dark/light theme
- Glassmorphism UI, particles, typing animation
- Offline diary drafts (Hive)
- Cloudinary media upload
- Rate limiting & Helmet security

## Tahsin AI behavior

Tahsin is configured in `backend/src/services/tahsinAIService.js`:

- Proud & motivating for good habits
- Loving scold for wasted days
- Firm protection for self-harm / danger
- Romantic, soft, human-like tone
- Never robotic

## Full installation

See [docs/INSTALLATION.md](docs/INSTALLATION.md) for step-by-step database, backend, Flutter, and APK setup.

## Project structure

See [docs/PROJECT_STRUCTURE.md](docs/PROJECT_STRUCTURE.md).

## Deploy on Netlify (Web)

Share the diary as a website:

1. Deploy **backend** to Render/Railway (API URL).
2. Set Netlify env: `API_BASE_URL=https://your-api.com/api`
3. Connect GitHub repo to Netlify (uses root `netlify.toml`).

Full guide (বাংলা): [docs/NETLIFY.md](docs/NETLIFY.md)

## Package as ZIP

```powershell
.\scripts\package-project.ps1
```

Creates `dist\jannatul-maowa-raisa-diary.zip` (excludes `node_modules`, `build`, `.git`).

## Deployment

See [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md).

## API documentation

See [docs/API.md](docs/API.md).

## Environment variables

| Variable | Required | Description |
|----------|----------|-------------|
| `DATABASE_URL` | Yes | PostgreSQL connection string |
| `JWT_SECRET` | Yes | Access token secret |
| `JWT_REFRESH_SECRET` | Yes | Refresh token secret |
| `OPENAI_API_KEY` | Recommended | Tahsin AI responses |
| `CLOUDINARY_*` | Optional | Photo/video upload |
| `SMTP_*` | Optional | Email verification |

## License

Private — built for Raisa with love.
