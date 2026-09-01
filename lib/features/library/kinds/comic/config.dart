import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/kinds/comic/add_dialog.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/comic/inspector_hero.dart';
import 'package:collectarr_app/features/library/kinds/comic/inspector_sections.dart';
import 'package:collectarr_app/features/library/kinds/comic/presentation.dart';
import 'package:collectarr_app/features/library/kinds/comic/vocabulary/comic_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
import 'package:collectarr_app/features/library/generic/transferable_field.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';

const comicsWorkspaceConfig = LibraryWorkspaceConfig(
  kind: CatalogMediaKind.comic,
  title: 'Comics',
  icon: Icons.collections_bookmark_outlined,
  accent: Color(0xFF44BFE7),
  preferencePrefix: 'comics',
);

const comicTransferableFieldKeys = <String>[
  ...kDefaultTransferableFieldKeys,
  'rawOrSlabbed',
  'gradingCompany',
  'graderNotes',
  'signedBy',
  'keyReason',
  'keyComic',
];

final comicTransferableFields = <TransferableField>[
  TransferableField(
    key: 'rawOrSlabbed',
    label: 'Raw / Slabbed',
    icon: Icons.layers_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.comicDetails?.rawOrSlabbed,
    write: (item, value) {
      final c = item.comicDetails ?? const ComicOwnedDetails();
      return item.copyWith(details: c.copyWith(rawOrSlabbed: value));
    },
  ),
  TransferableField(
    key: 'gradingCompany',
    label: 'Grading company',
    icon: Icons.verified_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.comicDetails?.gradingCompany,
    write: (item, value) {
      final c = item.comicDetails ?? const ComicOwnedDetails();
      return item.copyWith(details: c.copyWith(gradingCompany: value));
    },
  ),
  TransferableField(
    key: 'graderNotes',
    label: 'Grader notes',
    icon: Icons.note_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.comicDetails?.graderNotes,
    write: (item, value) {
      final c = item.comicDetails ?? const ComicOwnedDetails();
      return item.copyWith(details: c.copyWith(graderNotes: value));
    },
  ),
  TransferableField(
    key: 'signedBy',
    label: 'Signed by',
    icon: Icons.draw_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.comicDetails?.signedBy,
    write: (item, value) {
      final c = item.comicDetails ?? const ComicOwnedDetails();
      return item.copyWith(details: c.copyWith(signedBy: value));
    },
  ),
  TransferableField(
    key: 'keyReason',
    label: 'Key reason',
    icon: Icons.vpn_key_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.comicDetails?.keyReason,
    write: (item, value) {
      final c = item.comicDetails ?? const ComicOwnedDetails();
      return item.copyWith(details: c.copyWith(keyReason: value));
    },
  ),
  TransferableField(
    key: 'keyComic',
    label: 'Key issue',
    icon: Icons.vpn_key,
    type: TransferableFieldType.boolean,
    read: (item) => (item.comicDetails?.keyComic == true) ? 'true' : null,
    write: (item, value) {
      final c = item.comicDetails ?? const ComicOwnedDetails();
      return item.copyWith(details: c.copyWith(keyComic: value == 'true'));
    },
  ),
  TransferableField(
    key: 'coverPriceCents',
    label: 'Cover price',
    icon: Icons.price_check,
    type: TransferableFieldType.integer,
    scope: LibraryEditScope.release,
    read: (item) => item.comicDetails?.coverPriceCents?.toString(),
    write: (item, value) {
      final c = item.comicDetails ?? const ComicOwnedDetails();
      return item.copyWith(
        details: c.copyWith(
          coverPriceCents: value != null ? int.tryParse(value) : null,
        ),
      );
    },
  ),
];

final comicsLibraryConfig = LibraryTypeConfig(
  workspace: comicsWorkspaceConfig,
  singularLabel: 'Comic',
  pluralLabel: 'Comics',
  defaultMetadataProvider: 'gcd',
  metadataProviders: const [
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
  addChrome: const LibraryAddChromeConfig(),
  editChrome: LibraryEditChromeConfig(
    titleUsesItemTitle: true,
    synopsisLabel: 'Plot',
    showsIssueBadge: true,
    showsPhysicalFormatBadge: true,
  ),
  capabilities: LibraryTypeCapabilities(
    showsSynopsis: true,
    canScanCover: true,
    supportsMediaReleaseSplit: true,
    supportsIndexReassignment: true,
    supportsMetadataCompare: true,
    contentHierarchy: LibraryContentHierarchy.volumes,
    vocabulary: StandardKindVocabularyCapability(ComicVocabularies.all),
    mediaScopeGroupIds: _comicMediaGroupModes,
    releaseScopeGroupIds: _comicReleaseGroupModes,
    groupModeCategoriesBuilder: buildComicGroupModeCategories,
  ),
);

List<LibraryGroupModeCategory> buildComicGroupModeCategories(
  List<String> modes,
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

const Set<String> _comicMediaGroupModes = {
  'series',
  'publisher',
  'imprint',
  'release_date',
  'release_month',
  'release_year',
  'genre',
  'story_arc',
  'character',
  'creator',
  'artist',
  'writer',
  'penciller',
  'inker',
  'cover_artist',
  'editor',
  'editor_in_chief',
  'letterer',
  'colorist',
  'translator',
  'location',
  'grade',
  'condition',
  'is_key_comic',
  'raw_or_slabbed',
  'my_rating',
};

const Set<String> _comicReleaseGroupModes = {
  'variant',
  'format',
  'edition',
  'cover_date',
  'cover_month',
  'cover_year',
};
