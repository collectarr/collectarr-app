<#
.SYNOPSIS
    Reset the local Drift database and (optionally) run the app.

.DESCRIPTION
    1. Kills lingering collectarr dart / flutter processes that hold the DB lock.
    2. Deletes collectarr.sqlite from the Documents folder.
    3. Optionally seeds the complete typed-kind development fixture.
    4. Optionally runs `flutter run -d windows` afterwards.

.PARAMETER Run
    When set, launches the app after the reset.

.PARAMETER Clean
    When set, also runs `flutter clean` + `flutter pub get` before launching.

.PARAMETER Seed
    When set, runs the checked-in typed-kind seed and verification script after
    the reset. Use with -Run to open the app with the fixture already loaded.

.EXAMPLE
    .\scripts\reset_and_run.ps1            # just reset DB
    .\scripts\reset_and_run.ps1 -Run       # reset DB + run app
    .\scripts\reset_and_run.ps1 -Run -Clean # full clean build + run
#>
[CmdletBinding()]
param(
    [switch]$Run,
    [switch]$Clean,
    [switch]$Seed
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot

if ($Seed -and -not (Get-Command dart -ErrorAction SilentlyContinue)) {
    throw "Dart is not available in PATH; cannot seed the local database."
}

# --- 1. Kill lingering workspace processes ---
$workspaceRoot = [IO.Path]::GetFullPath($projectRoot).TrimEnd('\')
$processNames = @('dart', 'flutter', 'collectarr_app')
$workspaceProcesses = Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
    Where-Object {
        $processNames -contains $_.Name.TrimEnd('.exe') -and
        (
            ($_.ExecutablePath -and $_.ExecutablePath.StartsWith($workspaceRoot, [StringComparison]::OrdinalIgnoreCase)) -or
            ($_.CommandLine -and $_.CommandLine.IndexOf($workspaceRoot, [StringComparison]::OrdinalIgnoreCase) -ge 0)
        )
    }

if ($workspaceProcesses) {
    Write-Host "[reset] Killing $($workspaceProcesses.Count) collectarr process(es)..." -ForegroundColor Yellow
    $workspaceProcesses | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
    Start-Sleep -Milliseconds 500
} else {
    Write-Host "[reset] No lingering collectarr processes." -ForegroundColor Green
}

# --- 2. Delete the local Drift database ---
$dbPath = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'collectarr.sqlite'
if (Test-Path -LiteralPath $dbPath) {
    Remove-Item -LiteralPath $dbPath -Force
    Write-Host "[reset] Deleted $dbPath" -ForegroundColor Green
} else {
    Write-Host "[reset] DB not found at $dbPath (already clean)." -ForegroundColor Green
}

# Also clean SQLite's journal sidecars if they exist.
foreach ($suffix in @('-wal', '-shm', '-journal')) {
    $sidecar = "$dbPath$suffix"
    if (Test-Path -LiteralPath $sidecar) {
        Remove-Item -LiteralPath $sidecar -Force
        Write-Host "[reset] Deleted sidecar $sidecar" -ForegroundColor Green
    }
}

# --- 3. Optional: clean build artifacts ---
if ($Clean) {
    Write-Host "[reset] Running flutter clean..." -ForegroundColor Cyan
    Push-Location $projectRoot
    try {
        & flutter clean
        if ($LASTEXITCODE -ne 0) {
            throw "flutter clean failed with exit code $LASTEXITCODE."
        }
        & flutter pub get
        if ($LASTEXITCODE -ne 0) {
            throw "flutter pub get failed with exit code $LASTEXITCODE."
        }
    } finally {
        Pop-Location
    }
}

# --- 4. Optional: seed the typed-kind development fixture ---
if ($Seed) {
    Write-Host "[reset] Seeding typed-kind development fixture..." -ForegroundColor Cyan
    Push-Location $projectRoot
    try {
        & dart run scripts/seed_local_db.dart
        if ($LASTEXITCODE -ne 0) {
            throw "typed-kind seed failed with exit code $LASTEXITCODE."
        }
    } finally {
        Pop-Location
    }
}

# --- 5. Optional: run the app ---
if ($Run) {
    Write-Host "[reset] Launching app..." -ForegroundColor Cyan
    Push-Location $projectRoot
    try {
        & flutter run -d windows
        if ($LASTEXITCODE -ne 0) {
            throw "flutter run failed with exit code $LASTEXITCODE."
        }
    } finally {
        Pop-Location
    }
}

Write-Host "[reset] Done." -ForegroundColor Green
