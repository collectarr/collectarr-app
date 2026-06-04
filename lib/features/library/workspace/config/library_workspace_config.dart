import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:flutter/material.dart';

enum LibraryViewMode { grid, card, cardFlow, list, shelves }

enum LibraryWorkspaceBrowserMode { media, releases }

extension LibraryViewModeCoverSizeSupport on LibraryViewMode {
  bool get supportsCoverSize {
    return switch (this) {
      LibraryViewMode.grid ||
      LibraryViewMode.card ||
      LibraryViewMode.shelves =>
        true,
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

const kAllLibrarySortColumns = [
  LibrarySortColumn.status,
  LibrarySortColumn.title,
  LibrarySortColumn.series,
  LibrarySortColumn.issue,
  LibrarySortColumn.storyArc,
  LibrarySortColumn.variant,
  LibrarySortColumn.format,
  LibrarySortColumn.publisher,
  LibrarySortColumn.releaseDate,
  LibrarySortColumn.barcode,
  LibrarySortColumn.grade,
  LibrarySortColumn.rawOrSlabbed,
  LibrarySortColumn.gradingCompany,
  LibrarySortColumn.condition,
  LibrarySortColumn.price,
  LibrarySortColumn.location,
  LibrarySortColumn.collectionStatus,
  LibrarySortColumn.wishlist,
  LibrarySortColumn.keyComic,
  LibrarySortColumn.added,
  LibrarySortColumn.updated,
  LibrarySortColumn.country,
  LibrarySortColumn.language,
  LibrarySortColumn.pageCount,
  LibrarySortColumn.ageRating,
  LibrarySortColumn.imprint,
];

const kPlannedLibrarySortColumns = [
  LibrarySortColumn.status,
  LibrarySortColumn.title,
  LibrarySortColumn.series,
  LibrarySortColumn.issue,
  LibrarySortColumn.storyArc,
  LibrarySortColumn.variant,
  LibrarySortColumn.format,
  LibrarySortColumn.publisher,
  LibrarySortColumn.releaseDate,
  LibrarySortColumn.barcode,
  LibrarySortColumn.grade,
  LibrarySortColumn.condition,
  LibrarySortColumn.price,
  LibrarySortColumn.location,
  LibrarySortColumn.collectionStatus,
  LibrarySortColumn.wishlist,
  LibrarySortColumn.added,
  LibrarySortColumn.updated,
  LibrarySortColumn.country,
  LibrarySortColumn.language,
  LibrarySortColumn.pageCount,
  LibrarySortColumn.ageRating,
  LibrarySortColumn.imprint,
];

const kComicLibrarySortColumns = [
  LibrarySortColumn.status,
  LibrarySortColumn.title,
  LibrarySortColumn.series,
  LibrarySortColumn.issue,
  LibrarySortColumn.storyArc,
  LibrarySortColumn.variant,
  LibrarySortColumn.format,
  LibrarySortColumn.publisher,
  LibrarySortColumn.releaseDate,
  LibrarySortColumn.barcode,
  LibrarySortColumn.grade,
  LibrarySortColumn.rawOrSlabbed,
  LibrarySortColumn.gradingCompany,
  LibrarySortColumn.condition,
  LibrarySortColumn.price,
  LibrarySortColumn.location,
  LibrarySortColumn.collectionStatus,
  LibrarySortColumn.wishlist,
  LibrarySortColumn.keyComic,
  LibrarySortColumn.added,
  LibrarySortColumn.updated,
  LibrarySortColumn.country,
  LibrarySortColumn.language,
  LibrarySortColumn.pageCount,
  LibrarySortColumn.ageRating,
  LibrarySortColumn.imprint,
];

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
  title,
  issue,
  variant,
  format,
  publisher,
  releaseDate,
  barcode,
  grade,
  condition,
  price,
  location,
  wishlist,
  added,
  updated,
  country,
  language,
  pageCount,
  ageRating,
  imprint,
}

const kAllLibraryTableColumns = [
  LibraryTableColumn.status,
  LibraryTableColumn.cover,
  LibraryTableColumn.title,
  LibraryTableColumn.issue,
  LibraryTableColumn.variant,
  LibraryTableColumn.format,
  LibraryTableColumn.publisher,
  LibraryTableColumn.releaseDate,
  LibraryTableColumn.barcode,
  LibraryTableColumn.grade,
  LibraryTableColumn.condition,
  LibraryTableColumn.price,
  LibraryTableColumn.location,
  LibraryTableColumn.wishlist,
  LibraryTableColumn.added,
  LibraryTableColumn.updated,
  LibraryTableColumn.country,
  LibraryTableColumn.language,
  LibraryTableColumn.pageCount,
  LibraryTableColumn.ageRating,
  LibraryTableColumn.imprint,
];

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
    this.availableSortColumns = kAllLibrarySortColumns,
    this.availableTableColumns = kAllLibraryTableColumns,
  });

  final CatalogMediaKind kind;
  final String title;
  final IconData icon;
  final Color accent;
  final String preferencePrefix;
  final LibrarySortColumn defaultSortColumn;
  final Set<LibraryTableColumn> defaultVisibleColumns;
  final List<LibrarySortColumn> availableSortColumns;
  final List<LibraryTableColumn> availableTableColumns;

  bool supportsSortColumn(LibrarySortColumn column) {
    return availableSortColumns.contains(column);
  }

  bool supportsTableColumn(LibraryTableColumn column) {
    return availableTableColumns.contains(column);
  }

  String preferenceKey(String suffix) => '$preferencePrefix.$suffix';
}
