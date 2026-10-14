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
The seed inserts two fictional albums with stable IDs and leaves existing test
rows intact. Its database guard refuses other destinations.

Stop the stack without deleting its test data:

```powershell
docker compose -f tool/local_core/compose.yml down
```

Do not use `down --volumes` unless deliberately discarding this test storage.
