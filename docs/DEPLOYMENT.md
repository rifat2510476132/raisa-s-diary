# Deployment Guide

## Backend (Production)

### Option A: Railway / Render / Fly.io

1. Push repo to GitHub
2. Create PostgreSQL add-on
3. Set environment variables from `backend/.env.example`
4. Build command: `cd backend && npm install`
5. Start command: `cd backend && npm start`
6. Run migration once: `npm run db:migrate`

### Option B: VPS (Ubuntu)

```bash
sudo apt update && sudo apt install -y nodejs npm postgresql nginx
git clone <your-repo> /var/www/raisa-diary
cd /var/www/raisa-diary/backend
npm install --production
cp .env.example .env
# edit .env
npm run db:migrate
```

PM2 process manager:

```bash
npm install -g pm2
pm2 start src/index.js --name raisa-api
pm2 save
pm2 startup
```

Nginx reverse proxy (`/etc/nginx/sites-available/raisa-api`):

```nginx
server {
    listen 80;
    server_name api.yourdomain.com;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

Enable HTTPS with Certbot:

```bash
sudo certbot --nginx -d api.yourdomain.com
```

## Database

- Use managed PostgreSQL (Supabase, Neon, RDS) in production
- Enable SSL: set `NODE_ENV=production` (SSL enabled in pool config)
- Regular backups via provider

## Flutter / Play Store

1. Update `API_BASE_URL` to production HTTPS API
2. Configure signing in `android/app/build.gradle`
3. Create keystore:

```bash
keytool -genkey -v -keystore raisa-diary-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias raisa
```

4. Add `android/key.properties` (do not commit)
5. `flutter build appbundle --release`
6. Upload AAB to Google Play Console

## Security checklist

- [ ] Strong `JWT_SECRET` and `JWT_REFRESH_SECRET`
- [ ] HTTPS only in production
- [ ] Rate limiting enabled (default 200 req/15min)
- [ ] OpenAI key only on server
- [ ] CORS restricted to app domains in production
- [ ] PostgreSQL credentials rotated

## Monitoring

- Health endpoint: `GET /api/health`
- Log aggregation: PM2 logs, Datadog, or CloudWatch
- Set alerts on 5xx error rate
