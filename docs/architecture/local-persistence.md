# Local persistence architecture

`lib/core/db/local_database.dart` is the Drift composition root. It contains
the database declaration and migration orchestration; it does not own kind
semantics.

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
