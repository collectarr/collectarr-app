<#
.SYNOPSIS
    Reset the local Drift database and (optionally) run the app.

.DESCRIPTION
    1. Kills lingering collectarr dart / flutter processes that hold the DB lock.
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
