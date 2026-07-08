import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/collection_defaults.dart';
import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/kinds/comic/add_dialog.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/library_kind_workspace_behavior.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/comic/inspector_hero.dart';
import 'package:collectarr_app/features/library/kinds/comic/inspector_sections.dart';
import 'package:collectarr_app/features/library/kinds/comic/presentation.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';

const comicsLibrarySortColumns = [
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

const comicsLibraryTableColumns = [
  LibraryTableColumn.status,
  LibraryTableColumn.cover,
  LibraryTableColumn.frontCover,
  LibraryTableColumn.backCover,
  LibraryTableColumn.hasFront,
  LibraryTableColumn.hasBack,
  LibraryTableColumn.extraImages,
  LibraryTableColumn.title,
  LibraryTableColumn.issue,
  LibraryTableColumn.variant,
  LibraryTableColumn.publisher,
  LibraryTableColumn.releaseDate,
  LibraryTableColumn.barcode,
  LibraryTableColumn.grade,
  LibraryTableColumn.condition,
  LibraryTableColumn.value,
  LibraryTableColumn.price,
  LibraryTableColumn.location,
  LibraryTableColumn.wishlist,
  LibraryTableColumn.updated,
];

const comicsWorkspaceConfig = LibraryWorkspaceConfig(
  kind: CatalogMediaKind.comic,
  title: 'Comics',
  icon: Icons.collections_bookmark_outlined,
  accent: Color(0xFF44BFE7),
  preferencePrefix: 'comics',
  defaultSortColumn: LibrarySortColumn.title,
  availableSortColumns: comicsLibrarySortColumns,
  availableTableColumns: comicsLibraryTableColumns,
  defaultVisibleColumns: {
    LibraryTableColumn.status,
    LibraryTableColumn.cover,
    LibraryTableColumn.frontCover,
    LibraryTableColumn.backCover,
    LibraryTableColumn.title,
    LibraryTableColumn.issue,
    LibraryTableColumn.variant,
    LibraryTableColumn.publisher,
    LibraryTableColumn.releaseDate,
    LibraryTableColumn.barcode,
    LibraryTableColumn.grade,
    LibraryTableColumn.condition,
    LibraryTableColumn.value,
    LibraryTableColumn.price,
    LibraryTableColumn.location,
    LibraryTableColumn.wishlist,
    LibraryTableColumn.updated,
  },
);

final comicsLibraryConfig = LibraryTypeConfig(
  workspace: comicsWorkspaceConfig,
  singularLabel: 'Comic',
  pluralLabel: 'Comics',
  defaultMetadataProvider: 'gcd',
  metadataProviders: [
    gcdMetadataProvider,
    comicVineMetadataProvider,
    mangadexMetadataProvider,
    anilistMetadataProvider,
    hardcoverMetadataProvider,
  ],
  addDialogLauncher: showComicLibraryAddDialog,
  trackingProfile: comicTrackingProfile,
  editDialogBuilder: buildComicLibraryEditDialog,
  inspectorHeroBuilder: buildComicInspectorHero,
  inspectorSectionsBuilder: buildComicInspectorSections,
  showsDefaultInspectorPersonalSection: false,
  presentation: comicsLibraryMediaPresentation,
  editPresentation: comicsLibraryEditPresentation,
  editChrome: LibraryEditChromeConfig(
    titleUsesItemTitle: true,
    synopsisLabel: 'Plot',
    showsIssueBadge: true,
    showsPhysicalFormatBadge: true,
  ),
  mediaFields: MediaEditFields.print(
    numberLabel: 'No. / Vol.',
    publisherLabel: 'Publisher / Studio / Creator',
    releaseDateLabel: 'Cover date',
  ),
  collectionExportTitleLabel: 'Series',
  mediaReleaseScopeLabel: 'Series',
  manualAddUsesTitleAsSeries: true,
  editUsesTitleAsSeries: true,
  transferableFieldKeys: [
    ...kDefaultTransferableFieldKeys,
    ...kComicTransferableFieldKeys,
  ],
  releaseFields: ReleaseEditFields(
    variantLabel: 'Edition / Variant / Format',
    barcodeLabel: 'Barcode / UPC / ISBN',
    variantSeedsPhysicalFormatLabel: true,
  ),
  capabilities: LibraryTypeCapabilities(
    showsSynopsis: true,
    canScanCover: true,
    supportsMediaReleaseSplit: true,
    supportsIndexReassignment: true,
    supportsMetadataCompare: true,
    groupModeCategoriesBuilder: buildComicGroupModeCategories,
  ),
  workspaceBehavior: LibraryKindWorkspaceBehavior(
    supportsSeriesIssueJump: true,
    issueSortNumber: comicIssueSortNumber,
  ),
  conditions: kComicConditions,
  grades: kComicGrades,
  defaultCondition: 'Near Mint',
  defaultGrade: 'Ungraded',
);

List<LibraryGroupModeCategory> buildComicGroupModeCategories(
  List<LibraryGroupMode> modes,
) {
  const mainModes = {
    LibraryGroupMode.series,
    LibraryGroupMode.ageRating,
    LibraryGroupMode.country,
    LibraryGroupMode.crossover,
    LibraryGroupMode.genre,
    LibraryGroupMode.imprint,
    LibraryGroupMode.language,
    LibraryGroupMode.publisher,
    LibraryGroupMode.releaseDate,
    LibraryGroupMode.releaseMonth,
    LibraryGroupMode.releaseYear,
    LibraryGroupMode.seriesGroup,
    LibraryGroupMode.storyArc,
  };
  const valueModes = {
    LibraryGroupMode.grade,
    LibraryGroupMode.condition,
    LibraryGroupMode.isKeyComic,
    LibraryGroupMode.rawOrSlabbed,
    LibraryGroupMode.myRating,
    LibraryGroupMode.purchaseDate,
    LibraryGroupMode.purchaseMonth,
    LibraryGroupMode.purchaseYear,
    LibraryGroupMode.purchaseStore,
    LibraryGroupMode.owner,
  };
  const editionModes = {
    LibraryGroupMode.coverDate,
    LibraryGroupMode.coverMonth,
    LibraryGroupMode.coverYear,
    LibraryGroupMode.format,
  };
  const creatorsAndCharactersModes = {
    LibraryGroupMode.creator,
    LibraryGroupMode.artist,
    LibraryGroupMode.character,
    LibraryGroupMode.colorist,
    LibraryGroupMode.coverArtist,
    LibraryGroupMode.coverColorist,
    LibraryGroupMode.coverInker,
    LibraryGroupMode.coverPainter,
    LibraryGroupMode.coverPenciller,
    LibraryGroupMode.coverSeparator,
    LibraryGroupMode.editor,
    LibraryGroupMode.editorInChief,
    LibraryGroupMode.inker,
    LibraryGroupMode.layouts,
    LibraryGroupMode.letterer,
    LibraryGroupMode.painter,
    LibraryGroupMode.penciller,
    LibraryGroupMode.plotter,
    LibraryGroupMode.scripter,
    LibraryGroupMode.separator,
    LibraryGroupMode.translator,
    LibraryGroupMode.writer,
  };
  final main = modes.where(mainModes.contains).toList();
  final value = modes.where(valueModes.contains).toList();
  final edition = modes.where(editionModes.contains).toList();
  final creatorsAndCharacters =
      modes.where(creatorsAndCharactersModes.contains).toList();
  final personal = modes
      .where((mode) =>
          !mainModes.contains(mode) &&
          !valueModes.contains(mode) &&
          !editionModes.contains(mode) &&
          !creatorsAndCharactersModes.contains(mode))
      .toList();
  return [
    if (main.isNotEmpty) LibraryGroupModeCategory('Main', main),
    if (value.isNotEmpty) LibraryGroupModeCategory('Value', value),
    if (edition.isNotEmpty) LibraryGroupModeCategory('Edition', edition),
    if (creatorsAndCharacters.isNotEmpty)
      LibraryGroupModeCategory('Creators & Characters', creatorsAndCharacters),
    if (personal.isNotEmpty) LibraryGroupModeCategory('Personal', personal),
  ];
}

int? comicIssueSortNumber(String? raw) {
  if (raw == null) {
    return null;
  }
  return int.tryParse(raw.trim());
}
