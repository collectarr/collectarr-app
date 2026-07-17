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
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_fields.dart';

const comicsWorkspaceConfig = LibraryWorkspaceConfig(
  kind: CatalogMediaKind.comic,
  title: 'Comics',
  icon: Icons.collections_bookmark_outlined,
  accent: Color(0xFF44BFE7),
  preferencePrefix: 'comics',
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
  presentation: comicLibraryMediaPresentation,
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
    contentHierarchy: LibraryContentHierarchy.volumes,
    supportsSeriesSubgroups: true,
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
  List<Object> modes,
) {
  String modeId(Object mode) {
    final normalized = mode.toString().contains('.')
        ? mode.toString().split('.').last
        : mode.toString();
    return normalized
        .replaceAllMapped(
          RegExp(r'([a-z0-9])([A-Z])'),
          (match) => '${match[1]}_${match[2]}',
        )
        .toLowerCase();
  }

  const mainIds = {
    'series',
    'age_rating',
    'country',
    'crossover',
    'genre',
    'imprint',
    'language',
    'publisher',
    'release_date',
    'release_month',
    'release_year',
    'series_group',
    'story_arc',
  };
  const valueIds = {
    'grade',
    'condition',
    'is_key_comic',
    'raw_or_slabbed',
    'my_rating',
    'purchase_date',
    'purchase_month',
    'purchase_year',
    'purchase_store',
    'owner',
  };
  const editionIds = {
    'cover_date',
    'cover_month',
    'cover_year',
    'format',
  };
  const creatorsAndCharactersIds = {
    'creator',
    'artist',
    'character',
    'colorist',
    'cover_artist',
    'cover_colorist',
    'cover_inker',
    'cover_painter',
    'cover_penciller',
    'cover_separator',
    'editor',
    'editor_in_chief',
    'inker',
    'layouts',
    'letterer',
    'painter',
    'penciller',
    'plotter',
    'scripter',
    'separator',
    'translator',
    'writer',
  };
  final main = modes.where((m) => mainIds.contains(modeId(m))).toList();
  final value = modes.where((m) => valueIds.contains(modeId(m))).toList();
  final edition = modes.where((m) => editionIds.contains(modeId(m))).toList();
  final creatorsAndCharacters =
      modes.where((m) => creatorsAndCharactersIds.contains(modeId(m))).toList();
  final personal = modes
      .where((m) =>
          !mainIds.contains(modeId(m)) &&
          !valueIds.contains(modeId(m)) &&
          !editionIds.contains(modeId(m)) &&
          !creatorsAndCharactersIds.contains(modeId(m)))
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
