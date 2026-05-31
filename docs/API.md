# API Reference

Base URL: `http://localhost:3000/api`

## Authentication

| Method | Endpoint | Body | Auth |
|--------|----------|------|------|
| POST | `/auth/register` | `{ email, password, displayName? }` | No |
| POST | `/auth/login` | `{ email, password }` | No |
| POST | `/auth/refresh` | `{ refreshToken }` | No |
| POST | `/auth/forgot-password` | `{ email }` | No |
| POST | `/auth/reset-password` | `{ token, password }` | No |
| GET | `/auth/verify/:token` | — | No |
| GET | `/auth/profile` | — | Bearer |

## Diary

| Method | Endpoint | Body | Auth |
|--------|----------|------|------|
| POST | `/diary` | `{ content, title?, moodSticker?, mediaIds? }` | Bearer |
| GET | `/diary` | `?page=1&limit=20` | Bearer |
| GET | `/diary/:id` | — | Bearer |
| DELETE | `/diary/:id` | — | Bearer |
| GET | `/diary/tahsin-message` | — | Bearer |
| GET | `/diary/emotions/stats` | `?days=30` | Bearer |
| GET | `/diary/mood-calendar` | `?year=2026&month=5` | Bearer |

## Settings

| Method | Endpoint | Body | Auth |
|--------|----------|------|------|
| GET | `/settings` | — | Bearer |
| PATCH | `/settings` | `{ theme, ai_intensity, ... }` | Bearer |
| GET | `/settings/streak` | — | Bearer |
| GET | `/settings/achievements` | — | Bearer |
| POST | `/settings/pin` | `{ pin }` | Bearer |
| POST | `/settings/pin/verify` | `{ pin }` | Bearer |

## Notifications

| Method | Endpoint | Auth |
|--------|----------|------|
| GET | `/notifications` | Bearer |
| PATCH | `/notifications/:id/read` | Bearer |
| PATCH | `/notifications/read-all` | Bearer |
| POST | `/notifications/device` | Bearer |

## Media

| Method | Endpoint | Auth |
|--------|----------|------|
| POST | `/media/upload` | Bearer (multipart `file`, `mediaType`) |
| DELETE | `/media/:id` | Bearer |

## Health

`GET /api/health` — no auth required.
