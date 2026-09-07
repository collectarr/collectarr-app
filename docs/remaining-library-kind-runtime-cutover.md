# Remaining `LibraryKindRuntime` cutover

Baseline HEAD: `def62e14` on 2026-09-07.

Generated registration is compile-time discovery of the nine kind modules. No
runtime reflection or manual per-kind import list is required. The generated
registry is a composition root only.

## Already removed from this cutover

- `_module` forwarding and runtime registration reflection;
- generic workspace lookup through the generated kind map;
- generic facet definition ownership;
- test `CatalogMediaKind` switches in the migrated contract fixtures;
- common seed graph kind switches and manual seed contributor imports;
- common owned summary conversion bridge used by Activity/Calendar;
- Activity and Calendar detail/global hosts reading common `OwnedItem`;
- universal owned persistence table and generic derived-data service.

## Still erased and `PARTIAL`

`LibraryKindModule` / `LibraryKindSpec` still expose semantic behavior through
`LibraryProjectionRuntime` and related capability objects:

- field registries, columns, sorts, groups and facet execution;
- metadata and provider mapper access;
- generic inspector, transfer and card construction;
- edit/presentation paths that still carry `CatalogItemDto`;
- collection/detail mutation paths that still carry common `OwnedItem`.

These are used by the generic Library page and inspector/edit hosts. They must
be migrated to concrete kind workspace/edit modules before the erased members
are deleted. Do not add a second runtime or compatibility alias.

## Next deletion order

1. Move one complete workspace/presentation consumer cluster to a concrete
   kind-owned module and repeat for the remaining kinds.
2. Replace generic Catalog DTO reads with typed repositories and tiny mixed-kind
   projections.
3. Replace collection/edit/detail common Owned reads and mutations with typed
   kind payloads; keep only `OwnedItemRef`/`OwnedItemSummary` in mixed hosts.
4. Delete erased `LibraryKindModule` members and reduce the registration to
   navigation/dispatch.

The whole-repository architecture checker remains a failing migration gate at
601 AST violations and 410 complexity reports. Schema remains version `1` with
no compatibility upgrade path.
