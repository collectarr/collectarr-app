param(
  [string]$CoreRepo = "C:\Users\andrvoicu\Desktop\repos\collectarr-core",
  [string]$TargetDir = "C:\Users\andrvoicu\Desktop\repos\collectarr-app\tool\core_contracts"
)

$coreDocs = Join-Path $CoreRepo "docs"
New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null

$copies = @(
  @{ Source = Join-Path $coreDocs "openapi.json"; Target = Join-Path $TargetDir "openapi.json" },
  @{ Source = Join-Path $coreDocs "field-schema.md"; Target = Join-Path $TargetDir "field-schema.md" },
  @{ Source = Join-Path $coreDocs "provider-support.md"; Target = Join-Path $TargetDir "provider-support.md" },
  @{ Source = Join-Path $coreDocs "implementation-plan.md"; Target = Join-Path $TargetDir "implementation-plan.md" }
)

foreach ($copy in $copies) {
  if (Test-Path $copy.Source) {
    Copy-Item -Force $copy.Source $copy.Target
  }
}

@'
{
  "source_repo": "collectarr-core",
  "source_docs_dir": "docs",
  "files": [
    "openapi.json",
    "field-schema.md",
    "provider-support.md",
    "implementation-plan.md"
  ]
}
'@ | Set-Content -Path (Join-Path $TargetDir "contract-manifest.json") -Encoding utf8

@'
{
  "active_kinds": [
    "comic",
    "manga",
    "anime",
    "book",
    "game",
    "boardgame",
    "movie",
    "tv",
    "music"
  ]
}
'@ | Set-Content -Path (Join-Path $TargetDir "active-kinds.json") -Encoding utf8

@'
{
  "book": ["openlibrary", "hardcover"],
  "game": ["igdb"],
  "boardgame": ["bgg"],
  "music": ["musicbrainz"],
  "comic": ["comicvine", "gcd"],
  "manga": ["anilist", "comicvine"],
  "anime": ["anilist", "tmdb"],
  "movie": ["tmdb"],
  "tv": ["tmdb"]
}
'@ | Set-Content -Path (Join-Path $TargetDir "provider-support.json") -Encoding utf8
