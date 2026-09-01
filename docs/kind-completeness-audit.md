# Kind Completeness & Collector Data Audit Matrix

This document provides the verified completeness audit of all 9 active media kinds in Collectarr (`comic`, `manga`, `anime`, `book`, `game`, `boardgame`, `movie`, `tv`, `music`).

Each capability/layer is marked as:
- **OWNED**: Dedicated kind-specific implementation.
- **SHARED PRIMITIVE**: Shared infrastructure/primitive without kind leakage.

---

## Kind Completeness Matrix

| Capability / Layer | Comic | Manga | Anime | Book | Game | Boardgame | Movie | TV | Music |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Catalog Item Model** | OWNED (`ComicIssueDto`) | OWNED (`MangaChapterDto`) | OWNED (`AnimeEpisodeDto`) | OWNED (`BookVolumeDto`) | OWNED (`GameDto`) | OWNED (`BoardgameDto`) | OWNED (`MovieDto`) | OWNED (`TvSeriesDto`) | OWNED (`MusicAlbumDto`) |
| **Release Model** | SHARED PRIMITIVE (`CatalogEditionDto`) | SHARED PRIMITIVE (`CatalogEditionDto`) | SHARED PRIMITIVE (`CatalogEditionDto`) | SHARED PRIMITIVE (`CatalogEditionDto`) | SHARED PRIMITIVE (`CatalogEditionDto`) | SHARED PRIMITIVE (`CatalogEditionDto`) | SHARED PRIMITIVE (`CatalogEditionDto`) | SHARED PRIMITIVE (`CatalogEditionDto`) | SHARED PRIMITIVE (`CatalogEditionDto`) |
| **Owned Details Type** | OWNED (`ComicOwnedDetails`) | OWNED (`MangaOwnedDetails`) | OWNED (`AnimeOwnedDetails`) | OWNED (`BookOwnedDetails`) | OWNED (`GameOwnedDetails`) | OWNED (`BoardgameOwnedDetails`) | OWNED (`MovieOwnedDetails`) | OWNED (`TvOwnedDetails`) | OWNED (`MusicOwnedDetails`) |
| **Owned Details Codec** | OWNED (`ComicOwnedDetailsCodec`) | OWNED (`MangaOwnedDetailsCodec`) | OWNED (`AnimeOwnedDetailsCodec`) | OWNED (`BookOwnedDetailsCodec`) | OWNED (`GameOwnedDetailsCodec`) | OWNED (`BoardgameOwnedDetailsCodec`) | OWNED (`MovieOwnedDetailsCodec`) | OWNED (`TvOwnedDetailsCodec`) | OWNED (`MusicOwnedDetailsCodec`) |
| **Personal-Details Draft** | OWNED (`ComicOwnedDetailsDraft`) | OWNED (`MangaOwnedDetailsDraft`) | OWNED (`AnimeOwnedDetailsDraft`) | OWNED (`BookOwnedDetailsDraft`) | OWNED (`GameOwnedDetailsDraft`) | OWNED (`BoardgameOwnedDetailsDraft`) | OWNED (`MovieOwnedDetailsDraft`) | OWNED (`TvOwnedDetailsDraft`) | OWNED (`MusicOwnedDetailsDraft`) |
| **Add Draft** | OWNED (`ComicAddDraft`) | OWNED (`MangaAddDraft`) | OWNED (`AnimeAddDraft`) | OWNED (`BookAddDraft`) | OWNED (`GameAddDraft`) | OWNED (`BoardGameAddDraft`) | OWNED (`MovieAddDraft`) | OWNED (`TvAddDraft`) | OWNED (`MusicAddDraft`) |
| **Add Capability** | OWNED (`StandardLibraryAddCapability<ComicAddDraft>`) | OWNED (`StandardLibraryAddCapability<MangaAddDraft>`) | OWNED (`StandardLibraryAddCapability<AnimeAddDraft>`) | OWNED (`StandardLibraryAddCapability<BookAddDraft>`) | OWNED (`StandardLibraryAddCapability<GameAddDraft>`) | OWNED (`StandardLibraryAddCapability<BoardGameAddDraft>`) | OWNED (`StandardLibraryAddCapability<MovieAddDraft>`) | OWNED (`StandardLibraryAddCapability<TvAddDraft>`) | OWNED (`StandardLibraryAddCapability<MusicAddDraft>`) |
| **Edit Draft** | OWNED (`ComicEditDraft`) | OWNED (`MangaEditDraft`) | OWNED (`AnimeEditDraft`) | OWNED (`BookEditDraft`) | OWNED (`GameEditDraft`) | OWNED (`BoardGameEditDraft`) | OWNED (`MovieEditDraft`) | OWNED (`TvEditDraft`) | OWNED (`MusicEditDraft`) |
| **Edit Capability** | OWNED (`LibraryEditCapability`) | OWNED (`LibraryEditCapability`) | OWNED (`LibraryEditCapability`) | OWNED (`LibraryEditCapability`) | OWNED (`LibraryEditCapability`) | OWNED (`LibraryEditCapability`) | OWNED (`LibraryEditCapability`) | OWNED (`LibraryEditCapability`) | OWNED (`LibraryEditCapability`) |
| **Workspace DTO** | OWNED (`ComicWorkspaceDto`) | OWNED (`MangaWorkspaceDto`) | OWNED (`AnimeWorkspaceDto`) | OWNED (`BookWorkspaceDto`) | OWNED (`GameWorkspaceDto`) | OWNED (`BoardGameWorkspaceDto`) | OWNED (`MovieWorkspaceDto`) | OWNED (`TvWorkspaceDto`) | OWNED (`MusicWorkspaceDto`) |
| **Workspace Projector** | OWNED (`ComicWorkspaceProjector`) | OWNED (`MangaWorkspaceProjector`) | OWNED (`AnimeWorkspaceProjector`) | OWNED (`BookWorkspaceProjector`) | OWNED (`GameWorkspaceProjector`) | OWNED (`BoardGameWorkspaceProjector`) | OWNED (`MovieWorkspaceProjector`) | OWNED (`TvWorkspaceProjector`) | OWNED (`MusicWorkspaceProjector`) |
| **Field Registry & Scopes** | OWNED (`comicLibraryKindSchema`) | OWNED (`mangaLibraryKindSchema`) | OWNED (`animeLibraryKindSchema`) | OWNED (`bookLibraryKindSchema`) | OWNED (`gameLibraryKindSchema`) | OWNED (`boardgameLibraryKindSchema`) | OWNED (`movieLibraryKindSchema`) | OWNED (`tvLibraryKindSchema`) | OWNED (`musicLibraryKindSchema`) |
| **Card Presentation** | OWNED (`buildComicCardPresentation`) | OWNED (`buildMangaCardPresentation`) | OWNED (`buildAnimeCardPresentation`) | OWNED (`buildBookCardPresentation`) | OWNED (`buildGameCardPresentation`) | OWNED (`buildBoardGameCardPresentation`) | OWNED (`buildMovieCardPresentation`) | OWNED (`buildTvCardPresentation`) | OWNED (`buildMusicCardPresentation`) |
| **Detail Presentation**| OWNED (`comicLibraryMediaPresentation`) | OWNED (`mangaLibraryMediaPresentation`) | OWNED (`animeLibraryMediaPresentation`) | OWNED (`bookLibraryMediaPresentation`) | OWNED (`gamesLibraryMediaPresentation`) | OWNED (`boardGamesLibraryMediaPresentation`) | OWNED (`movieLibraryMediaPresentation`) | OWNED (`tvLibraryMediaPresentation`) | OWNED (`musicLibraryMediaPresentation`) |
| **Provider Mapper** | OWNED (`ComicLibraryKindProviderMapper`) | OWNED (`MangaLibraryKindProviderMapper`) | OWNED (`AnimeLibraryKindProviderMapper`) | OWNED (`BookLibraryKindProviderMapper`) | OWNED (`GameLibraryKindProviderMapper`) | OWNED (`BoardGameLibraryKindProviderMapper`) | OWNED (`MovieLibraryKindProviderMapper`) | OWNED (`TvLibraryKindProviderMapper`) | OWNED (`MusicLibraryKindProviderMapper`) |
| **Hierarchy** | OWNED (`LibraryHierarchyCapability`, volume children) | OWNED (`LibraryHierarchyCapability`, volume children) | OWNED (`LibraryHierarchyCapability`, video defaults) | OWNED (`LibraryHierarchyCapability`, volume children) | OWNED (`LibraryHierarchyCapability`, release split) | OWNED (`LibraryHierarchyCapability`, release split) | OWNED (`LibraryHierarchyCapability`, release split) | OWNED (`LibraryHierarchyCapability`, season children) | OWNED (`LibraryHierarchyCapability`, release split) |

---

## Architectural Guarantees Verified by Automated Contracts

1. **Explicit Kind Independence**: All 9 kinds are fully isolated. Zero borrowed drafts, zero generic drafts/details fallbacks in production specs.
2. **Strict Field Scoping**: Every field defined in the kind registries explicitly specifies its `LibraryFieldScope` (`copy`, `release`, or `media`), enforced by contract tests.
3. **Dedicated Ownership Types & Codecs**: All 9 kinds serialize and deserialize through their own dedicated codecs and typed `OwnedItemDetails` models.
