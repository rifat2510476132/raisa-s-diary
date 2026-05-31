# Installation Guide — Jannatul Maowa Raisa's Diary

Complete setup for database, backend API, and Flutter mobile app (APK).

## Requirements

| Tool | Version |
|------|---------|
| Node.js | 18+ |
| PostgreSQL | 14+ |
| Flutter SDK | 3.16+ |
| Android Studio | Latest (SDK + emulator) |
| OpenAI API key | Recommended |

## 1. Clone & folder layout

```
jannatul-maowa-raisa-diary/
├── backend/       # Express API
├── frontend/      # Flutter app
├── database/      # schema.sql
├── docs/          # Guides
├── assets/        # Shared branding
└── scripts/       # ZIP packaging
```

## 2. PostgreSQL database

```powershell
psql -U postgres -c "CREATE DATABASE raisa_diary;"
psql -U postgres -d raisa_diary -f database\schema.sql
```

## 3. Backend API

```powershell
cd backend
copy .env.example .env
```

Edit `.env`:

```env
DATABASE_URL=postgresql://postgres:YOUR_PASSWORD@localhost:5432/raisa_diary
JWT_SECRET=use-a-long-random-string-at-least-32-chars
JWT_REFRESH_SECRET=another-long-random-string
OPENAI_API_KEY=sk-your-key
PORT=3000
```

```powershell
npm install
npm run dev
```

Verify: http://localhost:3000/api/health

## 4. Flutter frontend

Install [Flutter](https://docs.flutter.dev/get-started/install) and add to PATH.

```powershell
cd frontend
flutter pub get
```

### Android `local.properties`

Copy `android\local.properties.example` to `android\local.properties` and set:

```
sdk.dir=C:\\Users\\YOU\\AppData\\Local\\Android\\sdk
flutter.sdk=C:\\path\\to\\flutter
```

### Run on emulator

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
```

### Run on physical phone (same Wi‑Fi)

Replace with your PC LAN IP:

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000/api
```

## 5. Build release APK

```powershell
cd frontend
flutter build apk --release --dart-define=API_BASE_URL=http://YOUR_SERVER:3000/api
```

APK path:

`frontend\build\app\outputs\flutter-apk\app-release.apk`

## 6. Optional: Docker database

```powershell
docker compose up -d
```

Then point `DATABASE_URL` at the container.

## 7. Package project ZIP

```powershell
.\scripts\package-project.ps1
```

Output: `dist\jannatul-maowa-raisa-diary.zip`

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `flutter` not found | Add Flutter `bin` to PATH |
| Network error on phone | Use LAN IP, allow firewall port 3000 |
| Gradle fails | Set `sdk.dir` in `local.properties` |
| Tahsin generic replies | Set `OPENAI_API_KEY` in backend `.env` |
| Biometrics fail | Use a real device; enable lock screen |
