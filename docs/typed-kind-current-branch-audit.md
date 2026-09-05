# Typed-kind current branch audit

Audit date: 2026-09-05
Branch: `work/typed-kind-full-implementation-plan`
Compared with `main`: `df49cf2a4fda6c70f0025ae8ce99f6123d3083e5`
HEAD: `8dd0281c` (`refactor(repository): add typed read contract`)

## Scope and evidence

This is the PR0 rebaseline for the new Full Typed-Kind Vertical Architecture plan. It covers the full `lib/**` production tree, the existing architecture checker, contract tests, kind modules, provider boundaries, persistence, and the seed scripts. Statuses are deliberately stricter than the previous plan: a typed slice is not DONE while a generic semantic bridge, common Owned model, or erased catalog representation remains.

Evidence checked:

- `git log main..HEAD`: 902 changed paths across the branch, with the prior typed-kind work and the seed refresh commit.
- `tool/check_library_kind_boundaries.dart`: whole-repository baseline currently reports 635 AST architecture violations; its 392 complexity warnings are informational.
- `test/contracts/**`, `test/architecture/**`, and `test/dev/dev_seed_test.dart`: full suite passed with `1819 passed, 5 skipped`.
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
| 12 | File import/export action contracts | **NOT STARTED** | No complete structural UiAction/import-export contract and kind-owned action registry is in place. |
| 13 | Action menu host | **NOT STARTED** | No complete structural UiAction/import-export contract and kind-owned action registry is in place. |
| 14 | Remove canonical common Owned domain | **PARTIAL** | Structural refs and typed tracking pieces exist, but common Owned/TrackingUnit compatibility remains. |
| 15 | Move tracking fields out of Owned | **PARTIAL** | Structural refs and typed tracking pieces exist, but common Owned/TrackingUnit compatibility remains. |
| 16 | Owned action/read projections | **DONE** | Cross-kind read projections/refs exist and are used as the intended small summary boundary. |
| 17 | Comic typed domain | **PARTIAL** | Comic has typed vertical slices and tests, but the new plan still finds erased metadata and generic integration bridges. |
| 18 | Comic Core mapping | **PARTIAL** | Comic has typed vertical slices and tests, but the new plan still finds erased metadata and generic integration bridges. |
| 19 | Comic local DB | **PARTIAL** | Comic has typed vertical slices and tests, but the new plan still finds erased metadata and generic integration bridges. |
| 20 | Comic repository | **PARTIAL** | Comic has typed vertical slices and tests, but the new plan still finds erased metadata and generic integration bridges. |
| 21 | Comic workspace | **PARTIAL** | Comic has typed vertical slices and tests, but the new plan still finds erased metadata and generic integration bridges. |
| 22 | Comic Add/Edit | **PARTIAL** | Comic has typed vertical slices and tests, but the new plan still finds erased metadata and generic integration bridges. |
| 23 | Comic collection actions | **PARTIAL** | Comic has typed vertical slices and tests, but the new plan still finds erased metadata and generic integration bridges. |
| 24 | Comic provider integrations | **PARTIAL** | Comic has typed vertical slices and tests, but the new plan still finds erased metadata and generic integration bridges. |
| 25 | Comic calendar/barcode/override contributions | **PARTIAL** | Comic has typed vertical slices and tests, but the new plan still finds erased metadata and generic integration bridges. |
| 26 | Comic reference contracts | **PARTIAL** | Comic has typed vertical slices and tests, but the new plan still finds erased metadata and generic integration bridges. |
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
| 44 | Replace CollectionPage hardcoded actions | **NOT STARTED** | The new plan's feature-host/action and semantic serializer moves have not been completed as a coherent migration. |
| 45 | Remove semantic global Shelf filters | **NOT STARTED** | The new plan's feature-host/action and semantic serializer moves have not been completed as a coherent migration. |
| 46 | Split CSV mechanics from CSV semantics | **NOT STARTED** | The new plan's feature-host/action and semantic serializer moves have not been completed as a coherent migration. |
| 47 | Move CLZ semantics into relevant kinds | **NOT STARTED** | The new plan's feature-host/action and semantic serializer moves have not been completed as a coherent migration. |
| 48 | Delete/rehome generic Collection XML | **NOT STARTED** | The new plan's feature-host/action and semantic serializer moves have not been completed as a coherent migration. |
| 49 | Move ComicInfo.xml into Comic | **NOT STARTED** | The new plan's feature-host/action and semantic serializer moves have not been completed as a coherent migration. |
| 50 | Replace common owned collection commands | **NOT STARTED** | The new plan's feature-host/action and semantic serializer moves have not been completed as a coherent migration. |
| 51 | Delete `CatalogCacheDerivedDataService` | **PARTIAL** | The old generic cache was reduced/renamed, but typed per-kind replacement is not complete and generic repository code remains. |
| 52 | Remove generic `CatalogCacheRepository` | **PARTIAL** | The old generic cache was reduced/renamed, but typed per-kind replacement is not complete and generic repository code remains. |
| 53 | Delete catalog type-erasure stack | **PARTIAL** | Several erased names were deleted, but CatalogItem transport/interoperability and generic metadata bridges remain. |
| 54 | Delete `shelfVolumesProvider` | **PARTIAL** | Typed hierarchy work exists, but legacy shelf volume/Season compatibility files are still present. |
| 55 | Remove generic `Season`/Volume compatibility APIs | **PARTIAL** | Typed hierarchy work exists, but legacy shelf volume/Season compatibility files are still present. |
| 56 | Remove global item/edition/variant ontology | **NOT STARTED** | No owning-kind override schema/storage interpretation has replaced the global ontology. |
| 57 | Keep only generic override storage/sync mechanics | **NOT STARTED** | No owning-kind override schema/storage interpretation has replaced the global ontology. |
| 58 | Generic calendar becomes event host only | **NOT STARTED** | Calendar remains a host with catalog semantics still represented by generic/legacy paths; contributors are not complete. |
| 59 | Kind calendar contributors | **NOT STARTED** | Calendar remains a host with catalog semantics still represented by generic/legacy paths; contributors are not complete. |
| 60 | Universal calendar contributors | **NOT STARTED** | Calendar remains a host with catalog semantics still represented by generic/legacy paths; contributors are not complete. |
| 61 | Keep scanner generic | **PARTIAL** | Scanner mechanics exist, but the new generic ScannedCode and kind-owned resolver matrix is incomplete. |
| 62 | Kind-owned identifier resolvers | **NOT STARTED** | Kind-owned identifier resolvers are not complete for all applicable kinds. |
| 63 | Loans use `OwnedItemRef` | **PARTIAL** | Loan infrastructure exists, but the common Owned domain still leaks into the cross-kind boundary. |
| 64 | Collapse duplicate pick-list infrastructure | **PARTIAL** | Pick-list infrastructure and typed vocabularies exist, but the old/new paths and global semantic definitions still need consolidation. |
| 65 | All concrete vocabularies stay kind-owned | **PARTIAL** | Pick-list infrastructure and typed vocabularies exist, but the old/new paths and global semantic definitions still need consolidation. |
| 66 | Separate personal imports from metadata imports | **PARTIAL** | Provider personal sync and import orchestration have typed pieces, while metadata import semantics still cross generic feature boundaries. |
| 67 | Generic import infrastructure becomes orchestration-only | **PARTIAL** | Provider personal sync and import orchestration have typed pieces, while metadata import semantics still cross generic feature boundaries. |
| 68 | Activity as projected events | **PARTIAL** | Projected activity/admin/settings infrastructure exists, but feature-specific semantic contributors are not fully separated. |
| 69 | Admin kind-specific screens/actions | **PARTIAL** | Projected activity/admin/settings infrastructure exists, but feature-specific semantic contributors are not fully separated. |
| 70 | Kind-specific settings contributions | **PARTIAL** | Projected activity/admin/settings infrastructure exists, but feature-specific semantic contributors are not fully separated. |
| 71 | Define genuinely universal tracking infrastructure | **PARTIAL** | Typed tracking models and TV/Anime storage exist, but generic tracking compatibility and full per-kind ownership remain. |
| 72 | Full kind-owned tracking state | **PARTIAL** | Typed tracking models and TV/Anime storage exist, but generic tracking compatibility and full per-kind ownership remain. |
| 73 | Move watch/custom episode storage | **PARTIAL** | Typed tracking models and TV/Anime storage exist, but generic tracking compatibility and full per-kind ownership remain. |
| 74 | Classify every `_shared` file | **PARTIAL** | The shared-kind audit exists, but the new allowed classification is stricter than the current _shared contents. |
| 75 | De-share Video | **NOT STARTED** | Shared video and publishing/serial semantic abstractions still exist or remain in compatibility locations. |
| 76 | De-share publishing/serial domains | **NOT STARTED** | Shared video and publishing/serial semantic abstractions still exist or remain in compatibility locations. |
| 77 | Per-kind Library toolbar actions | **NOT STARTED** | Typed toolbar, row, and bulk action declarations are not yet the single source for all kind actions. |
| 78 | Typed row/item actions | **NOT STARTED** | Typed toolbar, row, and bulk action declarations are not yet the single source for all kind actions. |
| 79 | Typed bulk actions | **NOT STARTED** | Typed toolbar, row, and bulk action declarations are not yet the single source for all kind actions. |
| 80 | Provider search summary only | **DONE** | ProviderSearchHit is a compact summary and provider mapping contracts cover the current provider matrix. |
| 81 | Kind-owned provider metadata resolution | **PARTIAL** | Kind-owned provider mappers exist, but generic add/metadata bridge callers remain. |
| 82 | Remove normalized provider metadata god model | **PARTIAL** | The normalized envelope is quarantined/covered, but has not been deleted. |
| 83 | Personal sync cleanup | **PARTIAL** | ProviderPersonalEntry and sync policy tests exist; a full canonical cleanup and parity audit remain. |
| 84 | Sync policy parity | **PARTIAL** | ProviderPersonalEntry and sync policy tests exist; a full canonical cleanup and parity audit remain. |
| 85 | `LocalDatabase` becomes composition root | **PARTIAL** | Kind tables and ownership tests exist, but LocalDatabase/production DB composition still needs the final ownership gate. |
| 86 | Kind DB ownership checker | **PARTIAL** | Kind tables and ownership tests exist, but LocalDatabase/production DB composition still needs the final ownership gate. |
| 87 | Delete giant `LibraryKindRuntime` | **PARTIAL** | Dispatch uses registrations, but the giant runtime and generic capability forwarding are still present. |
| 88 | Cross-kind summaries only | **DONE** | The intentionally small cross-kind projections CatalogSearchHit, OwnedItemRef/Summary, and ProviderSearchHit exist. |
| 89 | Library metrics system | **PARTIAL** | Library metrics, typography, result-table, selection, and visual contracts exist; action visual standardization is not yet complete everywhere. |
| 90 | Typography system | **PARTIAL** | Library metrics, typography, result-table, selection, and visual contracts exist; action visual standardization is not yet complete everywhere. |
| 91 | Shared generic result table | **PARTIAL** | Library metrics, typography, result-table, selection, and visual contracts exist; action visual standardization is not yet complete everywhere. |
| 92 | Standard selection controls | **PARTIAL** | Library metrics, typography, result-table, selection, and visual contracts exist; action visual standardization is not yet complete everywhere. |
| 93 | Shared action visuals | **PARTIAL** | Library metrics, typography, result-table, selection, and visual contracts exist; action visual standardization is not yet complete everywhere. |
| 94 | Mandatory contracts all 9 kinds | **PARTIAL** | Core/add/edit/release/tracking/provider contracts exist, but action/calendar/barcode/override contract coverage is incomplete. |
| 95 | Release/Edition contracts | **PARTIAL** | Core/add/edit/release/tracking/provider contracts exist, but action/calendar/barcode/override contract coverage is incomplete. |
| 96 | Action contracts | **PARTIAL** | Core/add/edit/release/tracking/provider contracts exist, but action/calendar/barcode/override contract coverage is incomplete. |
| 97 | Calendar contracts | **PARTIAL** | Core/add/edit/release/tracking/provider contracts exist, but action/calendar/barcode/override contract coverage is incomplete. |
| 98 | Barcode contracts | **PARTIAL** | Core/add/edit/release/tracking/provider contracts exist, but action/calendar/barcode/override contract coverage is incomplete. |
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
| 110 | Cross-kind dependency enforcement | **PARTIAL** | Several architecture guards exist, but the baseline checker currently reports 98 violations and still has migration allowlists. |
| 111 | Provider dependency enforcement | **PARTIAL** | Several architecture guards exist, but the baseline checker currently reports 98 violations and still has migration allowlists. |
| 112 | Core DTO ownership enforcement | **PARTIAL** | Several architecture guards exist, but the baseline checker currently reports 98 violations and still has migration allowlists. |
| 113 | Type-erasure enforcement | **PARTIAL** | Several architecture guards exist, but the baseline checker currently reports 98 violations and still has migration allowlists. |
| 114 | Semantic action enforcement | **PARTIAL** | Several architecture guards exist, but the baseline checker currently reports 98 violations and still has migration allowlists. |
| 115 | DB ownership enforcement | **PARTIAL** | Several architecture guards exist, but the baseline checker currently reports 98 violations and still has migration allowlists. |
| 116 | Declarative Add/Edit ownership enforcement | **PARTIAL** | Several architecture guards exist, but the baseline checker currently reports 98 violations and still has migration allowlists. |
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
| Full `lib/**` semantic checker baseline | FAIL | Current checker exits 1 with 635 AST violations; complexity output is informational and the migration allowlist remains explicit/shrinkable. |
| Core DTO field adoption | PASS | Generated DTO policy and CI checks are present; dev seed/core tests pass. |
| Nine-kind mandatory typed contracts | PASS | Explicit all-kind manifest and matrix tests are present and passing. |
| No cross-kind imports | FAIL | Baseline includes a Game → Music import violation and generic Library → TV imports. |
| No erased metadata after dispatch | FAIL | `CatalogItemDto`/metadata bridge consumers remain in production boundaries. |
| No common Owned domain | FAIL | Generic `OwnedItem`/common ownership infrastructure remains as a compatibility surface. |
| Kind-owned DB semantics | PARTIAL | Kind tables and ownership tests exist, but final composition/semantic-column enforcement remains. |
| Whole-repository semantic vacuum | FAIL | Existing vacuum audit excludes kind paths but does not yet classify every occurrence across all `lib/**`. |

## PR0 conclusion

PR0 is complete as a rebaseline. The branch has substantial prior typed-kind work and the seed fixtures are now coherent, but it is not yet compliant with the new definition of done. PR1 is implemented as a baseline: the checker applies boundary rules across the relevant production `lib/**` surface, skips only explicit generated/composition roots, and keeps migration allowlists visible. PR2-6 added reusable contracts, strict Core field adoption, an explicit nine-kind manifest, an owned-edit registration boundary, and typed read repositories. PR11 now adds the structural action contract. The current checker baseline remains 635 AST violations and must shrink in subsequent migrations.

## Recommended next PR

`PR11 — Migrate existing kind toolbar descriptors to typed action registries`, while shrinking the PR1 baseline in parallel with each migration.
