# Project Structure

## Backend (`backend/`)

```
backend/
├── src/
│   ├── index.js              # Express app entry
│   ├── config/               # DB + env config
│   ├── controllers/          # Route handlers
│   ├── middleware/           # auth, validate, errors
│   ├── routes/               # API route definitions
│   ├── services/             # Business logic + Tahsin AI
│   ├── jobs/                 # Cron notifications
│   ├── scripts/              # DB migrate
│   └── utils/
├── uploads/                  # Local media fallback
├── .env.example
└── package.json
```

## Frontend (`frontend/`)

```
frontend/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── constants/        # API URLs
│   │   ├── services/         # API, storage, lock, audio, notifications
│   │   ├── theme/            # Light/dark romantic theme
│   │   └── utils/            # Emotion helpers
│   ├── models/
│   ├── providers/            # Riverpod state
│   ├── repositories/         # API data layer
│   ├── router/               # GoRouter
│   ├── screens/
│   │   ├── auth/
│   │   ├── home/
│   │   ├── diary/
│   │   ├── insights/
│   │   ├── settings/
│   │   ├── lock/
│   │   ├── notifications/
│   │   ├── achievements/
│   │   └── calendar/
│   └── widgets/              # Glass UI, particles, Tahsin avatar
├── android/                  # APK build config
├── assets/
│   ├── images/
│   └── audio/
└── pubspec.yaml
```

## Database (`database/`)

- `schema.sql` — users, diary_entries, emotions, ai_replies, notifications, streaks, settings, media_files

## Docs (`docs/`)

- `API.md` — REST endpoints
- `DEPLOYMENT.md` — Production deploy
- `INSTALLATION.md` — Local setup
- `PROJECT_STRUCTURE.md` — This file
