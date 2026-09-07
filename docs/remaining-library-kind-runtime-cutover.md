# Remaining `LibraryKindModule` cutover

Audit basis: branch `work/typed-kind-full-implementation-plan` after the
generated concrete registration cutover. This document is a deletion map, not
a new compatibility contract.

## Current inventory

The production tree currently contains 362 references to
`LibraryKindModule`, `LibraryKindSpec`, or `LibraryKindRuntime` when searched
with `rg` (generated registry output included). The dominant symbol is still
`LibraryKindModule`; the old name is used by the UI as an erased capability
aggregate even though the page dispatch itself is now generated and concrete.

The generated registry currently owns:

- the nine concrete registration classes;
- kind/page discovery and navigation dispatch;
- contributor maps generated from kind-owned files;
- the explicit failure path for an unknown kind.

The registry no longer contains a handwritten kind switch and no longer uses
`LibraryKindRegistrationAdapter`.

## Classification

### Keep at the erased boundary temporarily: dispatch/navigation

These are structural entrypoints and may remain on the small registration
interface while the callers are migrated:

- `kind` and `identity`;
- library page construction;
- Add entrypoint;
- media/release/owned edit entrypoints;
- top-level action dispatch where the host only renders an action contract.

The concrete implementations are generated as `*Registration` classes. They
do not expose fields, repositories, codecs, provider metadata, or workspace
semantics through the registration interface.

### Move into typed kind workspace modules

These members are semantic and must leave `LibraryKindModule`:

- `fields`, projection, columns, sorts, groups, and facets;
- card/presentation builders and metadata formatting;
- hierarchy, inspector, tracking, value, relation, and transfer capability
  graphs;
- provider mapper and metadata decoder access;
- owned details codecs and owned payload builders;
- physical format and search-target semantics;
- kind-specific toolbar and statistics definitions.

The generic host may consume structural view models produced by a typed
workspace controller. It must not recover these values by casting a module or
by reading a dynamic metadata map.

### Delete as compatibility

The following patterns are not target architecture and have no new callers:

- `withCatalogMetadata` cloning of a kind spec;
- generic runtime methods that decode/re-encode concrete metadata;
- common owned details/default/validation methods;
- generic provider-to-catalog mapper methods returning `CatalogItem`;
- module APIs whose only purpose is to forward a kind-owned capability;
- aliases named `runtime`, `type`, or `spec` that merely hide the erased
  aggregate after kind dispatch.

## Cutover order

1. Change generic workspace/projection consumers to receive typed structural
   workspace contracts at the page boundary.
2. Remove owned codec and payload methods from the module interface.
3. Remove provider mapper and metadata decoder methods from the module.
4. Remove facet execution and semantic field access from the module.
5. Shrink the module to a kind-local composition object, then delete it from
   cross-feature APIs once all pages use concrete kind registrations.

Each step must keep the generated registry as a composition root only. No
runtime reflection or `Map<String, dynamic>` replacement is permitted.

## Verification commands

```text
dart run tool/generate_kind_registries.dart
flutter test test/architecture/typed_kind_registration_boundary_test.dart
flutter analyze lib/features/library/kinds/registry/collectarr_kind_registry.g.dart
```

The whole-repository checker remains a migration baseline until the semantic
consumers listed above are removed; its current baseline is recorded in the
typed-kind audit documents.
