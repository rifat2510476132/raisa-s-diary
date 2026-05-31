# Local web build (Netlify এ আপলোড করার আগে টেস্ট)
param(
  [string]$ApiUrl = "http://localhost:3000/api"
)

$ErrorActionPreference = "Stop"
Set-Location "$PSScriptRoot\..\frontend"

flutter config --enable-web
flutter pub get
flutter build web --release --dart-define=API_BASE_URL=$ApiUrl

Write-Host ""
Write-Host "Build ready: frontend\build\web"
Write-Host "Netlify drag-drop: upload the 'build\web' folder"
Write-Host "Or: netlify deploy --prod --dir=build\web"
