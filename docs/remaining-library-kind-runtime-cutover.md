# Remaining `LibraryKindRuntime` cutover

HEAD `4bd2c0de` was audited on 2026-09-07. The generated registry already performs
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
surfaces through `LibraryProjectionRuntime` and other erased capability APIs:

- field registries, projector, columns, sorts, groups and facet execution;
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
- generated registrations are direct typed module values; there is no erased
  `_module` getter or runtime reflection path;
- workspace consumers resolve typed workspaces through the generated kind map;
- facet definition lists are owned by their kinds, and test fixtures use typed
  maps/concrete types instead of `CatalogMediaKind` switches;
- seed graph validation is supplied by each kind contributor; the common seed
  runner no longer switches on a kind string;
- common owned patch command and generic transfer detail conversion;
- provider, DTO, domain and presentation compatibility aliases;
- provider search results and descriptors retain typed catalog kinds; provider
  JSON/protocol strings remain explicit boundary values;
- typed metadata API dispatch receives `CatalogMediaKind` through the client
  and converts to route values only at the transport boundary;
- universal owned-details tables and universal owned-item persistence table.

## Next deletion order

1. Move remaining Library projection/columns/sorts/groups/facet execution to
   typed kind entry points and remove erased runtime members.
2. Move metadata/provider resolution to kind-owned integrations.
3. Replace common `OwnedItem` reads with `OwnedItemRef`/`OwnedItemSummary` or
   concrete kind reads.
4. Delete the corresponding `LibraryKindModule` members, then reduce
   `LibraryKindSpec` to navigation composition only.

The database remains schema version `1`; this document does not authorize a
migration path or compatibility storage.
