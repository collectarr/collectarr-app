# Local persistence architecture

`lib/core/db/local_database.dart` is the Drift composition root. It declares
schema version 4, creates all registered tables for new databases, and applies
the upgrades below for existing databases. It does not own kind semantics.

The current upgrade path is:

- v1 → v2 adds Music partial-date columns and the artist-credit and label
  tables.
- v2 → v3 adds the Music release-image table.
- v3 to v4 removes the unused Music release-group synopsis column.
- Upgrading from v1 applies all three steps in order.

Kind tables and local mappers live beside their kind repositories:

```text
library/kinds/comic/data/local/
library/kinds/manga/data/local/
library/kinds/book/data/local/
library/kinds/game/data/local/
library/kinds/boardgame/data/local/
library/kinds/movie/data/local/
library/kinds/tv/data/local/
library/kinds/anime/data/local/
library/kinds/music/data/local/
```

The composition root may list every table because that is schema composition,
not a shared semantic model. Universal tables cover genuinely universal
personal state such as locations, ownership, sync, and tracking entries.

The DB schema ownership and typed local mapping boundaries are guarded by
`test/architecture/db_schema_ownership_test.dart` and the per-kind persistence
contracts.
