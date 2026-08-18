# Kind Completeness & Collector Data Audit Matrix

This document provides an explicit baseline audit of all 9 active media kinds in Collectarr (`comic`, `manga`, `anime`, `book`, `game`, `boardgame`, `movie`, `tv`, `music`).

Each capability/layer is marked as:
- **OWNED**: Dedicated kind-specific implementation.
- **SHARED PRIMITIVE**: Shared infrastructure/primitive without kind leakage.
- **BORROWED FROM ANOTHER KIND**: Inappropriately reuses another kind's semantics or models.
- **GENERIC FALLBACK**: Unspecialized fallback (e.g. `GenericEditDraft`, `GenericOwnedDetailsDraft`).
- **MISSING**: Not implemented.

---

## Kind Completeness Matrix

| Capability / Layer | Comic | Manga | Anime | Book | Game | Boardgame | Movie | TV | Music |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Catalog Item Model** | OWNED (`ComicIssueDto`) | OWNED (`MangaChapterDto`) | OWNED (`AnimeEpisodeDto`) | OWNED (`BookVolumeDto`) | OWNED (`GameDto`) | OWNED (`BoardgameDto`) | OWNED (`MovieDto`) | OWNED (`TvSeriesDto`) | OWNED (`MusicAlbumDto`) |
| **Release Model** | SHARED PRIMITIVE (`CatalogEditionDto`) | SHARED PRIMITIVE (`CatalogEditionDto`) | SHARED PRIMITIVE (`CatalogEditionDto`) | SHARED PRIMITIVE (`CatalogEditionDto`) | SHARED PRIMITIVE (`CatalogEditionDto`) | SHARED PRIMITIVE (`CatalogEditionDto`) | SHARED PRIMITIVE (`CatalogEditionDto`) | SHARED PRIMITIVE (`CatalogEditionDto`) | SHARED PRIMITIVE (`CatalogEditionDto`) |
| **Owned Details Type** | OWNED (`ComicOwnedDetails`) | **BORROWED FROM COMIC** (`ComicOwnedDetails`) | **BORROWED FROM VIDEO** (`VideoOwnedDetails`) | OWNED (`BookOwnedDetails`) | OWNED (`GameOwnedDetails`) | OWNED (`BoardgameOwnedDetails`) | OWNED (`VideoOwnedDetails`) | **BORROWED FROM VIDEO** (`VideoOwnedDetails`) | OWNED (`MusicOwnedDetails`) |
| **Owned Details Codec** | OWNED (`ComicOwnedDetailsCodec`) | **BORROWED FROM COMIC** (`ComicOwnedDetailsCodec`) | **BORROWED FROM VIDEO** (`VideoOwnedDetailsCodec`) | OWNED (`BookOwnedDetailsCodec`) | OWNED (`GameOwnedDetailsCodec`) | OWNED (`BoardgameOwnedDetailsCodec`) | OWNED (`VideoOwnedDetailsCodec`) | **BORROWED FROM VIDEO** (`VideoOwnedDetailsCodec`) | OWNED (`MusicOwnedDetailsCodec`) |
| **Personal-Details Draft** | OWNED (`ComicOwnedDetailsDraft`) | **BORROWED FROM COMIC** (`ComicOwnedDetailsDraft`) | **BORROWED FROM VIDEO** (`VideoOwnedDetailsDraft`) | OWNED (`BookOwnedDetailsDraft`) | OWNED (`GameOwnedDetailsDraft`) | **GENERIC FALLBACK** (`GenericOwnedDetailsDraft`) | OWNED (`VideoOwnedDetailsDraft`) | **BORROWED FROM VIDEO** (`VideoOwnedDetailsDraft`) | OWNED (`MusicOwnedDetailsDraft`) |
| **Add Draft** | OWNED (`ComicAddDraft`) | **BORROWED FROM COMIC** (`ComicAddDraft`) | **BORROWED FROM VIDEO** (`VideoAddDraft`) | OWNED (`BookAddDraft`) | OWNED (`GameAddDraft`) | OWNED (`BoardGameAddDraft`) | OWNED (`VideoAddDraft`) | **BORROWED FROM VIDEO** (`VideoAddDraft`) | OWNED (`MusicAddDraft`) |
| **Add Capability** | OWNED (`StandardLibraryAddCapability<ComicAddDraft>`) | **BORROWED DRAFT** (`StandardLibraryAddCapability<ComicAddDraft>`) | **BORROWED DRAFT** (`StandardLibraryAddCapability<VideoAddDraft>`) | OWNED (`StandardLibraryAddCapability<BookAddDraft>`) | OWNED (`StandardLibraryAddCapability<GameAddDraft>`) | OWNED (`StandardLibraryAddCapability<BoardGameAddDraft>`) | OWNED (`StandardLibraryAddCapability<VideoAddDraft>`) | **BORROWED DRAFT** (`StandardLibraryAddCapability<VideoAddDraft>`) | OWNED (`StandardLibraryAddCapability<MusicAddDraft>`) |
| **Edit Draft** | OWNED (`ComicEditDraft`) | **BORROWED FROM COMIC** (`ComicEditDraft`) | **BORROWED FROM VIDEO** (`VideoEditDraft`) | OWNED (`BookEditDraft`) | OWNED (`GameEditDraft`) | **GENERIC FALLBACK** (`GenericEditDraft`) | OWNED (`VideoEditDraft`) | **BORROWED FROM VIDEO** (`VideoEditDraft`) | OWNED (`MusicEditDraft`) |
| **Edit Capability** | OWNED (`LibraryEditCapability`) | OWNED (`LibraryEditCapability`) | OWNED (`LibraryEditCapability`) | OWNED (`LibraryEditCapability`) | OWNED (`LibraryEditCapability`) | **GENERIC FALLBACK** (`createGenericEditDraft`) | OWNED (`LibraryEditCapability`) | OWNED (`LibraryEditCapability`) | OWNED (`LibraryEditCapability`) |
| **Workspace DTO** | OWNED (`ComicWorkspaceDto`) | OWNED (`MangaWorkspaceDto`) | OWNED (`AnimeWorkspaceDto`) | OWNED (`BookWorkspaceDto`) | OWNED (`GameWorkspaceDto`) | OWNED (`BoardGameWorkspaceDto`) | OWNED (`MovieWorkspaceDto`) | OWNED (`TvWorkspaceDto`) | OWNED (`MusicWorkspaceDto`) |
| **Workspace Projector** | OWNED (`ComicWorkspaceProjector`) | OWNED (`MangaWorkspaceProjector`) | OWNED (`AnimeWorkspaceProjector`) | OWNED (`BookWorkspaceProjector`) | OWNED (`GameWorkspaceProjector`) | OWNED (`BoardGameWorkspaceProjector`) | OWNED (`MovieWorkspaceProjector`) | OWNED (`TvWorkspaceProjector`) | OWNED (`MusicWorkspaceProjector`) |
| **Field Registry** | OWNED (`comicLibraryKindSchema`) | OWNED (`mangaLibraryKindSchema`) | OWNED (`animeLibraryKindSchema`) | OWNED (`bookLibraryKindSchema`) | OWNED (`gameLibraryKindSchema`) | OWNED (`boardgameLibraryKindSchema`) | OWNED (`movieLibraryKindSchema`) | OWNED (`tvLibraryKindSchema`) | OWNED (`musicLibraryKindSchema`) |
| **Inspector Sections** | OWNED (`buildComicInspectorSections`) | SHARED PRIMITIVE | OWNED (`buildAnimeInspectorSections`) | OWNED (`buildBookInspectorSections`) | OWNED (`buildGameInspectorSections`) | SHARED PRIMITIVE (empty) | OWNED (`buildMovieInspectorSections`) | OWNED (`buildTvInspectorSections`) | SHARED PRIMITIVE (empty) |
| **Card Presentation** | OWNED (`buildComicCardPresentation`) | SHARED PRIMITIVE (`buildDefaultCardPresentation`) | **BORROWED FROM VIDEO** (`buildVideoCardPresentation`) | SHARED PRIMITIVE (`buildDefaultCardPresentation`) | SHARED PRIMITIVE (`buildDefaultCardPresentation`) | SHARED PRIMITIVE (`buildDefaultCardPresentation`) | OWNED (`buildVideoCardPresentation`) | OWNED (`buildVideoCardPresentation`) | OWNED (`buildMusicCardPresentation`) |
| **Detail Presentation**| OWNED (`comicLibraryMediaPresentation`) | OWNED (`mangaLibraryMediaPresentation`) | OWNED (`animeLibraryMediaPresentation`) | OWNED (`bookLibraryMediaPresentation`) | OWNED (`gamesLibraryMediaPresentation`) | OWNED (`boardGamesLibraryMediaPresentation`) | OWNED (`movieLibraryMediaPresentation`) | OWNED (`tvLibraryMediaPresentation`) | OWNED (`musicLibraryMediaPresentation`) |
| **Provider Mapper** | OWNED (`ComicLibraryKindProviderMapper`) | SHARED PRIMITIVE (`DefaultLibraryKindProviderMapper`) | OWNED (`AnimeLibraryKindProviderMapper`) | OWNED (`BookLibraryKindProviderMapper`) | OWNED (`GameLibraryKindProviderMapper`) | SHARED PRIMITIVE (`DefaultLibraryKindProviderMapper`) | OWNED (`MovieLibraryKindProviderMapper`) | OWNED (`TvLibraryKindProviderMapper`) | OWNED (`MusicLibraryKindProviderMapper`) |
| **Facets** | OWNED | OWNED | OWNED | OWNED | OWNED | OWNED | OWNED | OWNED | OWNED |
| **Hierarchy** | OWNED (`LibraryContentHierarchy.volumes`) | OWNED (`LibraryContentHierarchy.volumes`) | OWNED (`LibraryContentHierarchy.seasons`) | OWNED (`LibraryContentHierarchy.volumes`) | OWNED (`LibraryContentHierarchy.flat`) | OWNED (`LibraryContentHierarchy.flat`) | OWNED (`LibraryContentHierarchy.flat`) | OWNED (`LibraryContentHierarchy.seasons`) | OWNED (`LibraryContentHierarchy.flat`) |

---

## Identified Issues & Next Steps

1. **Central Ownership Drafting Switch**:
   `LibraryKindSpec.buildPersonalDetailsDraft` currently switches on `kind` centrally in `lib/features/library/kinds/registry/library_kind_module.dart`.
2. **Central Edit Draft Dispatching**:
   `_editDraftFactoryForKind` in `library_kind_module.dart` maps `comic/manga` to `createComicEditDraft`, `movie/tv/anime` to `createVideoEditDraft`, and falls through for `boardgame` to generic.
3. **Borrowed Add Drafts**:
   - `Manga` uses `ComicAddDraft`.
   - `Anime` and `TV` use `VideoAddDraft` (whose default kind is `movie`).
4. **Borrowed Owned Details & Codecs**:
   - `Manga` uses `ComicOwnedDetails` / `ComicOwnedDetailsCodec`.
   - `Anime` and `TV` use `VideoOwnedDetails` / `VideoOwnedDetailsCodec`.
