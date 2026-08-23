# Outside-Kinds Generic Audit Matrix

This audit document catalogues all kind-specific symbols, imports, switches, and semantic strings located outside lib/features/library/kinds/.

Under **Plan A (Outside kinds/ = generic)**, everything in lib/features/library/ outside kinds/ must be completely kind-agnostic. Kind-specific UI, drafts, controllers, and semantics must be owned by their respective kind modules under lib/features/library/kinds/<kind>/.

---

## Violation & Inventory Matrix

| File | Symbol / Semantic | Category | Why Kind-Specific | Target Owner | Migration Phase |
| :--- | :--- | :--- | :--- | :--- | :--- |
| lib/features/library/edit/shell/library_edit_dialog.dart | ComicEditController, _comicEdit | Edit Controller | Manages Comic-specific preservation, grading, and slab fields | kinds/comic/edit/ | Phase A1 (Task A1.2) |
| lib/features/library/edit/shell/library_edit_dialog.dart | ComicEditHost | Interface Implementation | Implements comic host callbacks directly in generic shell | kinds/comic/edit/ | Phase A1 (Task A1.2) |
| lib/features/library/edit/shell/library_edit_dialog.dart | ComicEditDraft, _comicDraft | Draft State | Direct access to concrete comic draft in generic form | kinds/comic/edit/ | Phase A1 (Task A1.2) |
| lib/features/library/edit/shell/library_edit_dialog.dart | _buildComicDetailSections | Edit UI Section | Hardcoded Comic edit layout and widgets in generic renderer | kinds/comic/edit/ | Phase A1 (Task A1.2) |
| lib/features/library/edit/shell/library_edit_dialog.dart | GameEditController, _gameEdit | Edit Controller | Manages Game-specific PriceCharting, completeness, and platform | kinds/game/edit/ | Phase A1 (Task A1.3) |
| lib/features/library/edit/shell/library_edit_dialog.dart | GameEditDraft, _gameDraft | Draft State | Direct access to concrete game draft in generic form | kinds/game/edit/ | Phase A1 (Task A1.3) |
| lib/features/library/edit/shell/library_edit_dialog.dart | _buildGameDetailSections | Edit UI Section | Hardcoded Game edit layout and PriceCharting widgets | kinds/game/edit/ | Phase A1 (Task A1.3) |
| lib/features/library/edit/shell/library_edit_dialog.dart | VideoEditController, _videoEdit | Edit Controller | Manages Video edition, runtime, audio tracks, and subtitles | kinds/_shared/video/ & kinds/movie/ | Phase A1 (Task A1.4) |
| lib/features/library/edit/shell/library_edit_dialog.dart | _buildVideoDetailSections, _buildTvEpisodeSections | Edit UI Section | Hardcoded TV season/episode and Movie physical media layouts | kinds/movie/edit/ & kinds/tv/edit/ | Phase A1 (Task A1.4) |
| lib/features/library/edit/draft/common_metadata_draft.dart | creators, characters, storyArcs, platforms | Metadata Model | Mixes kind-specific metadata fields into single shared draft | kinds/<kind>/catalog/ & generic custom map | Phase A1 / Phase A2 |
| lib/features/library/edit/draft/tracking_draft.dart | seasonTracking, olumeTracking, playtime | Tracking Draft | Hardcodes media-specific tracking counters in generic draft | kinds/<kind>/ tracking capability | Phase A1 / Phase A2 |
| lib/features/library/models/library_metadata_item.dart | characters, storyArcs, platforms, 	racks, credits | Catalog Model | Contains untyped bag of kind-specific domain fields | kinds/<kind>/domain/ | Phase A2 |
| lib/core/api/dto/catalog/catalog_item_dto.dart | ComicIssueDto, BookVolumeDto, GameDto, etc. | Transport DTO | Backend transport DTO unions for all catalog items | Core API Transport (Boundary) | Boundary Exception |
| lib/features/library/config/library_type_config.dart | showsComicCollectorFields, supportsMediaReleaseSplit | Legacy Config | Feature flag getters checking kind types | LibraryKindSpec capabilities | Phase A1 (Completed in P0.2) |
| lib/features/library/sections/seasons_section.dart | SeasonList, EpisodeList | UI Section | Video/TV specific hierarchy rendering outside kind module | kinds/tv/ & kinds/anime/ inspector | Phase A2 |
| lib/features/library/sections/volumes_section.dart | VolumeList, ChapterList | UI Section | Manga/Book specific hierarchy rendering outside kind module | kinds/book/ & kinds/manga/ inspector | Phase A2 |
| lib/features/library/providers/seasons_provider.dart | 	vSeasonsProvider | State Provider | Concrete TV/Anime seasons query outside kinds | kinds/tv/ hierarchy provider | Phase A2 |
| lib/features/library/providers/volumes_provider.dart | ookVolumesProvider | State Provider | Concrete Book/Manga volumes query outside kinds | kinds/book/ hierarchy provider | Phase A2 |
| lib/features/library/shared/comic/* | edit_controller.dart, edit_host.dart, edit_tabs.dart | Re-export Shims | Forwarding shims exposing comic internals to generic code | Deleted -> moved into kinds/comic/edit/ | Phase A1 (Task A1.2) |
| lib/features/library/shared/game/* | edit_controller.dart, game_domain.dart | Re-export Shims | Forwarding shims exposing game internals to generic code | Deleted -> moved into kinds/game/edit/ | Phase A1 (Task A1.3) |
| lib/features/library/shared/movie/* & shared/tv/* | edit_dialog.dart, edit_tabs.dart | Re-export Shims | Forwarding shims exposing video internals | Deleted -> moved into kinds/movie/edit/ & kinds/tv/edit/ | Phase A1 (Task A1.4) |
| lib/features/library/media/video/* | ideo_edit_controller.dart, ideo_season_tracking_section.dart | Legacy Video Layer | Legacy cross-kind video UI shared between movie, tv, anime | Neutral primitives to kinds/_shared/video/, rest to kinds | Phase A1 (Task A1.4) |

---

## Action Plan & Architecture Enforcement

1. **Phase A1 (Edit UI Extraction)**:
   - Introduce LibraryEditUiCapability / LibraryEditSectionBuilder on LibraryEditCapability.
   - Extract Comic, Game, Movie, TV, Anime, Manga, Book, Boardgame, Music edit sections into their respective kinds/<kind>/edit/ directories.
   - Strip all kind controllers and drafts from library_edit_dialog.dart to reduce it to a pure generic form shell (< 600 lines).
   - Delete shared/<kind>/* forwarding shims.

2. **Phase A2 (Hierarchy & Detail Section Agnosticism)**:
   - Migrate seasons and volumes sections into LibraryHierarchyCapability / LibraryInspectorCapability.
   - Decouple media/video/ into neutral shared primitives under kinds/_shared/video/.
