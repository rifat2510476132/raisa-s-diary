#!/usr/bin/env bash
# Netlify CI build — installs Flutter and builds web release
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/frontend"

FLUTTER_VERSION="${FLUTTER_VERSION:-3.24.5}"
FLUTTER_DIR="${FLUTTER_ROOT:-/opt/flutter}"

if [ ! -f "$FLUTTER_DIR/bin/flutter" ]; then
  echo ">>> Installing Flutter $FLUTTER_VERSION..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$FLUTTER_DIR"
  cd "$FLUTTER_DIR"
  git fetch --depth 1 origin "${FLUTTER_VERSION}" 2>/dev/null || true
  git checkout "${FLUTTER_VERSION}" 2>/dev/null || git checkout stable
  cd "$ROOT/frontend"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"
flutter --version
flutter config --enable-web --no-analytics
flutter precache --web

# Missing web/icons (first deploy)
if [ ! -f "web/icons/Icon-192.png" ]; then
  echo ">>> Adding default web platform files..."
  flutter create . --platforms=web --org com.raisadiary --project-name raisa_diary
fi

flutter pub get

API_URL="${API_BASE_URL:-https://raisa-diary-api.onrender.com/api}"
echo ">>> Building web with API_BASE_URL=$API_URL"

flutter build web --release --dart-define=API_BASE_URL="$API_URL"

echo ">>> Build done: frontend/build/web"
