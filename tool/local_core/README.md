# Local Music Core for UI testing

This stack uses separate named volumes under `collectarr-ui-core`. It never
mounts an existing database, backup or the normal development `.env` file.
The local credentials below are fictional and must not be used on a public host.

From the App repository, with Docker Desktop running:

```powershell
docker compose -f tool/local_core/compose.yml up -d
Get-Content tool/local_core/seed.py -Raw | docker compose -f tool/local_core/compose.yml exec -T api python -
```

Core: `http://127.0.0.1:8010` (health: `/api/v1/health`, API explorer: `/docs`).
Image storage: `http://127.0.0.1:9002`.
The prepared local test account is `ui-test@example.com` with password
`CollectarrUiTest2026!`. If starting fresh, register this account first; the
address is an administrator only in this isolated stack. Use the App's Core
server setting and sign in to test Add from Core, link/unlink and corrections.
The seed creates or refreshes only its two fictional albums with stable IDs,
leaving other test rows intact. Its database guard refuses other destinations.
Both albums include edition metadata, artist credits, album/disc credits,
recording details, a CD and a red 180 g vinyl disc, four tracks, composition,
external links, and original generated front/back covers plus thumbnails.
Images are served from this stack's MinIO; no external image host is required.

Search in Add Albums:

| Search | Album(s) |
|---|---|
| `After the Rain` | After the Rain |
| `Northern Lights` | Northern Lights |
| `The Paper Moons` | Both albums |
| `Demo Records` | Both albums |
| `DEMO-001` | After the Rain |
| `DEMO-002` | Northern Lights |
| Barcode `2000000000015` | After the Rain |
| Barcode `2000000000022` | Northern Lights |
| Advanced Artist `The Paper Moons` | Both albums |
| Advanced Record Label `Demo Records` | Both albums |
| Advanced Year `2026` | Both albums |

Each album has CD and Vinyl formats. Format filtering can therefore match both.
The catalog numbers are `DEMO-001` and `DEMO-002`.

Stop the stack without deleting its test data:

```powershell
docker compose -f tool/local_core/compose.yml down
```

Do not use `down --volumes` unless deliberately discarding this test storage.
