# Active Kind Boundary Plan

## Ownership rule

Code under `lib/features/library/kinds/<kind>/` owns that kind's fields, values, validation, and semantic interpretation. Shared code may know `CatalogMediaKind`, structural Work/Release/Copy references, and display projections. Core DTOs and provider payloads are transport contracts; kind-owned mappers interpret them. Registries compose contributions without deciding field semantics.

The rule is described in [kind architecture](kinds.md). Implemented behavior is recorded in [current status](current-status.md); this plan tracks the remaining work. The current Drift schema and migrations are described in [local persistence](local-persistence.md).

## Completed foundations

- Typed Work/Release/Copy contracts and references that include the parent chain.
- Structural workspace projections and kind-owned semantic provider mappers.
- Removal of the `LibraryMetadataItem` facade and other old bridges covered by architecture checks.
- Separation of the main Work/Release/Copy edit contracts; Music retains distinct Release Group and Release levels.

These are recorded as completed foundations, not tasks to repeat.

## Active stages, in recommended order

### 1. Manual Add and shared Add/Edit fields — high priority

First fix manual Add submission, which can report success without saving. Then unify field definitions and UI sessions across Add and Edit for each kind and scope. Keep create and update operations separate, with explicit patch semantics for Edit. See the [Add/Edit form plan](add-edit-form-unification-plan.md) for the detailed sequence.

### 2. Shared Add/provider orchestration

Keep search, selection, structural preview, loading, and submission orchestration in the host. Move semantic hydration, candidate construction, and proposal mapping into kind contributions. Reduce generic access to `CatalogSearchCandidate` and metadata payloads after the first manual Add flow is corrected. Split `LibraryAddSessionController` by actual responsibility rather than file length.

### 3. Remaining cross-kind surfaces

Review Admin corrections, query building, import/export, sync/tracking, stats, calendar, barcode, workspace, and settings. Move each kind-specific field read or write into its owning kind, leaving only structural contracts in the host. Review provider mappers and transport DTOs separately: the presence of a field on the wire does not authorize the host to interpret it.

### 4. Cleanup and documentation

Remove dead branches, semantic fallbacks, and parallel drafts as soon as callers have migrated. Update `current-status.md`, README, and persistence documentation when contracts or the database version change. Before closing a stage, verify registry generation, the boundary rule, analyzer results, affected kind contracts, and relevant Add/Edit flows.

## Completion criteria

- Shared hosts do not read, validate, or serialize kind-specific fields.
- Each kind can add and edit shared fields through one form definition, with typed create/update adapters.
- No manual Add flow closes successfully without performing an operation.
- Old paths without callers are removed, and architecture documents match the current code and database schema.
