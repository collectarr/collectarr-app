# Remaining `LibraryKindRuntime` cutover

HEAD was audited on 2026-09-07. The generated registry already performs
compile-time discovery of all nine kind modules; no runtime reflection or
manual per-kind import list is required for registration.

## Current classification

### Permanent dispatch boundary

- `LibraryKindRegistration`: kind identity, navigation, Add, media/release/
  owned edit entry points.
- generated maps for calendar, activity, admin, barcode, facets, CSV and
  provider contributors.
- structural mixed-kind projections such as `CatalogEntityRef` and
  `OwnedItemSummary`.

### Still erased and scheduled for removal

`LibraryKindModule`/`LibraryKindSpec` still expose the following semantic
surfaces through `LibraryWorkspaceDto` and `LibraryProjectionRuntime`:

- field registries, projector, workspace columns, sorts, groups and facets;
- metadata capability and provider mapper access;
- owned details codec/draft access;
- transfer and inspector capabilities that read common `OwnedItem` values;
- generic card construction and video presentation adapters.

These APIs are used by the generic Library page and several inspector/edit
hosts. They cannot be deleted as aliases; callers must first move to concrete
kind workspace/edit modules.

### Already removed from the cutover path

- runtime registration no longer imports kind modules manually: the generated
  registration file is the source-generated composition root;
- common owned patch command and generic transfer detail conversion;
- provider, DTO, domain and presentation compatibility aliases;
- universal owned-details tables and universal owned-item persistence table.

## Next deletion order

1. Move Library workspace projection/columns/sorts/groups/facets to typed kind
   workspace entry points.
2. Move metadata/provider resolution to kind-owned integrations.
3. Replace common `OwnedItem` reads with `OwnedItemRef`/`OwnedItemSummary` or
   concrete kind reads.
4. Delete the corresponding `LibraryKindModule` members, then reduce
   `LibraryKindSpec` to navigation composition only.

The database remains schema version `1`; this document does not authorize a
migration path or compatibility storage.
