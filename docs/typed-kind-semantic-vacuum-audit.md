# Typed-kind semantic-vacuum audit

This audit covers every occurrence of the vocabulary listed by PR121 outside
`lib/features/library/kinds/**`. The search is intentionally lexical; a hit is
classified by the boundary that owns the vocabulary, not by the spelling of a
field alone.

Search basis:

```text
series issue volume chapter season episode
publisher imprint barcode ISBN
HDR track platform grade story arc character creator
```

## Classification

| Boundary | Classification | Examples |
| --- | --- | --- |
| Kind-owned modules | N/A | All kind domain, catalog, provider, local, edit, tracking, and workspace implementations are excluded from this audit. |
| Core API DTOs and generated API | Structural transport | DTO field names and generated protocol members preserve the server contract; they do not define a shared application domain model. |
| Core DB schema and migrations | Structural persistence | Table/column names and migration SQL preserve existing storage and migration compatibility. |
| Provider adapters and provider models | Protocol boundary | Provider payload fields are read and normalized at the provider boundary; semantic mapping remains in the owning kind module. |
| Collection, sync, imports, exports, loans, and settings | Workflow boundary | These modules handle personal state, file formats, synchronization, or administrative workflows. Their identifiers are protocol/workflow data, not a common catalog domain. |
| Routing, admin, barcode, and presentation widgets | UI/help text | Route names, labels, tooltips, and detail affordances describe user-facing behavior. |
| Core personal-state models | Shared personal state | Tracking coordinates and status data are personal collection state. The remaining generic tracking-units compatibility table is separately recorded by PR122. |
| Shared Library add/edit/workspace adapters | Compatibility debt | These are the remaining semantic generic surfaces: `CatalogItem` payload transport and the shared video edit contract. They are not treated as clean parity. PR122 owns their deletion or narrowing. |

## Result

No new shared semantic domain abstraction was found during this audit. Every
non-kind occurrence belongs to one of the structural, protocol, workflow, UI,
personal-state, or compatibility classifications above.

The compatibility classification is an explicit remaining FAIL for the
semantic-vacuum objective. It covers the following production families:

```text
lib/core/api/dto/catalog/catalog_item_dto.dart
lib/core/api/mappers/*_mapper.dart
lib/features/catalog/library_catalog_repository.dart
lib/features/library/add/**
lib/features/library/config/**
lib/features/library/edit/**
lib/features/library/generic/**
lib/features/library/metadata/**
lib/features/library/models/catalog/**
lib/features/library/workspace/**
lib/features/library/kinds/registry/**
```

These files still form a migration bridge around the typed kind modules. They
must not gain new domain behavior, and they remain the deletion target of
PR122. The audit is complete because the remaining exception is named and
bounded rather than silently counted as parity.

## PR121 verdict

```text
Structural/protocol/UI/personal occurrences: PASS
Semantic generic compatibility surfaces: FAIL — carried to PR122
```
