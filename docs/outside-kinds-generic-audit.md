# Outside-Kinds Generic Audit Matrix

This audit document catalogues all kind-specific symbols, imports, switches, and semantic strings located outside `lib/features/library/kinds/`.

Under **Plan A (Outside kinds/ = generic)**, everything in `lib/features/library/` outside `kinds/` must be completely kind-agnostic. Adding a new production kind `foo`:
1. create `kinds/foo/`
2. implement its capabilities (`LibraryKindSpec`)
3. register `fooKindSpec` in `collectarr_kind_modules.dart`
-> **ZERO generic Library behavior files need modification.**

---

## 1. Summary of Architecture Invariants

| Invariant | Status | Verification |
| :--- | :--- | :--- |
| **Zero concrete kind imports outside `kinds/`** | **PASSED (0 imports)** | No generic library file imports `kinds/<kind>/` |
| **No legacy `shared/<kind>/` shims** | **PASSED (0 files)** | Deleted all legacy forwarding shims |
| **`LibraryMetadataItem` decomposition** | **COMPLETED** | `{ identity, common, kindMetadata }` with 0 generic concrete fields |
| **Zero runtime usages of `GenericKindMetadataPayload`** | **PASSED (0 usages)** | Fully migrated to typed `LibraryKindMetadataRuntime` & decoders |
| **Generic sync boundary** | **COMPLETED** | `toSyncPayload()` delegates payload encoding to `kindMetadata.toSyncPayload()` |
| **Analyzer status** | **0 errors** | `dart analyze` reports 0 errors across entire repository |

---

## 2. Current Inventory & Classification Matrix

| Location | Symbol / Semantic | Category | Classification | Status / Action |
| :--- | :--- | :--- | :--- | :--- |
| `lib/features/library/hierarchy/ui/hierarchy_children_section.dart` | `_defaultTitleForKind` (switch on `tv`, `anime`, `manga`, `comic`, `book`, `music`) | UI Label Fallback | **Compatibility Debt** | Delegate child container label to `LibraryHierarchyCapability` in future refinement |
| `lib/core/api/dto/catalog/catalog_item_dto.dart` | `ComicIssueDto`, `BookVolumeDto`, `GameDto`, `MusicCatalogDetails`, etc. | Transport DTO | **Allowed Boundary / Transport-Only** | Transport boundary schemas for wire serialization and database persistence |
| `lib/features/library/models/library_metadata_item.dart` | `toCatalogItem()` bridge | Interop Bridge | **Allowed Boundary** | Bridging typed runtime `LibraryKindMetadataRuntime` to transport DTO `CatalogItemDto` |
| `lib/features/library/kinds/registry/collectarr_kind_modules.dart` | `collectarrKindModules` | Composition Root | **Explicit Registry** | Central registration registry mapping kinds to `LibraryKindModule` / `LibraryKindSpec` |
| `lib/features/library/models/library_kind_metadata_runtime.dart` | `LibraryKindMetadataDecoders` | Kind Decoders | **Explicit Registry** | Central factory decoding wire maps to concrete `LibraryKindMetadataRuntime` |
| `lib/features/library/kinds/_shared/` | `video/`, `print/` | Reusable Domain Primitives | **Allowed Shared Primitives** | Cross-kind composable primitives shared strictly across visual/print kind families |

---

## 3. PR 1 Decomposition Verification

- **Shape**:
  ```dart
  final class LibraryMetadataItem {
    final LibraryItemIdentity identity;
    final LibraryCommonMetadata common;
    final LibraryKindMetadataRuntime kindMetadata;
  }
  ```
- **Generic Common Metadata**: Contains strictly universal fields (`title`, `sortKey`, `synopsis`, `coverImageUrl`, `thumbnailImageUrl`, `releaseDate`, `releaseYear`, etc.).
- **Concrete Field Families**: 100% extracted from `LibraryMetadataItem` and owned by kind-specific runtime models (`BookCatalogMetadata`, `ComicCatalogMetadata`, `MusicCatalogMetadata`, `GameCatalogMetadata`, `BoardGameMetadata`, `AnimeMetadata`, `MangaMetadata`, `MovieCatalogMetadata`, `TvCatalogMetadata`).
- **Sync Serialization**: `toSyncPayload()` does not inspect concrete schemas, spreading `kindMetadata.toSyncPayload()` into the transport envelope.
