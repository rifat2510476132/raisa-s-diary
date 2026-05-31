# Packages the full project into a ZIP (excludes node_modules, build artifacts)
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$dist = Join-Path $root "dist"
$zipName = "jannatul-maowa-raisa-diary.zip"
$zipPath = Join-Path $dist $zipName
$staging = Join-Path $dist "staging"

if (Test-Path $staging) { Remove-Item $staging -Recurse -Force }
New-Item -ItemType Directory -Path $staging -Force | Out-Null
New-Item -ItemType Directory -Path $dist -Force | Out-Null

$excludeDirs = @(
    "node_modules",
    ".dart_tool",
    "build",
    ".git",
    "dist",
    "uploads"
)

function Copy-ProjectTree {
    param([string]$Source, [string]$Dest)
    Get-ChildItem -Path $Source -Force | ForEach-Object {
        if ($excludeDirs -contains $_.Name) { return }
        $target = Join-Path $Dest $_.Name
        if ($_.PSIsContainer) {
            New-Item -ItemType Directory -Path $target -Force | Out-Null
            Copy-ProjectTree -Source $_.FullName -Dest $target
        } else {
            Copy-Item $_.FullName -Destination $target -Force
        }
    }
}

Copy-ProjectTree -Source $root -Dest $staging

if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
Compress-Archive -Path (Join-Path $staging "*") -DestinationPath $zipPath -Force
Remove-Item $staging -Recurse -Force

Write-Host "Created: $zipPath"
Write-Host "Size: $((Get-Item $zipPath).Length / 1MB) MB"
