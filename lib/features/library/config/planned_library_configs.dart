import 'package:collectarr_app/features/library/config/collection_defaults.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';

const mangaWorkspaceConfig = LibraryWorkspaceConfig(
  kind: 'manga',
  title: 'Manga',
  icon: Icons.auto_stories,
  preferencePrefix: 'manga',
  defaultSortColumn: LibrarySortColumn.title,
  defaultVisibleColumns: {
    LibraryTableColumn.status,
    LibraryTableColumn.cover,
    LibraryTableColumn.title,
    LibraryTableColumn.issue,
    LibraryTableColumn.publisher,
    LibraryTableColumn.releaseDate,
    LibraryTableColumn.condition,
    LibraryTableColumn.price,
    LibraryTableColumn.storageBox,
    LibraryTableColumn.wishlist,
    LibraryTableColumn.updated,
  },
);

const mangaLibraryConfig = LibraryTypeConfig(
  workspace: mangaWorkspaceConfig,
  singularLabel: 'Manga',
  pluralLabel: 'Manga',
  defaultMetadataProvider: 'anilist',
  metadataProviders: [
    anilistMetadataProvider,
    mangadexMetadataProvider,
    comicVineMetadataProvider,
    hardcoverMetadataProvider,
  ],
  trackingProfile: readingTrackingProfile,
  presentation: mangaLibraryMediaPresentation,
  capabilities: LibraryTypeCapabilities(
    showsSynopsis: true,
    contentHierarchy: LibraryContentHierarchy.volumes,
  ),
  conditions: kComicConditions,
);

const animeWorkspaceConfig = LibraryWorkspaceConfig(
  kind: 'anime',
  title: 'Anime',
  icon: Icons.movie_filter_outlined,
  preferencePrefix: 'anime',
  defaultSortColumn: LibrarySortColumn.title,
  defaultVisibleColumns: {
    LibraryTableColumn.status,
    LibraryTableColumn.cover,
    LibraryTableColumn.title,
    LibraryTableColumn.publisher,
    LibraryTableColumn.releaseDate,
    LibraryTableColumn.condition,
    LibraryTableColumn.price,
    LibraryTableColumn.storageBox,
    LibraryTableColumn.wishlist,
    LibraryTableColumn.updated,
  },
);

const animeLibraryConfig = LibraryTypeConfig(
  workspace: animeWorkspaceConfig,
  singularLabel: 'Anime',
  pluralLabel: 'Anime',
  defaultMetadataProvider: 'anilist',
  metadataProviders: [
    anilistMetadataProvider,
    tmdbMetadataProvider,
  ],
  trackingProfile: videoTrackingProfile,
  presentation: animeLibraryMediaPresentation,
  capabilities: LibraryTypeCapabilities(
    showsSynopsis: true,
    contentHierarchy: LibraryContentHierarchy.seasons,
  ),
);

const booksWorkspaceConfig = LibraryWorkspaceConfig(
  kind: 'book',
  title: 'Books',
  icon: Icons.menu_book_outlined,
  preferencePrefix: 'books',
  defaultSortColumn: LibrarySortColumn.title,
  defaultVisibleColumns: {
    LibraryTableColumn.status,
    LibraryTableColumn.cover,
    LibraryTableColumn.title,
    LibraryTableColumn.publisher,
    LibraryTableColumn.releaseDate,
    LibraryTableColumn.barcode,
    LibraryTableColumn.condition,
    LibraryTableColumn.price,
    LibraryTableColumn.storageBox,
    LibraryTableColumn.wishlist,
    LibraryTableColumn.updated,
  },
);

const booksLibraryConfig = LibraryTypeConfig(
  workspace: booksWorkspaceConfig,
  singularLabel: 'Book',
  pluralLabel: 'Books',
  defaultMetadataProvider: 'openlibrary',
  metadataProviders: [
    openLibraryMetadataProvider,
    hardcoverMetadataProvider,
  ],
  trackingProfile: readingTrackingProfile,
  presentation: booksLibraryMediaPresentation,
  capabilities: LibraryTypeCapabilities(
    showsSynopsis: true,
    contentHierarchy: LibraryContentHierarchy.volumes,
  ),
  conditions: kBookConditions,
);

const gamesWorkspaceConfig = LibraryWorkspaceConfig(
  kind: 'game',
  title: 'Games',
  icon: Icons.sports_esports,
  preferencePrefix: 'games',
  defaultSortColumn: LibrarySortColumn.title,
  defaultVisibleColumns: {
    LibraryTableColumn.status,
    LibraryTableColumn.cover,
    LibraryTableColumn.title,
    LibraryTableColumn.publisher,
    LibraryTableColumn.releaseDate,
    LibraryTableColumn.barcode,
    LibraryTableColumn.condition,
    LibraryTableColumn.price,
    LibraryTableColumn.storageBox,
    LibraryTableColumn.wishlist,
    LibraryTableColumn.updated,
  },
);

