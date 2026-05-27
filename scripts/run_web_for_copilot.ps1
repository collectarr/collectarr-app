<#
.SYNOPSIS
    Runs collectarr-app on Flutter Web in a predictable local URL for Copilot browser sharing.

.DESCRIPTION
    - Starts `flutter run` for a web device on 127.0.0.1 and a fixed port.
    - Opens the app URL in your default browser.
    - Prints the exact URL to share in Copilot Chat browser tools.

    Note:
    A local script cannot force Copilot attachment by itself.
    Attachment is done from the active chat session when the page is shared.

.EXAMPLE
    .\scripts\run_web_for_copilot.ps1

.EXAMPLE
    .\scripts\run_web_for_copilot.ps1 -Port 7357 -Device chrome -Route /libraries

.EXAMPLE
    .\scripts\run_web_for_copilot.ps1 -NoOpen
#>
[CmdletBinding()]
param(
    [ValidateSet('chrome', 'edge')]
    [string]$Device = 'chrome',

    [int]$Port = 7357,

    [string]$HostName = '127.0.0.1',

    [string]$Route = '/libraries',

    [switch]$NoOpen
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    throw "Flutter is not available in PATH."
}

$routePath = if ([string]::IsNullOrWhiteSpace($Route)) { '/libraries' } else { $Route }
if (-not $routePath.StartsWith('/')) {
    $routePath = "/$routePath"
}

$url = "http://$HostName`:$Port/#$routePath"

Write-Host "[web] Project: $projectRoot" -ForegroundColor Cyan
Write-Host "[web] URL:     $url" -ForegroundColor Cyan
Write-Host "[web] Device:  $Device" -ForegroundColor Cyan

$flutterArgs = @(
    'run',
    '-d', $Device,
    '--web-hostname', $HostName,
    '--web-port', $Port,
    '--web-launch-url', $url
)

# Start flutter run in a separate PowerShell window so this script can return quickly.
$argLine = "Set-Location '$projectRoot'; flutter " + ($flutterArgs -join ' ')
Start-Process -FilePath 'pwsh' -ArgumentList '-NoExit', '-Command', $argLine -WorkingDirectory $projectRoot | Out-Null

if (-not $NoOpen) {
    Start-Process $url | Out-Null
}

Write-Host "[web] Flutter Web was started in a new terminal window." -ForegroundColor Green
Write-Host "[copilot] In chat, share/open this page URL so I can attach browser tools:" -ForegroundColor Yellow
Write-Host "          $url" -ForegroundColor Yellow
