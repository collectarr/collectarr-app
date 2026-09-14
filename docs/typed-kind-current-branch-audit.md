# Typed-kind current branch audit

> Current code checkpoint: `8f739e24e` (2026-09-14). AST architecture
> violations: **0**; complexity reports: **403** informational; fatal Flutter
> analyzer: **0 issues**; affected custom-episode, TMDb, seed, sync, Add and
> tracking tests: **all passed**. The common custom-episode model/ref/repository
> and mutation service are deleted. TMDb Movie/TV/Anime semantic mapping now
> lives in kind integrations, and Add bundle choices use a structural summary.
> Documentation is maintained outside code commits.

Updated checkpoint: `8f739e24e` (2026-09-14).

## Current status

- Branch: `work/typed-kind-full-implementation-plan`
- Schema policy: v1 only; no compatibility-upgrade path
- AST architecture violations: **0**
- Complexity reports: **403 informational**
- `dart analyze lib test`: **0 issues**
- Focused typed workspace, registration, facet and architecture tests: **49/49 passed**
- Full `flutter test`: known non-zero baseline; not rerun for every code batch

## Completed in the latest code batch

- Deleted the shared `WorkspaceDtoAdapter` semantic base.
- All nine kind workspace DTOs implement `LibraryWorkspaceDto` directly.
- Kept workspace semantic getters in their owning kind DTOs.
- Deleted pure Edit barrel aliases and obsolete registration, codec and lookup
  forwarding files.
- Removed duplicate domain exports and generated imports introduced by the
  previous compatibility cutover.
- Updated production and test imports to canonical paths.
- Workspace repository reads, bucket mutations and metadata comparison now use
  schema-v1 `CatalogImportTransport`; generic snapshot callers no longer
  promote transport to `CatalogSearchCandidate`.

## Architectural checks

- Kinds do not import other kinds: **PASS**
- Provider direction: **PASS**
- Core DTO ownership: **PASS**
- No erased workspace adapter: **PASS**
- No shared capability bundle class: **PASS**
- Documentation changes are intentionally outside code commits.

## Remaining priority

The next substantial code batch is the remaining generic Add/Edit and provider
orchestration transport cutover:

1. remove rich `CatalogSearchCandidate` coupling from generic Add/Edit/detail
   hosts;
2. reduce generated capability access to composition/dispatch contracts;
3. continue schema-v1 Collection import/action decomposition through per-kind
   profiles;
4. narrow the remaining common tracking storage boundary.

The current branch audit is the source of truth for remaining migration debt;
the implementation plans have been removed after the requested consolidation.
