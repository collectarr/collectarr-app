# Typed-kind current branch audit

Audit date: 2026-09-05
Branch: `work/typed-kind-full-implementation-plan`
Compared with `main`: `df49cf2a4fda6c70f0025ae8ce99f6123d3083e5`
HEAD: `4625b668` (`test(seeds): validate barcode-ready fixture coverage`)

## Scope and evidence

This is the PR0 rebaseline for the new Full Typed-Kind Vertical Architecture plan. It covers the full `lib/**` production tree, the existing architecture checker, contract tests, kind modules, provider boundaries, persistence, and the seed scripts. Statuses are deliberately stricter than the previous plan: a typed slice is not DONE while a generic semantic bridge, common Owned model, or erased catalog representation remains.

Evidence checked:

- `git diff --name-only main..HEAD`: current branch includes the seed quality guard, Comic export/CSV boundaries, Manga Shelf hierarchy ownership, and de-shared video ownership details.
- `tool/check_library_kind_boundaries.dart`: whole-repository baseline currently reports 541 AST architecture violations; its 392 complexity warnings are informational.
- `test/contracts/**`, `test/architecture/**`, `test/dev/dev_seed_test.dart`, the Comic domain suite, the Collection/Shelf/Stats suites, and the Movie/TV/Anime vertical suites: focused suites pass; the full suite passes at 1870 tests with 5 skipped.
- Barcode contracts execute against all 9 registered kind resolvers; the Add and metadata lookup paths dispatch normalized identifiers through the owning resolver before the API boundary.
- Loan domain/repository consumers now use `OwnedItemRef` canonically; the legacy API `owned_item_id` remains only at the JSON/Drift boundary.
- All checked-in physical seed fixtures now provide a resolver-compatible barcode; the seed quality guard verifies retail/ISBN checksums and the Comic UPC-A supplement format, and the dev seed test verifies persisted rows through kind dispatch.
- Existing audits: `docs/typed-kind-parity-final.md`, `docs/typed-kind-semantic-vacuum-audit.md`, `docs/outside-kinds-generic-audit.md`, and `docs/collectarr_shared_kind_audit.md`.
- Seed coverage: 15 catalog entries for each kind except BoardGame (10), matching owned/tracking fixtures and expanded pick-list vocabulary.

Status meanings:

- `DONE`: the new plan's acceptance shape is already evidenced.
- `PARTIAL`: meaningful implementation exists, but the new invariant still has an explicit bridge/debt item.
- `NOT STARTED`: no coherent implementation for the new task is present.
- `FAIL`: the task has an explicit failing architectural gate.
- `OBSOLETE`: no task is marked obsolete solely because earlier architecture landed; the new plan supersedes the old task ordering and re-audits it.

## PR classification

