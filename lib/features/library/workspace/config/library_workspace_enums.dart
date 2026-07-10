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

enum LibrarySortFieldGroup { main, value, edition, personal }