const gamesLibraryConfig = LibraryTypeConfig(
  workspace: gamesWorkspaceConfig,
  singularLabel: 'Game',
  pluralLabel: 'Games',
  defaultMetadataProvider: 'igdb',
  metadataProviders: [
    igdbMetadataProvider,
  ],
  trackingProfile: gameTrackingProfile,
  presentation: gamesLibraryMediaPresentation,
);

const boardGamesWorkspaceConfig = LibraryWorkspaceConfig(
  kind: 'boardgame',
  title: 'Board Games',
  icon: Icons.casino_outlined,
  preferencePrefix: 'boardgames',
  defaultSortColumn: LibrarySortColumn.title,
  defaultVisibleColumns: {
    LibraryTableColumn.status,
    LibraryTableColumn.cover,
    LibraryTableColumn.title,
    LibraryTableColumn.publisher,
    LibraryTableColumn.releaseDate,
    LibraryTableColumn.barcode,
    LibraryTableColumn.condition,
    LibraryTableColumn.price,
    LibraryTableColumn.storageBox,
    LibraryTableColumn.wishlist,
    LibraryTableColumn.updated,
  },
);

const boardGamesLibraryConfig = LibraryTypeConfig(
  workspace: boardGamesWorkspaceConfig,
  singularLabel: 'Board Game',
  pluralLabel: 'Board Games',
  defaultMetadataProvider: 'bgg',
  metadataProviders: [
    bggMetadataProvider,
  ],
  trackingProfile: gameTrackingProfile,
  presentation: boardGamesLibraryMediaPresentation,
);

const moviesWorkspaceConfig = LibraryWorkspaceConfig(
  kind: 'movie',
  title: 'Movies',
  icon: Icons.movie_outlined,
  preferencePrefix: 'movies',
  defaultSortColumn: LibrarySortColumn.title,
  defaultVisibleColumns: {
    LibraryTableColumn.status,
    LibraryTableColumn.cover,
    LibraryTableColumn.title,
    LibraryTableColumn.publisher,
    LibraryTableColumn.releaseDate,
    LibraryTableColumn.barcode,
    LibraryTableColumn.condition,
    LibraryTableColumn.price,
    LibraryTableColumn.storageBox,
    LibraryTableColumn.wishlist,
    LibraryTableColumn.updated,
  },
);

const moviesLibraryConfig = LibraryTypeConfig(
  workspace: moviesWorkspaceConfig,
  singularLabel: 'Movie',
  pluralLabel: 'Movies',
  defaultMetadataProvider: 'tmdb',
  metadataProviders: [
    tmdbMetadataProvider,
  ],
  trackingProfile: videoTrackingProfile,
  presentation: moviesLibraryMediaPresentation,
  capabilities: LibraryTypeCapabilities(
    showsSynopsis: true,
  ),
);

const musicWorkspaceConfig = LibraryWorkspaceConfig(
  kind: 'music',
  title: 'Music',
  icon: Icons.music_note,
  preferencePrefix: 'music',
  defaultSortColumn: LibrarySortColumn.title,
  defaultVisibleColumns: {
    LibraryTableColumn.status,
    LibraryTableColumn.cover,
    LibraryTableColumn.title,
    LibraryTableColumn.publisher,
    LibraryTableColumn.releaseDate,
    LibraryTableColumn.barcode,
    LibraryTableColumn.condition,
    LibraryTableColumn.price,
    LibraryTableColumn.storageBox,
    LibraryTableColumn.wishlist,
    LibraryTableColumn.updated,
  },
);

const musicLibraryConfig = LibraryTypeConfig(
  workspace: musicWorkspaceConfig,
  singularLabel: 'Music',
  pluralLabel: 'Music',
  defaultMetadataProvider: 'musicbrainz',
  metadataProviders: [
    musicBrainzMetadataProvider,
  ],
  trackingProfile: listeningTrackingProfile,
  presentation: musicLibraryMediaPresentation,
  capabilities: LibraryTypeCapabilities(
    showsTrackData: true,
  ),
);

const tvWorkspaceConfig = LibraryWorkspaceConfig(
  kind: 'tv',
  title: 'TV Shows',
  icon: Icons.tv,
  preferencePrefix: 'tv',
  defaultSortColumn: LibrarySortColumn.title,
  defaultVisibleColumns: {
    LibraryTableColumn.status,
    LibraryTableColumn.cover,
    LibraryTableColumn.title,
    LibraryTableColumn.publisher,
    LibraryTableColumn.releaseDate,
    LibraryTableColumn.barcode,
    LibraryTableColumn.condition,
    LibraryTableColumn.price,
    LibraryTableColumn.storageBox,
    LibraryTableColumn.wishlist,
    LibraryTableColumn.updated,
  },
);

const tvLibraryConfig = LibraryTypeConfig(
  workspace: tvWorkspaceConfig,
  singularLabel: 'TV show',
  pluralLabel: 'TV shows',
  defaultMetadataProvider: 'tmdb',
  metadataProviders: [
    tmdbMetadataProvider,
  ],
  trackingProfile: videoTrackingProfile,
  presentation: tvLibraryMediaPresentation,
  capabilities: LibraryTypeCapabilities(
    showsSynopsis: true,
    contentHierarchy: LibraryContentHierarchy.seasons,
  ),
);
