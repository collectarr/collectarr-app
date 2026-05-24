import 'package:collectarr_app/features/library/config/collection_defaults.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/library_edit_builders.dart';
import 'package:collectarr_app/features/library/kinds/manga/presentation.dart';
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
  editDialogBuilder: buildGenericLibraryEditDialog,
  presentation: mangaLibraryMediaPresentation,
  capabilities: LibraryTypeCapabilities(
    showsSynopsis: true,
    contentHierarchy: LibraryContentHierarchy.volumes,
  ),
  conditions: kComicConditions,
);