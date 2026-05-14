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
  defaultMetadataProvider: 'anilist',
  metadataProviders: [
    anilistMetadataProvider,
  ],
  trackingProfile: readingTrackingProfile,
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

const blurayWorkspaceConfig = LibraryWorkspaceConfig(
  kind: 'bluray',
  title: 'Blu-rays',
  icon: Icons.album,
  preferencePrefix: 'bluray',
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

const blurayLibraryConfig = LibraryTypeConfig(
  workspace: blurayWorkspaceConfig,
  singularLabel: 'Blu-ray',
  pluralLabel: 'Blu-rays',
  defaultMetadataProvider: 'tmdb',
  metadataProviders: [
    tmdbMetadataProvider,
  ],
  trackingProfile: videoTrackingProfile,
);
