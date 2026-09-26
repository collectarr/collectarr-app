# Active Kind Boundary Plan

> **Superseded:** its Work/Release/Copy ownership boundaries are historical.
> The current target is the coordinated all-kind Catalog Item v1 cutover in
> [catalog-item-v1-cutover.md](catalog-item-v1-cutover.md).

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

Manual Add submission now has kind-owned candidate builders and rejects no-op success. Continue unifying field definitions and UI sessions across Add and Edit for each kind and scope. A shared mapper can expose create and update operations; use explicit patch semantics when Edit performs a partial update. See the [Add/Edit form plan](add-edit-form-unification-plan.md) for the detailed sequence.

### 2. Shared Add/provider orchestration

Keep search, selection, structural preview, loading, and submission orchestration in the host. Move semantic hydration, candidate construction, and proposal mapping into kind contributions. Reduce generic access to `CatalogSearchCandidate` and metadata payloads. Split `LibraryAddSessionController` by actual responsibility rather than file length.

### 3. Remaining cross-kind surfaces

Review Admin corrections, query building, import/export, sync/tracking, stats, calendar, barcode, workspace, and settings. Move each kind-specific field read or write into its owning kind, leaving only structural contracts in the host. Review provider mappers and transport DTOs separately: the presence of a field on the wire does not authorize the host to interpret it.

### 4. Cleanup and documentation

Remove dead branches, semantic fallbacks, and parallel drafts as soon as callers have migrated. Update `current-status.md`, README, and persistence documentation when contracts or the database version change. Before closing a stage, verify registry generation, the boundary rule, analyzer results, affected kind contracts, and relevant Add/Edit flows.

## Targeted follow-ups from the current code review

1. **Comic edit navigation:** `comicOpenEditTab('photos')` is wired to the "Manage My Images" action, but its host-adapter implementation is empty. Connect it to the active edit tab controller or remove the action until it has a real destination.
2. **Provider identity decoding:** `ProviderAccountStore`, `ProviderLinkStore`, `ProviderAccount.fromJson`, and `ProviderItemLink.fromJson` decode an unknown provider as AniList; `ProviderAdapter.id` and `ProviderPersonalEntry.fromJson` default to TMDb. Reject or isolate unknown identities instead of assigning records to a different provider. Review the similar auth-type defaults for stored accounts.
3. **Sync queue consistency:** `SyncQueueRepository.listPending()` logs and skips malformed rows while `pendingCount()` counts every stored row. Define a recovery path for malformed rows and make the displayed count match the set of actionable changes, while retaining diagnostics.
4. **Add draft type safety:** `StandardLibraryAddCapability.buildCommand()` and `buildCommandFromDetails()` replace a draft of the wrong kind with a fresh initial draft. Fail explicitly at this boundary so a mismatched draft cannot silently discard entered values.

## Completion criteria

- Shared hosts do not read, validate, or serialize kind-specific fields.
- Each kind can add and edit shared fields through one form definition and typed create/update operations.
- No manual Add flow closes successfully without performing an operation.
- Old paths without callers are removed, and architecture documents match the current code and database schema.
