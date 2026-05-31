# Flutter App — Raisa's Diary

Premium emotional diary UI with **Tahsin** AI companion.

## Run

```powershell
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
```

## Build APK

```powershell
flutter build apk --release --dart-define=API_BASE_URL=https://your-api.com/api
```

## Key screens

| Screen | Route |
|--------|-------|
| Splash / Onboarding | `/splash`, `/onboarding` |
| Auth | `/login`, `/register`, `/forgot` |
| Home shell | `/home` (tabs: Home, Diary, Insights, Settings) |
| Write diary | `/write` |
| Notifications | `/notifications` |
| Achievements | `/achievements` |
| Mood calendar | `/mood-calendar` |
| PIN / Biometric lock | `/lock` |

## Assets

- `assets/images/` — branding, Tahsin avatar (add `tahsin.png` optional)
- `assets/audio/calm.mp3` — background music (optional)

## State management

Riverpod providers in `lib/providers/providers.dart`.
