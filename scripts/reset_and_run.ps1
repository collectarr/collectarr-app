<#
.SYNOPSIS
    Reset the local Drift database and (optionally) run the app.

.DESCRIPTION
    1. Kills any lingering dart / flutter processes that hold the DB lock.
    2. Deletes collectarr.sqlite from the Documents folder.
    3. Optionally runs `flutter run -d windows` afterwards.

.PARAMETER Run
    When set, launches the app after the reset.

.PARAMETER Clean
    When set, also runs `flutter clean` + `flutter pub get` before launching.

.EXAMPLE
    .\scripts\reset_and_run.ps1            # just reset DB
    .\scripts\reset_and_run.ps1 -Run       # reset DB + run app
    .\scripts\reset_and_run.ps1 -Run -Clean # full clean build + run
#>
[CmdletBinding()]
param(
    [switch]$Run,
    [switch]$Clean
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot

# --- 1. Kill lingering dart processes ---
$dartProcs = Get-Process -Name dart -ErrorAction SilentlyContinue
if ($dartProcs) {
    Write-Host "[reset] Killing $($dartProcs.Count) dart process(es)..." -ForegroundColor Yellow
    $dartProcs | Stop-Process -Force
    Start-Sleep -Milliseconds 500
} else {
    Write-Host "[reset] No lingering dart processes." -ForegroundColor Green
}

# --- 2. Delete the local Drift database ---
$dbPath = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'collectarr.sqlite'
if (Test-Path $dbPath) {
    Remove-Item $dbPath -Force
    Write-Host "[reset] Deleted $dbPath" -ForegroundColor Green
} else {
    Write-Host "[reset] DB not found at $dbPath (already clean)." -ForegroundColor Green
}

# Also clean the -wal and -shm sidecar files if they exist
foreach ($ext in @('.sqlite-wal', '.sqlite-shm')) {
    $sidecar = $dbPath.Replace('.sqlite', $ext)
    if (Test-Path $sidecar) {
        Remove-Item $sidecar -Force
        Write-Host "[reset] Deleted sidecar $sidecar" -ForegroundColor Green
    }
}

# --- 3. Optional: clean build artifacts ---
if ($Clean) {
    Write-Host "[reset] Running flutter clean..." -ForegroundColor Cyan
    Push-Location $projectRoot
    flutter clean
    flutter pub get
    Pop-Location
}

# --- 4. Optional: run the app ---
if ($Run) {
    Write-Host "[reset] Launching app..." -ForegroundColor Cyan
    Push-Location $projectRoot
    flutter run -d windows
    Pop-Location
}

Write-Host "[reset] Done." -ForegroundColor Green
