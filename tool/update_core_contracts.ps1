param(
  [string]$CoreRepo,
  [string]$TargetDir
)

$AppRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

if (-not $CoreRepo) {
  $CoreRepo = (Resolve-Path (Join-Path $AppRoot "..\collectarr-core")).Path
}

if (-not $TargetDir) {
  $TargetDir = Join-Path $AppRoot "tool\core_contracts"
}

$coreContracts = Join-Path $CoreRepo "contracts"
if (-not (Test-Path $coreContracts)) {
  throw "Core contract bundle not found at $coreContracts"
}

New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null

$files = @(
  "openapi.json",
  "metadata-field-schema.json",
  "active-kinds.json",
  "provider-support.json",
  "contract-manifest.json"
)

foreach ($file in $files) {
  $source = Join-Path $coreContracts $file
  if (-not (Test-Path $source)) {
    throw "Missing contract file: $source"
  }
  Copy-Item -Force $source (Join-Path $TargetDir $file)
}
