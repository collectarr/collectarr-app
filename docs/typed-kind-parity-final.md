# Typed-kind parity final

Audit basis: `flutter test test/domain`, the all-kind contract matrix, the
release/tracking/provider matrices, and the architecture contract suite.

| Area | Comic | Manga | Book | Game | BoardGame | Movie | TV | Anime | Music |
|---|---|---|---|---|---|---|---|---|---|
| Core DTO mapping | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Core field policy | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Media domain | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Release domain | PASS | N/A | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Owned details | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Tracking domain | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Media local DB | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Release local DB | PASS | N/A | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Owned local DB | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Tracking local DB | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Repository | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Workspace | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Fields | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Columns | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Sorts | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Groups | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Facets | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Vocabularies | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Add schema | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Media Edit schema | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Release Edit schema | PASS | N/A | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Owned Edit schema | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Hierarchy | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Provider integrations | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Provider dependency direction | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Stats | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Value | PASS | N/A | N/A | N/A | N/A | PASS | N/A | N/A | N/A |
| Mandatory contracts | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| Capability contracts | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| No cross-kind imports | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |
| No erased catalog metadata | FAIL | FAIL | FAIL | FAIL | FAIL | FAIL | FAIL | FAIL | FAIL |
| No false-common domain layer | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS | PASS |

## Global audit status

| Check | Status |
|---|---|
| Nine active kinds are represented | PASS |
| Release participants are explicit | PASS |
| Tracking participants are explicit | PASS |
| Provider-kind pairs are explicit | PASS |
| Domain test suite | PASS |
| No erased catalog metadata | FAIL |

The erased-metadata FAIL is intentional and tracked by PR101/PR122. The
remaining occurrences are migration surfaces and generic transport boundaries;
they are not counted as kind parity until the final deletion pass removes or
reclassifies them.
