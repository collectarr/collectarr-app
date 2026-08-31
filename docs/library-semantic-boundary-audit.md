# Library Semantic Boundary Audit

**Scope:** `lib/features/library/**` (excluding `lib/features/library/kinds/**`), plus global collection pick-list / vocabulary files.  
**Objective:** Identify every concrete media semantic concept leaking into generic library infrastructure, categorize it, and assign it to a remediation PR.

---

## 1. Audit Summary & Architectural Rule

> **Core Rule:** Generic code may know what a concept or capability is conceptually (e.g. *what a vocabulary is*, *what a field is*, *how to render tabs/sections*), but generic code **must not know what specific concrete concepts exist** (e.g. `publisher`, `storyArc`, `pageQuality`, `gamePlatform`, `hdr`, `screenRatio`, `track`).

All concrete semantics must reside strictly within `lib/features/library/kinds/<kind>/` or be exposed through dynamic kind capabilities (`LibraryKindVocabularyCapability`, `LibraryKindPresentationCapability`, etc.).

---

## 2. Semantic Leak Classification Matrix

| File | Symbol | Semantic Concept | Category | Allowed / Violation | Target Kind / Capability | Planned PR |
|---|---|---|---|---|---|---|
| `lib/features/collection/pick_list/pick_list_options.dart` | `kPublisherPickListName` | `publisher` | concrete definition | ❌ Violation | `ComicVocabularies`, `BookVocabularies`, `MangaVocabularies` | PR 2 |
| `lib/features/collection/pick_list/pick_list_options.dart` | `kImprintPickListName` | `imprint` | concrete definition | ❌ Violation | `ComicVocabularies`, `MangaVocabularies` | PR 2 |
| `lib/features/collection/pick_list/pick_list_options.dart` | `kSeriesGroupPickListName` | `series` / group | concrete definition | ❌ Violation | `ComicVocabularies` | PR 2 |
| `lib/features/collection/pick_list/pick_list_options.dart` | `kPhysicalFormatPickListName` | `physicalFormat` | concrete definition | ❌ Violation | `PhysicalFormatVocabularies` (per kind) | PR 2 |
| `lib/features/collection/pick_list/pick_list_options.dart` | `kCountryPickListName` | `country` | concrete definition | ❌ Violation | `MovieVocabularies`, `TvVocabularies` | PR 2 |
| `lib/features/collection/pick_list/pick_list_options.dart` | `kLanguagePickListName` | `language` | concrete definition | ❌ Violation | `MovieVocabularies`, `TvVocabularies`, `BookVocabularies` | PR 2 |
| `lib/features/collection/pick_list/pick_list_options.dart` | `kAgeRatingPickListName` | `ageRating` | concrete definition | ❌ Violation | `MovieVocabularies`, `GameVocabularies`, `TvVocabularies` | PR 2 |
| `lib/features/collection/pick_list/pick_list_options.dart` | `kAudienceRatingPickListName` | `audienceRating` | concrete definition | ❌ Violation | `MovieVocabularies`, `TvVocabularies` | PR 2 |
| `lib/features/collection/pick_list/pick_list_options.dart` | `kRegionPickListName` | `region` | concrete definition | ❌ Violation | `MovieVocabularies`, `GameVocabularies` | PR 2 |
| `lib/features/collection/pick_list/pick_list_options.dart` | `kPackagingPickListName` | `packaging` | concrete definition | ❌ Violation | `MovieVocabularies`, `TvVocabularies` | PR 2 |
| `lib/features/collection/pick_list/pick_list_options.dart` | `kDistributorPickListName` | `distributor` | concrete definition | ❌ Violation | `MovieVocabularies`, `TvVocabularies` | PR 2 |
| `lib/features/collection/pick_list/pick_list_options.dart` | `kScreenRatioPickListName` | `aspectRatio` / `screenRatio` | concrete definition | ❌ Violation | `MovieVocabularies`, `TvVocabularies` | PR 2 |
| `lib/features/collection/pick_list/pick_list_options.dart` | `kLayersPickListName` | `disc` / `layers` | concrete definition | ❌ Violation | `MovieVocabularies`, `TvVocabularies` | PR 2 |
| `lib/features/collection/pick_list/pick_list_options.dart` | `kColorPickListName` | `color` | concrete definition | ❌ Violation | `MovieVocabularies`, `TvVocabularies` | PR 2 |
| `lib/features/collection/pick_list/pick_list_options.dart` | `kAudioTrackPickListName` | `audio` | concrete definition | ❌ Violation | `MovieVocabularies`, `TvVocabularies` | PR 2 |
| `lib/features/collection/pick_list/pick_list_options.dart` | `kSubtitlePickListName` | `subtitle` | concrete definition | ❌ Violation | `MovieVocabularies`, `TvVocabularies` | PR 2 |
| `lib/features/collection/pick_list/pick_list_options.dart` | `kGamePlatformPickListName` | `platform` | concrete definition | ❌ Violation | `GameVocabularies` | PR 2 |
| `lib/features/collection/pick_list/pick_list_options.dart` | `kGameRegionPickListName` | `region` | concrete definition | ❌ Violation | `GameVocabularies` | PR 2 |
| `lib/features/collection/pick_list/pick_list_options.dart` | `kMusicFormatPickListName` | `format` / `physicalFormat` | concrete definition | ❌ Violation | `MusicVocabularies` | PR 2 |
| `lib/features/collection/pick_list/pick_list_options.dart` | `kCrossoverPickListName` | `crossover` / `storyArc` | concrete definition | ❌ Violation | `ComicVocabularies` | PR 2 |
| `lib/features/collection/pick_list/pick_list_options.dart` | `kStoryArcPickListName` | `storyArc` | concrete definition | ❌ Violation | `ComicVocabularies` | PR 2 |
| `lib/features/collection/pick_list/pick_list_options.dart` | `kPageQualityPickListName` | `pageQuality` | concrete definition | ❌ Violation | `ComicVocabularies` | PR 2 |
| `lib/features/collection/pick_list/pick_list_options.dart` | `kKeyCategoryPickListName` | `keyCategory` | concrete definition | ❌ Violation | `ComicVocabularies` | PR 2 |
| `lib/features/library/edit/vocabulary/library_edit_vocabulary_controller.dart` | `LibraryEditVocabularyRequest` | `publisher`, `imprint`, `pageQuality`, `keyCategory`, `gamePlatforms`, `storyArc`, `audioTracks`, `subtitles`, `packaging`, `distributor`, etc. | concrete definition | ❌ Violation | Generic `VocabularyRegistry` + Kind Capability | PR 1, PR 2 |
| `lib/features/library/edit/vocabulary/library_edit_vocabulary_controller.dart` | `LibraryEditVocabularyOptions` | Concrete vocabulary output bundles | concrete definition | ❌ Violation | Typed `VocabularyOptions` map / registry | PR 1, PR 2 |
| `lib/features/library/config/physical_media_formats.dart` | `kDefaultPhysicalMediaFormats` | `physicalFormat`, `edition`, `packaging` | concrete default/value | ❌ Violation | Kind-specific defaults (`ComicFormats`, `MovieFormats`, etc.) | PR 2 |
| `lib/features/library/config/edit_field_config.dart` | `LibraryEditFieldConfig` | Specific fields (`issueNumber`, `volumeNumber`, `publisher`, `trackCount`) | concrete definition | ❌ Violation | `LibraryKindPresentationCapability` | PR 3 |
| `lib/features/library/config/library_type_config.dart` | `LibraryTypeConfig` | Specific field flags & metadata slots | contract/infrastructure | ⚠️ Refactor | Streamlined spec | PR 3 |
| `lib/features/library/config/library_type_capabilities.dart` | `LibraryTypeCapabilities` | Semantic capabilities | contract/infrastructure | Allowed | Generic capability base | PR 1 |
| `lib/features/library/config/presentation/library_media_presentation_models.dart` | `LibraryMediaPresentationModels` | Concrete media formatting | presentation semantic | ❌ Violation | Per-kind presentation adapters | PR 4 |
| `lib/features/library/edit/shell/library_edit_dialog.dart` | `_buildComicTab`, `_buildVideoTab`, `_buildGameTab` | Kind-specific tab builders in generic shell | presentation semantic | ❌ Violation | Kind-delegated edit tab renderers | PR 4 |
| `lib/features/library/series/series_registry_repository.dart` | `SeriesRegistryRepository` | `series` / `seriesGroup` | contract/infrastructure | Allowed (Generic Series Primitive) | Core library hierarchy | PR 3 |
| `lib/features/library/workspace/` | `LibraryWorkspaceDto` | Media workspace projection | serialization boundary | Allowed | Clean DTO boundary | PR 4 |

---

## 3. Explicit Baseline Review

1. **`LibraryEditVocabularyController`**: Currently functions as a monolith containing ~25 concrete domain fields hardcoded into its request and response structures. Needs replacement by generic `VocabularyDefinition<T>` and `VocabularyRepository`.
2. **`LibraryMediaPresentationModels`**: Contains presentation logic for comic issues, game platforms, movie runtimes, and track counts. Must be moved to kind-specific presentation builders.
3. **`LibraryWorkspaceDto`**: Generic serialization container for grid/list views; verified to maintain generic boundary without kind-specific branching.
4. **`LibraryTypeConfig` & `LibraryTypeCapabilities`**: Foundational contracts; vocabulary capability (`LibraryKindVocabularyCapability`) will be added to supply registered definitions cleanly.
5. **`LibraryAddDialog` & `LibraryEditRenderer`**: Must consume vocabulary options generically from kind specifications rather than hardcoded fields.
6. **`pick_list_options`**: Global `k*PickListName` constants will be superseded by kind-owned `VocabularyId<T>` constants.
