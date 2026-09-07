# Remaining `LibraryKindRuntime` cutover

Baseline HEAD: `75885c6a` on 2026-09-07.

Generated registration is compile-time discovery of the nine kind modules. No
runtime reflection or manual per-kind import list is required. The generated
registry is a composition root only.

## Already removed from this cutover

- `_module` forwarding and runtime registration reflection;
- generic workspace lookup through the generated kind map;
- `LibraryKindModule.fields` / `projector` forwarding; every kind now owns a
  generated `TypedLibraryKindWorkspace` registration;
- Add payloads now construct the complete owning-kind Owned aggregate; the
  generated serializer registry is the only remaining Add persistence edge;
- Owned update payloads now consume and return concrete kind-owned models; the
  generated deserializer/serializer pair is the only update boundary left;
- collection Add/update writes now enter each typed repository directly; the
  common aggregate is used only for legacy reads and sync payload
  serialization;
- deletion now dispatches by `OwnedItemRef` to typed repositories; common
  deletion input has been removed from collection mutation callers;
- location assignment and cleanup now use `OwnedItemSummary` plus typed
  per-kind location updaters; LocationRepository no longer reads common
  Owned fields;
- tracking target resolution now uses `OwnedItemSummary`; TrackingMutations no
  longer reads the common Owned aggregate for catalog identity;
- Pick List owned-value usage counts now dispatch through generated kind-owned
  vocabulary contributors; the generic host no longer reads common Owned
  fields or detail payloads;
- Pick List preview/apply merge now dispatches through the same typed
  contributors; common Owned mutation and universal detail codecs are no
  longer used by Pick List merging;
- Pick List catalog/custom-field usage and merge operations are scoped to the
  requested kind instead of counting or mutating unrelated kind values;
- Collection CSV import now persists each imported owned aggregate through the
  generated typed repository dispatch; common Owned remains only at the CSV
  and sync serialization boundaries for this path;
- sync pull now deserializes the protocol payload once and persists each
  reconstructed owned item through the generated typed repository dispatch;
- development seed persistence now dispatches every fixture through the
  generated typed Owned repository registry instead of common `upsertAll`;
- generic facet definition ownership;
- test `CatalogMediaKind` switches in the migrated contract fixtures;
- common seed graph kind switches and manual seed contributor imports;
- common owned summary conversion bridge used by Activity/Calendar;
- Activity and Calendar detail/global hosts reading common `OwnedItem`;
- universal owned persistence table and generic derived-data service.

## Still erased and `PARTIAL`

`LibraryKindModule` / `LibraryKindSpec` still expose semantic behavior through
`LibraryProjectionRuntime` and related capability objects:

- remaining capability forwarding for metadata, provider, inspector, transfer,
  card and presentation surfaces;
- field/column/sort/group/facet execution still reaches generic projection
  engines even though its field definitions now live in kind workspaces;
- edit/presentation paths that still carry `CatalogItemDto`;
- collection/detail mutation paths that still carry common `OwnedItem`.

These are used by the generic Library page and inspector/edit hosts. They must
be migrated to concrete kind workspace/edit modules before the erased members
are deleted. Do not add a second runtime or compatibility alias.

## Next deletion order

1. Replace generic Catalog DTO reads with typed repositories and tiny mixed-kind
   projections.
2. Replace collection/edit/detail common Owned reads and mutations with typed
   kind payloads; keep only `OwnedItemRef`/`OwnedItemSummary` in mixed hosts.
3. Move remaining workspace/presentation capability consumers to concrete
   kind-owned modules.
4. Delete erased `LibraryKindModule` members and reduce the registration to
   navigation/dispatch.

The whole-repository architecture checker remains a failing migration gate at
601 AST violations and 410 complexity reports. Schema remains version `1` with
no compatibility upgrade path.
