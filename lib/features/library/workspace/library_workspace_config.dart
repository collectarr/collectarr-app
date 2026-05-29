import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:flutter/material.dart';

enum LibraryViewMode { grid, card, cardFlow, list, shelves }

extension LibraryViewModeCoverSizeSupport on LibraryViewMode {
  bool get supportsCoverSize {
    return switch (this) {
      LibraryViewMode.grid ||
      LibraryViewMode.card ||
      LibraryViewMode.shelves => true,
      LibraryViewMode.cardFlow || LibraryViewMode.list => false,
    };
  }
}

enum LibraryDetailsLayout { right, bottom, hidden }

enum LibraryGroupMode {
  // ── Main ──
  series,
  storyArc,
  character,
  title,
  publisher,
  year,
  genre,
  country,
  language,
  ageRating,
  // ── Edition ──
  audioTracks,
  boxSet,
  distributor,
  editionReleaseDate,
  editionReleaseMonth,
  editionReleaseYear,
  extras,
  format,
  hdr,
  layers,
  packaging,
  regions,
  screenRatios,
  subtitles,
  // ── Cast & Crew ──
  actor,
  director,
  musician,
  photography,
  producer,
  writer,
  creator,
  artist,
  penciller,
  colorist,
  letterer,
  coverArtist,
  editor,
  // ── Personal ──
  location,
  ownership,
  addedDate,
  addedMonth,
  addedYear,
  collectionStatus,
  grade,
  condition,
  imageType,
  modifiedDate,
  modifiedMonth,
  myRating,
  owner,
  purchaseDate,
  purchaseMonth,
  purchaseYear,
  purchaseStore,
  storageDevice,
  tags,
  watchDate,
  watchMonth,
  watchYear,
  watched,
  watchedWhere,
}

enum LibraryWorkspacePreset { cover, card, list, details }

extension LibraryWorkspacePresetLabels on LibraryWorkspacePreset {
  String get label {
    return switch (this) {
      LibraryWorkspacePreset.cover => 'Grid',
      LibraryWorkspacePreset.card => 'Cards',
      LibraryWorkspacePreset.list => 'List',
      LibraryWorkspacePreset.details => 'Details panel',
    };
  }

  IconData get icon {
    return switch (this) {
      LibraryWorkspacePreset.cover => Icons.grid_view,
      LibraryWorkspacePreset.card => Icons.view_module,
      LibraryWorkspacePreset.list => Icons.view_list,
      LibraryWorkspacePreset.details => Icons.view_sidebar,
    };
  }
}

enum LibrarySortColumn {
  status,
  title,
  issue,
  variant,
  publisher,
  releaseDate,
  barcode,
  grade,
  condition,
  price,
  storageBox,
  wishlist,
  updated,
  country,
  language,
  pageCount,
  ageRating,
  imprint,
}

class LibrarySortRule {
  const LibrarySortRule({required this.column, required this.ascending});

  final LibrarySortColumn column;
  final bool ascending;

  LibrarySortRule copyWith({
    LibrarySortColumn? column,
    bool? ascending,
  }) {
    return LibrarySortRule(
      column: column ?? this.column,
      ascending: ascending ?? this.ascending,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LibrarySortRule &&
        other.column == column &&
        other.ascending == ascending;
  }

  @override
  int get hashCode => Object.hash(column, ascending);
}

enum LibraryTableColumn {
  status,
  cover,
  title,
  issue,
  variant,
  publisher,
  releaseDate,
  barcode,
  grade,
  condition,
  price,
  storageBox,
  wishlist,
  updated,
  country,
  language,
  pageCount,
  ageRating,
  imprint,
}

enum LibraryTableColumnGroup { main, edition, value, personal }

class LibraryTableColumnPreset {
  const LibraryTableColumnPreset({
    this.id,
    required this.label,
    required this.columns,
  });

  final String? id;
  final String label;
  final Set<LibraryTableColumn> columns;

  bool get isSaved => id != null;
}

class LibraryWorkspaceConfig {
  const LibraryWorkspaceConfig({
    required this.kind,
    required this.title,
    required this.icon,
    required this.preferencePrefix,
    required this.defaultSortColumn,
    required this.defaultVisibleColumns,
  });

  final CatalogMediaKind kind;
  final String title;
  final IconData icon;
  final String preferencePrefix;
  final LibrarySortColumn defaultSortColumn;
  final Set<LibraryTableColumn> defaultVisibleColumns;

  String preferenceKey(String suffix) => '$preferencePrefix.$suffix';
}