| PR | Task | Status | Evidence / remaining boundary |
|---:|---|---|---|
| 0 | Branch delta audit | **DONE** | This document records the branch delta, whole-repository baseline, and a status for every PR0-125 task. |
| 1 | Whole-repository semantic boundary checker baseline | **PARTIAL** | The checker now scans relevant production `lib/**` boundaries and reports the migration baseline; allowlists and current violations still need to shrink. |
| 2 | Typed reusable contract-test framework | **PARTIAL** | Reusable contracts now cover repository, workspace, Add/Edit, owned, provider, tracking, actions, import/export, calendar, barcode, and overrides; execution is not yet registered for every applicable kind. |
| 3 | Core DTO adoption checker | **DONE** | Generated-field policies and explicit all-kind contract registrations are present and covered by tests/CI. |
| 4 | All-kind contract manifest | **DONE** | Generated-field policies and explicit all-kind contract registrations are present and covered by tests/CI. |
| 5 | Tiny `LibraryKindRegistration` | **PARTIAL** | A registration boundary exists, but the runtime still exposes erased capability/field surfaces. |
| 6 | Structural repository interfaces | **PARTIAL** | `ReadRepository<TId, TEntity>` now covers all 9 typed media roots with concrete IDs/entities; create/update/delete remain kind-specific by design. |
| 7 | Typed structural `EditSchema` | **DONE** | Structural typed schemas and shared renderers exist and are exercised by contract tests. |
| 8 | Declarative Edit renderer | **DONE** | Structural typed schemas and shared renderers exist and are exercised by contract tests. |
| 9 | Typed structural `AddSchema` | **DONE** | Structural typed schemas and shared renderers exist and are exercised by contract tests. |
| 10 | Declarative Add renderer | **DONE** | Structural typed schemas and shared renderers exist and are exercised by contract tests. |
| 11 | Introduce typed `UiAction<TContext>` | **PARTIAL** | Structural `UiAction<TContext>` and placement contract now exist; the existing runtime-backed toolbar descriptors still need migration to kind-owned typed action registries. |
| 12 | File import/export action contracts | **PARTIAL** | Structural `ExportArtifact`, `ImportPreview`, `ExportAction`, and `ImportAction` contracts now exist; generic file host migration and kind-owned format actions remain. |
| 13 | Action menu host | **PARTIAL** | Generic `ActionMenu<TContext>` now renders typed actions by placement and state; existing Library menus and kind toolbar descriptors still need migration to this host. |
| 14 | Remove canonical common Owned domain | **PARTIAL** | Comic now has a complete typed owned model behind an explicit legacy adapter; the common Owned aggregate and other-kind compatibility remain. |
| 15 | Move tracking fields out of Owned | **PARTIAL** | Comic reading state is now separate from Comic copy state; generic Owned tracking fields and other-kind migrations remain. |
| 16 | Owned action/read projections | **DONE** | `OwnedItemRef` and `OwnedItemSummary` now exist as explicit small cross-kind projections; domain-specific owned details remain outside the projection. |
| 17 | Comic typed domain | **DONE** | ComicMedia, ComicRelease, ComicOwnedItem, and ComicReadingState now have kind-owned typed IDs/models with round-trip and legacy-boundary tests. |
| 18 | Comic Core mapping | **PARTIAL** | `ComicCoreMapper` maps Core DTOs and generic catalog results directly to `ComicMedia`; generic catalog/add and persistence bridges remain outside the canonical path. |
| 19 | Comic local DB | **PARTIAL** | Comic now owns complete `ComicOwnedItemsRows` and `ComicReadingRows` with v27 backfill coverage; the common `OwnedItemsCache` and legacy details table remain during migration. |
| 20 | Comic repository | **DONE** | ComicRepository and ComicOwnedRepository expose typed media/release/owned operations; generic catalog/collection callers remain outside the kind as explicit compatibility bridges. |
| 21 | Comic workspace | **PARTIAL** | `ComicWorkspaceDto.ownedItem`, projector, fields, columns, value, stats, cards, inspector, presentation, and relations now consume typed Comic projections; common workspace projections and global request bridges remain. |
| 22 | Comic Add/Edit | **PARTIAL** | Typed Comic schemas exist; Add results and the Edit host now use canonical `ComicMedia`, while owned edit, generic edit requests, and common renderer bridges remain. |
| 23 | Comic collection actions | **PARTIAL** | ComicInfo export and Comic CSV projection now live under Comic and reach Collection through structural boundaries; CLZ parsing and the remaining generic import/export host are not migrated. |
| 24 | Comic provider integrations | **PARTIAL** | Comic has typed vertical slices and tests, but the new plan still finds erased metadata and generic integration bridges. |
| 25 | Comic calendar/barcode/override contributions | **PARTIAL** | Comic owns a typed barcode resolver and calendar contributor; override contributor/schema work is not complete, while Comic UI owned projections are now typed. |
| 26 | Comic reference contracts | **PARTIAL** | Comic domain, local DB, workspace, edit, seed, and provider tests pass; the reference contract set is not yet fully isolated from common persistence/runtime bridges. |
| 27 | Comic architectural gate | **FAIL** | The reference gate is not green: the checker reports erased metadata and generic Comic semantics outside the owning vertical. |
| 28 | Manga data vertical | **PARTIAL** | All remaining kinds have substantial typed slices and tests, but the stricter full-owned/no-erasure definition is not met. |
| 29 | Manga UX/integration vertical | **PARTIAL** | All remaining kinds have substantial typed slices and tests, but the stricter full-owned/no-erasure definition is not met. |
| 30 | Book data vertical | **PARTIAL** | All remaining kinds have substantial typed slices and tests, but the stricter full-owned/no-erasure definition is not met. |
| 31 | Book UX/integration vertical | **PARTIAL** | All remaining kinds have substantial typed slices and tests, but the stricter full-owned/no-erasure definition is not met. |
| 32 | Game data vertical | **PARTIAL** | All remaining kinds have substantial typed slices and tests, but the stricter full-owned/no-erasure definition is not met. |
| 33 | Game UX/integration vertical | **PARTIAL** | All remaining kinds have substantial typed slices and tests, but the stricter full-owned/no-erasure definition is not met. |
| 34 | BoardGame data vertical | **PARTIAL** | All remaining kinds have substantial typed slices and tests, but the stricter full-owned/no-erasure definition is not met. |
| 35 | BoardGame UX/integration vertical | **PARTIAL** | All remaining kinds have substantial typed slices and tests, but the stricter full-owned/no-erasure definition is not met. |
| 36 | Movie data vertical | **PARTIAL** | All remaining kinds have substantial typed slices and tests, but the stricter full-owned/no-erasure definition is not met. |
| 37 | Movie UX/integration vertical | **PARTIAL** | All remaining kinds have substantial typed slices and tests, but the stricter full-owned/no-erasure definition is not met. |
| 38 | TV data vertical | **PARTIAL** | All remaining kinds have substantial typed slices and tests, but the stricter full-owned/no-erasure definition is not met. |
| 39 | TV UX/integration vertical | **PARTIAL** | All remaining kinds have substantial typed slices and tests, but the stricter full-owned/no-erasure definition is not met. |
| 40 | Anime data vertical | **PARTIAL** | All remaining kinds have substantial typed slices and tests, but the stricter full-owned/no-erasure definition is not met. |
| 41 | Anime UX/integration vertical | **PARTIAL** | All remaining kinds have substantial typed slices and tests, but the stricter full-owned/no-erasure definition is not met. |
| 42 | Music data vertical | **PARTIAL** | All remaining kinds have substantial typed slices and tests, but the stricter full-owned/no-erasure definition is not met. |
| 43 | Music UX/integration vertical | **PARTIAL** | All remaining kinds have substantial typed slices and tests, but the stricter full-owned/no-erasure definition is not met. |
| 44 | Replace CollectionPage hardcoded actions | **PARTIAL** | Collection still owns the Import/Export host controls, but ComicInfo is now supplied as a kind-owned structural export artifact instead of a generic semantic serializer. |
| 45 | Remove semantic global Shelf filters | **PARTIAL** | Global Shelf no longer exposes Missing grade, Key comics, grade/series distributions, or condition/grade row semantics; compatibility aggregates remain for the Stats dashboard. |
| 46 | Split CSV mechanics from CSV semantics | **PARTIAL** | Generic CSV reader/writer mechanics now live in one collection infrastructure module and are used by Collection CSV, TMDB import, and share export; the canonical semantic union row and generic matching remain. |
| 47 | Move CLZ semantics into relevant kinds | **PARTIAL** | Comic CSV layout, aliases, typed parsing, and catalog/owned export semantics now live under Comic; the generic `CollectionCsvRow` mutation adapter and remaining multi-kind host are still compatibility code. |
| 48 | Delete/rehome generic Collection XML | **DONE** | The generic semantic CollectionXml format was deleted; the wizard now exposes Collectarr CSV, CLZ CSV, and kind-contributed exports. |
| 49 | Move ComicInfo.xml into Comic | **DONE** | ComicInfo XML parser/serializer and the export projection now live under Comic; Collection receives only structural export artifacts. |
| 50 | Replace common owned collection commands | **PARTIAL** | ComicInfo export crosses through an explicit Comic owned adapter, but Collection CSV/CLZ commands still use the common Owned command surface. |
| 51 | Delete `CatalogCacheDerivedDataService` | **PARTIAL** | Derived vocabulary capture now delegates metadata projection to explicit kind contributors; generic serial authority and the catalog compatibility repository still remain. |
| 52 | Remove generic `CatalogCacheRepository` | **PARTIAL** | The old generic cache was reduced/renamed, but typed per-kind replacement is not complete and generic repository code remains. |
| 53 | Delete catalog type-erasure stack | **PARTIAL** | Several erased names were deleted, but CatalogItem transport/interoperability and generic metadata bridges remain. |
| 54 | Delete `shelfVolumesProvider` | **DONE** | The generic provider was deleted; Manga now owns hierarchy hydration and the Shelf volume/chapter extension, while Collection receives only a structural widget contribution. |
| 55 | Remove generic `Season`/Volume compatibility APIs | **PARTIAL** | Typed hierarchy work exists, but legacy shelf volume/Season compatibility files are still present. |
| 56 | Remove global item/edition/variant ontology | **NOT STARTED** | No owning-kind override schema/storage interpretation has replaced the global ontology. |
| 57 | Keep only generic override storage/sync mechanics | **NOT STARTED** | No owning-kind override schema/storage interpretation has replaced the global ontology. |
| 58 | Generic calendar becomes event host only | **PARTIAL** | Release projection now leaves the host through registered contributors for all 9 kinds; generic owned/tracking lifecycle events and fallback watch handling remain. |
| 59 | Kind calendar contributors | **PARTIAL** | All 9 kinds have registered release contributors, and TV/Anime additionally own episode projection; generic owned lifecycle and the full contract matrix remain. |
| 60 | Universal calendar contributors | **NOT STARTED** | Calendar remains a host with catalog semantics still represented by generic/legacy paths; contributors are not complete. |
| 61 | Keep scanner generic | **DONE** | Scanner UI and platform mechanics now return the generic `ScannedCode` projection with raw value, normalized value, and symbology. |
| 62 | Kind-owned identifier resolvers | **DONE** | All 9 applicable kinds implement the structural resolver contract, are explicitly registered, and Add/metadata lookup dispatches normalized values through the owning resolver. |
| 63 | Loans use `OwnedItemRef` | **PARTIAL** | `Loan.ownedRef` is now canonical and repository/UI consumers use it; the legacy `owned_item_id` transport column and generic owned-item loading remain at compatibility boundaries. |
| 64 | Collapse duplicate pick-list infrastructure | **DONE** | Repository, options, editor, vocabulary contracts, and vocabulary repository now live under `features/pick_lists`; old Collection paths are export-only compatibility shims, and production imports use the canonical namespace. |
| 65 | All concrete vocabularies stay kind-owned | **DONE** | Kind-specific condition/grade definitions and all other concrete vocabulary definitions are owned by the corresponding kind and reach the generic host through explicit contributors; only genuinely cross-kind tags, people, acquisition, and loan vocabularies remain global. |
| 66 | Separate personal imports from metadata imports | **PARTIAL** | Provider personal sync and import orchestration have typed pieces, while metadata import semantics still cross generic feature boundaries. |
| 67 | Generic import infrastructure becomes orchestration-only | **PARTIAL** | Provider personal sync and import orchestration have typed pieces, while metadata import semantics still cross generic feature boundaries. |
| 68 | Activity as projected events | **PARTIAL** | Projected activity/admin/settings infrastructure exists, but feature-specific semantic contributors are not fully separated. |
| 69 | Admin kind-specific screens/actions | **PARTIAL** | Projected activity/admin/settings infrastructure exists, but feature-specific semantic contributors are not fully separated. |
| 70 | Kind-specific settings contributions | **PARTIAL** | Projected activity/admin/settings infrastructure exists, but feature-specific semantic contributors are not fully separated. |
| 71 | Define genuinely universal tracking infrastructure | **PARTIAL** | Typed tracking models and TV/Anime storage exist, but generic tracking compatibility and full per-kind ownership remain. |
| 72 | Full kind-owned tracking state | **PARTIAL** | Typed tracking models and TV/Anime storage exist, but generic tracking compatibility and full per-kind ownership remain. |
| 73 | Move watch/custom episode storage | **PARTIAL** | Typed tracking models and TV/Anime storage exist, but generic tracking compatibility and full per-kind ownership remain. |
| 74 | Classify every `_shared` file | **PARTIAL** | The shared-kind audit exists, but the new allowed classification is stricter than the current _shared contents. |
| 75 | De-share Video | **PARTIAL** | Movie, TV, and Anime now own independent physical-copy detail models; generic Collection/Detail/Inspector code no longer reads shared video semantics. Shared video edit/catalog/tracking compatibility remains. |
| 76 | De-share publishing/serial domains | **NOT STARTED** | Shared video and publishing/serial semantic abstractions still exist or remain in compatibility locations. |
| 77 | Per-kind Library toolbar actions | **NOT STARTED** | Typed toolbar, row, and bulk action declarations are not yet the single source for all kind actions. |
| 78 | Typed row/item actions | **NOT STARTED** | Typed toolbar, row, and bulk action declarations are not yet the single source for all kind actions. |
| 79 | Typed bulk actions | **NOT STARTED** | Typed toolbar, row, and bulk action declarations are not yet the single source for all kind actions. |
| 80 | Provider search summary only | **DONE** | ProviderSearchHit is a compact summary and provider mapping contracts cover the current provider matrix. |
| 81 | Kind-owned provider metadata resolution | **PARTIAL** | Kind-owned provider mappers exist, but generic add/metadata bridge callers remain. |
| 82 | Remove normalized provider metadata god model | **PARTIAL** | The normalized envelope is quarantined/covered, but has not been deleted. |
| 83 | Personal sync cleanup | **PARTIAL** | ProviderPersonalEntry and sync policy tests exist; a full canonical cleanup and parity audit remain. |
| 84 | Sync policy parity | **PARTIAL** | ProviderPersonalEntry and sync policy tests exist; a full canonical cleanup and parity audit remain. |
| 85 | `LocalDatabase` becomes composition root | **PARTIAL** | LocalDatabase remains the composition root and now includes the typed kind tables plus structural loan reference migration; final semantic-column enforcement remains. |
| 86 | Kind DB ownership checker | **PARTIAL** | Kind tables and ownership tests exist, but LocalDatabase/production DB composition still needs the final ownership gate. |
| 87 | Delete giant `LibraryKindRuntime` | **PARTIAL** | Dispatch uses registrations, but the giant runtime and generic capability forwarding are still present. |
| 88 | Cross-kind summaries only | **DONE** | The intentionally small cross-kind projections CatalogSearchHit, OwnedItemRef/Summary, and ProviderSearchHit exist. |
| 89 | Library metrics system | **PARTIAL** | Library metrics, typography, result-table, selection, and visual contracts exist; action visual standardization is not yet complete everywhere. |
| 90 | Typography system | **PARTIAL** | Library metrics, typography, result-table, selection, and visual contracts exist; action visual standardization is not yet complete everywhere. |
| 91 | Shared generic result table | **PARTIAL** | Library metrics, typography, result-table, selection, and visual contracts exist; action visual standardization is not yet complete everywhere. |
| 92 | Standard selection controls | **PARTIAL** | Library metrics, typography, result-table, selection, and visual contracts exist; action visual standardization is not yet complete everywhere. |
| 93 | Shared action visuals | **PARTIAL** | Library metrics, typography, result-table, selection, and visual contracts exist; action visual standardization is not yet complete everywhere. |
| 94 | Mandatory contracts all 9 kinds | **PARTIAL** | Core/add/edit/release/tracking/provider contracts exist; barcode coverage now executes for all 9 kinds, while action/calendar/override coverage remains incomplete. |
| 95 | Release/Edition contracts | **PARTIAL** | Core/add/edit/release/tracking/provider contracts exist, but action/calendar/barcode/override contract coverage is incomplete. |
| 96 | Action contracts | **PARTIAL** | Core/add/edit/release/tracking/provider contracts exist, but action/calendar/barcode/override contract coverage is incomplete. |
| 97 | Calendar contracts | **PARTIAL** | Release contributor behavior is tested across all 9 kind contributors plus TV/Anime episode behavior and stable event identities; a reusable full calendar contract remains. |
| 98 | Barcode contracts | **DONE** | The reusable barcode contract executes against all 9 registered resolvers and dispatch tests cover normalization, supported/unsupported values, and unknown-kind behavior. |
| 99 | Metadata override contracts | **PARTIAL** | Core/add/edit/release/tracking/provider contracts exist, but action/calendar/barcode/override contract coverage is incomplete. |
| 100 | Provider-kind contracts | **PARTIAL** | Core/add/edit/release/tracking/provider contracts exist, but action/calendar/barcode/override contract coverage is incomplete. |
| 101 | Comic semantics | **DONE** | Kind-specific domain test suites exist for the listed semantics and the full test suite currently passes. |
| 102 | Manga semantics | **DONE** | Kind-specific domain test suites exist for the listed semantics and the full test suite currently passes. |
| 103 | Book semantics | **DONE** | Kind-specific domain test suites exist for the listed semantics and the full test suite currently passes. |
| 104 | Game semantics | **DONE** | Kind-specific domain test suites exist for the listed semantics and the full test suite currently passes. |
| 105 | BoardGame semantics | **DONE** | Kind-specific domain test suites exist for the listed semantics and the full test suite currently passes. |
| 106 | Movie semantics | **DONE** | Kind-specific domain test suites exist for the listed semantics and the full test suite currently passes. |
| 107 | TV semantics | **DONE** | Kind-specific domain test suites exist for the listed semantics and the full test suite currently passes. |
| 108 | Anime semantics | **DONE** | Kind-specific domain test suites exist for the listed semantics and the full test suite currently passes. |
| 109 | Music semantics | **DONE** | Kind-specific domain test suites exist for the listed semantics and the full test suite currently passes. |
| 110 | Cross-kind dependency enforcement | **PARTIAL** | Several architecture guards exist, but the current whole-repository checker reports 541 violations and still has migration allowlists. |
| 111 | Provider dependency enforcement | **PARTIAL** | Several architecture guards exist, but the current whole-repository checker reports 541 violations and still has migration allowlists. |
| 112 | Core DTO ownership enforcement | **PARTIAL** | Several architecture guards exist, but the current whole-repository checker reports 541 violations and still has migration allowlists. |
| 113 | Type-erasure enforcement | **PARTIAL** | Several architecture guards exist, but the current whole-repository checker reports 541 violations and still has migration allowlists. |
| 114 | Semantic action enforcement | **PARTIAL** | Several architecture guards exist, but the current whole-repository checker reports 541 violations and still has migration allowlists. |
| 115 | DB ownership enforcement | **PARTIAL** | Several architecture guards exist, but the current whole-repository checker reports 541 violations and still has migration allowlists. |
| 116 | Declarative Add/Edit ownership enforcement | **PARTIAL** | Several architecture guards exist, but the current whole-repository checker reports 541 violations and still has migration allowlists. |
| 117 | Catalog deletions | **PARTIAL** | Delete-only work has removed multiple legacy surfaces, while catalog/Owned/edit/hierarchy compatibility remains. |
| 118 | Owned deletions | **PARTIAL** | Delete-only work has removed multiple legacy surfaces, while catalog/Owned/edit/hierarchy compatibility remains. |
| 119 | Edit/Add deletions | **PARTIAL** | Delete-only work has removed multiple legacy surfaces, while catalog/Owned/edit/hierarchy compatibility remains. |
| 120 | Collection legacy deletions | **PARTIAL** | Delete-only work has removed multiple legacy surfaces, while catalog/Owned/edit/hierarchy compatibility remains. |
| 121 | Hierarchy/tracking deletions | **PARTIAL** | Delete-only work has removed multiple legacy surfaces, while catalog/Owned/edit/hierarchy compatibility remains. |
| 122 | Compatibility sweep | **NOT STARTED** | The new full compatibility sweep has not yet been performed against all surviving compatibility markers. |
| 123 | Full vertical ownership matrix | **PARTIAL** | A previous parity report exists, but it records erased metadata as FAIL under the new invariants. |
| 124 | Whole `lib/` semantic vacuum audit | **PARTIAL** | The existing semantic audit is not yet a zero-unexplained-violation scan of all lib/**. |
| 125 | Final documentation | **PARTIAL** | Several architecture documents exist, but the new required final documentation set is not complete. |

## Current hard gates

| Gate | Status | Evidence |
|---|---|---|
| Full `lib/**` semantic checker baseline | FAIL | Current checker exits 1 with 541 AST violations; its 392 complexity warnings are informational and the migration allowlist remains explicit/shrinkable. |
| Core DTO field adoption | PASS | Generated DTO policy and CI checks are present; dev seed/core tests pass. |
| Nine-kind mandatory typed contracts | PASS | Explicit all-kind manifest and matrix tests are present and passing. |
| No cross-kind imports | FAIL | Baseline includes a Game → Music import violation and generic Library → TV imports. |
| No erased metadata after dispatch | FAIL | `CatalogItemDto`/metadata bridge consumers remain in production boundaries. |
| No common Owned domain | FAIL | Generic `OwnedItem`/common ownership infrastructure remains as a compatibility surface. |
| Kind-owned DB semantics | PARTIAL | Kind tables and ownership tests exist, but final composition/semantic-column enforcement remains. |
| Whole-repository semantic vacuum | FAIL | Existing vacuum audit excludes kind paths but does not yet classify every occurrence across all `lib/**`. |

## PR0 conclusion

PR0 is complete as a refreshed rebaseline. The branch has substantial prior typed-kind work and the seed fixtures are coherent, enriched, and validated, but it is not yet compliant with the new definition of done. PR1 is implemented as a baseline: the checker applies boundary rules across the relevant production `lib/**` surface, skips only explicit generated/composition roots, and keeps migration allowlists visible. PR2-6 added reusable contracts, strict Core field adoption, an explicit nine-kind manifest, an owned-edit registration boundary, and typed read repositories. PR11-13 added the structural action, import/export, and generic menu contracts. PR16 and PR63 made the owned read projections and loan references explicit. PR64 consolidated the generic pick-list/vocabulary infrastructure, and PR65 now keeps concrete vocabularies inside their owning kinds while leaving only genuinely universal people, acquisition, tags, and loan lists global. The seed entry point now validates catalog/owned/tracking coverage and quality before writes, and its pick-list supplements seed every kind-owned vocabulary without erasing catalog-derived values. Comic now has typed owned persistence plus typed workspace, value, stats, inspector, presentation, relation, Add, Edit, transfer, series-detail, and CSV export consumers; ComicInfo XML, Comic CSV layout/parser/projection, and its CLZ aliases are kind-owned and the global Shelf no longer exposes Comic-specific grade/series filters, while generic compatibility edges remain. CSV encoding/decoding mechanics are centralized without yet removing the semantic union profile. Manga hierarchy hydration and the Shelf volume/chapter contribution now live under Manga. Movie/TV/Anime physical copy details are duplicated inside their owning kinds, removing one shared video ownership abstraction from generic UI. Calendar now dispatches release projections for all 9 kinds through kind-owned contributors, with stable event IDs and TV/Anime episode projections; generic owned/tracking fallbacks remain. Barcode lookup now dispatches through all 9 kind-owned resolvers. Loans use `OwnedItemRef` as their canonical domain reference while old transport/storage columns remain. The current checker baseline is 541 AST violations with 392 informational complexity warnings and must shrink in subsequent migrations.

## Recommended next PR

Current branch recommendation: `PR66 - Separate personal imports from metadata imports`.
Next active implementation: `PR66 - Separate personal imports from metadata imports`, keeping `ProviderPersonalEntry` generic while moving catalog metadata import parsing, matching, and application into owning kinds.

`PR11 — Migrate existing kind toolbar descriptors to typed action registries`, while shrinking the PR1 baseline in parallel with each migration.
