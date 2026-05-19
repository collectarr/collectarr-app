import 'package:collectarr_app/features/library/library_type_config.dart';
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
  defaultMetadataProvider: 'mangadex',
  metadataProviders: [
    mangadexMetadataProvider,
    anilistMetadataProvider,
    comicVineMetadataProvider,
  ],
  trackingProfile: readingTrackingProfile,
);

const animeWorkspaceConfig = LibraryWorkspaceConfig(
  kind: 'anime',
  title: 'Anime',
  icon: Icons.smart_display,
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
  ],
  trackingProfile: readingTrackingProfile,
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
);

const musicWorkspaceConfig = LibraryWorkspaceConfig(
  kind: 'music',
  title: 'Music',
  icon: Icons.album_outlined,
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
  singularLabel: 'Music Release',
  pluralLabel: 'Music Releases',
  defaultMetadataProvider: 'musicbrainz',
  metadataProviders: [
    musicBrainzMetadataProvider,
  ],
  trackingProfile: readingTrackingProfile,
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
);
