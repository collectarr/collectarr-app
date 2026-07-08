import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/config/library_toolbar_config.dart';
import 'package:flutter/material.dart';

enum LibraryViewMode { grid, card, horizontalCards, cardFlow, list, shelves }

enum LibraryWorkspaceBrowserMode { media, releases }

enum LibraryWorkspaceDensityPreset { comfortable, compact, ultraCompact }

extension LibraryViewModeCoverSizeSupport on LibraryViewMode {
  bool get supportsCoverSize {
    return switch (this) {
      LibraryViewMode.grid ||
      LibraryViewMode.card ||
      LibraryViewMode.horizontalCards ||
      LibraryViewMode.shelves =>
        true,
      LibraryViewMode.cardFlow || LibraryViewMode.list => false,
    };
  }
}

enum LibraryDetailsLayout { right, bottom, hidden }

enum LibraryFolderDisplayMode { drilldown, tree }

extension LibraryFolderDisplayModeLabels on LibraryFolderDisplayMode {
  String get label {
    return switch (this) {
      LibraryFolderDisplayMode.drilldown => 'Drilldown',
      LibraryFolderDisplayMode.tree => 'Tree',
    };
  }

  IconData get icon {
    return switch (this) {
      LibraryFolderDisplayMode.drilldown => Icons.segment,
      LibraryFolderDisplayMode.tree => Icons.account_tree_outlined,
    };
  }
}

enum LibraryGroupMode {
  // ── Main ──
  series,
  storyArc,
  character,
  title,
  publisher,
  year,
  audienceRating,
  color,
  genre,
  platform,
  developer,
  country,
  language,
  ageRating,
  crossover,
  imprint,
  seriesGroup,
  movieOrTvSeries,
  releaseDate,
  releaseMonth,
  releaseYear,
  publicationPlace,
  originalReleaseDate,
  originalReleaseMonth,
  originalReleaseYear,
  originalCountry,
  originalLanguage,
  originalPublicationDate,
  originalPublicationMonth,
  originalPublicationYear,
  originalPublicationPlace,
  originalPublisher,
  recordingDate,
  recordingMonth,
  recordingYear,
  coverDate,
  coverMonth,
  coverYear,
  // ── Edition ──
  audioTracks,
  boxSet,
  completeness,
  valueLocked,
  dustJacketCondition,
  distributor,
  instrument,
  isLive,
  mediaCondition,
  rpm,
  spars,
  soundType,
  studio,
  vinylColor,
  toySubtype,
  toyType,
  edition,
  audiobookAbridged,
  firstEdition,
  narrator,
  paperType,
  printedBy,
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
  chorus,
  composer,
  composition,
  conductor,
  engineer,
  director,
  musician,
  orchestra,
  photography,
  producer,
  writer,
  creator,
  artist,
  penciller,
  inker,
  colorist,
  painter,
  letterer,
  separator,
  layouts,
  translator,
  plotter,
  scripter,
  coverArtist,
  coverPenciller,
  coverPainter,
  coverInker,
  coverColorist,
  coverSeparator,
  editor,
  editorInChief,
  forewordAuthor,
  ghostWriter,
  illustrator,
  // ── Personal ──
  location,
  ownership,
  addedDate,
  addedMonth,
  addedYear,
  collectionStatus,
  grade,
  condition,
  rawOrSlabbed,
  isKeyComic,
  imageType,
  modifiedDate,
  modifiedMonth,
  myRating,
  owner,
  reader,
  readingStatus,
  completed,
  completedDate,
  completedMonth,
  completedYear,
  readDate,
  readMonth,
  readYear,
  isSigned,
  signedBy,
  purchaseDate,
  purchaseMonth,
  purchaseYear,
  purchaseStore,
  soldDate,
  soldMonth,
  soldYear,
  storageDevice,
  dustJacket,
  subject,
  tags,
  bagBoardDate,
  bagBoardMonth,
  bagBoardYear,
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
  series,
  issue,
  storyArc,
  variant,
  format,
  publisher,
  releaseDate,
  barcode,
  grade,
  rawOrSlabbed,
  gradingCompany,
  condition,
  price,
  location,
  collectionStatus,
  wishlist,
  keyComic,
  added,
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

class LibrarySortPreset {
  const LibrarySortPreset({
    this.id,
    required this.label,
    required this.rules,
    this.icon,
    this.isBuiltIn = false,
  });

