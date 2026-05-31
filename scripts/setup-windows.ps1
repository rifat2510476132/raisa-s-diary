# Setup script for Windows
param(
    [string]$DbPassword = "postgres"
)

$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Write-Host "Setting up Raisa's Diary at $Root" -ForegroundColor Magenta

# Backend
Set-Location "$Root\backend"
if (-not (Test-Path ".env")) {
    Copy-Item ".env.example" ".env"
    Write-Host "Created backend\.env - please edit with your secrets" -ForegroundColor Yellow
}
npm install
if ($LASTEXITCODE -ne 0) { exit 1 }

# Database hint
Write-Host "`nDatabase setup:" -ForegroundColor Cyan
Write-Host "  psql -U postgres -c `"CREATE DATABASE raisa_diary;`""
Write-Host "  psql -U postgres -d raisa_diary -f `"$Root\database\schema.sql`""
Write-Host "  Or: npm run db:migrate (from backend folder)"

# Flutter
Set-Location "$Root\frontend"
if (Get-Command flutter -ErrorAction SilentlyContinue) {
    flutter pub get
    Write-Host "Flutter dependencies installed." -ForegroundColor Green
} else {
    Write-Host "Flutter not found in PATH. Install from https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Yellow
}

Write-Host "`nDone! Start backend: cd backend; npm run dev" -ForegroundColor Green
Write-Host "Run app: cd frontend; flutter run" -ForegroundColor Green
