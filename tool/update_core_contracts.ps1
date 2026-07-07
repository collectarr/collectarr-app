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

# Validate that the copied payload matches the hashes recorded in the manifest.
# This catches partial copies or a stale manifest before they reach the app.
$manifestPath = Join-Path $TargetDir "contract-manifest.json"
$manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
$hashKeyByFile = @{
  "openapi.json"               = "openApiHash"
  "metadata-field-schema.json" = "fieldSchemaHash"
  "active-kinds.json"          = "activeKindsHash"
  "provider-support.json"      = "providerSupportHash"
}

foreach ($entry in $hashKeyByFile.GetEnumerator()) {
  $target = Join-Path $TargetDir $entry.Key
  $actual = (Get-FileHash $target -Algorithm SHA256).Hash.ToLower()
  $expected = ([string]$manifest.$($entry.Value)).ToLower()
  if ($actual -ne $expected) {
    throw "Contract drift: $($entry.Key) hash $actual does not match manifest.$($entry.Value) $expected"
  }
}

Write-Host "Core contracts synced and verified against contract-manifest.json"