  final String? id;
  final String label;
  final List<LibrarySortRule> rules;
  final IconData? icon;
  final bool isBuiltIn;

  bool get isSaved => id != null && !isBuiltIn;
}

enum LibraryTableColumn {
  status,
  cover,
  frontCover,
  backCover,
  hasFront,
  hasBack,
  extraImages,
  author,
  artist,
  album,
  title,
  issue,
  variant,
  format,
  publisher,
  label,
  catalogNumber,
  platform,
  developer,
  releaseDate,
  releasePlatform,
  barcode,
  discCount,
  trackCount,
  length,
  vinylColor,
  rpm,
  grade,
  condition,
  completion,
  price,
  value,
  location,
  readStatus,
  rating,
  wishlist,
  added,
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
    required this.accent,
    required this.preferencePrefix,
    required this.defaultSortColumn,
    required this.defaultVisibleColumns,
    this.defaultDensityPreset = LibraryWorkspaceDensityPreset.compact,
    this.availableSortColumns = const [],
    this.availableTableColumns = const [],
    this.availableDensityPresets = const [
      LibraryWorkspaceDensityPreset.comfortable,
      LibraryWorkspaceDensityPreset.compact,
      LibraryWorkspaceDensityPreset.ultraCompact,
    ],
    this.toolbarActions = kDefaultLibraryToolbarActions,
  });

  final CatalogMediaKind kind;
  final String title;
  final IconData icon;
  final Color accent;
  final String preferencePrefix;
  final LibrarySortColumn defaultSortColumn;
  final Set<LibraryTableColumn> defaultVisibleColumns;
  final LibraryWorkspaceDensityPreset defaultDensityPreset;
  final List<LibrarySortColumn> availableSortColumns;
  final List<LibraryTableColumn> availableTableColumns;
  final List<LibraryWorkspaceDensityPreset> availableDensityPresets;
  final List<LibraryToolbarActionId> toolbarActions;

  bool supportsSortColumn(LibrarySortColumn column) {
    return availableSortColumns.contains(column);
  }

  bool supportsTableColumn(LibraryTableColumn column) {
    return availableTableColumns.contains(column);
  }

  bool supportsDensityPreset(LibraryWorkspaceDensityPreset preset) {
    return availableDensityPresets.contains(preset);
  }

  String preferenceKey(String suffix) => '$preferencePrefix.$suffix';

  String sortColumnFieldId(LibrarySortColumn column) {
    return '${kind.apiValue}.${column.name}';
  }

  String tableColumnFieldId(LibraryTableColumn column) {
    return '${kind.apiValue}.${column.name}';
  }

  LibrarySortColumn? sortColumnFromFieldId(String? fieldId) {
    if (fieldId == null || fieldId.trim().isEmpty) {
      return null;
    }
    final normalized = fieldId.trim();
    for (final column in availableSortColumns) {
      if (sortColumnFieldId(column) == normalized ||
          column.name == normalized) {
        return column;
      }
    }
    return null;
  }

  LibraryTableColumn? tableColumnFromFieldId(String? fieldId) {
    if (fieldId == null || fieldId.trim().isEmpty) {
      return null;
    }
    final normalized = fieldId.trim();
    for (final column in availableTableColumns) {
      if (tableColumnFieldId(column) == normalized ||
          column.name == normalized) {
        return column;
      }
    }
    return null;
  }
}
