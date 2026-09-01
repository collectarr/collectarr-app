import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/kinds/anime/add/anime_add_manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/anime/add/anime_add_manual_draft.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/anime/add/anime_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/anime/config.dart';
import 'package:collectarr_app/features/library/kinds/anime/vocabulary/anime_vocabularies.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/anime/provider/anime_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_card_presentation.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_fields.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';

final animeKindModule = LibraryKindSpec<AnimeWorkspaceDto, AnimeOwnedDetails>(
  type: animeLibraryConfig,
  projector: const AnimeWorkspaceProjector(),
  ownedDetailsCodec: const AnimeOwnedDetailsCodec(),
  fields: animeLibraryKindSchema.toRegistry(),
  catalogCodec: const DefaultCatalogKindCodec<AnimeMetadata>(
    AnimeMetadata.fromJson,
    _encodeAnimeMetadata,
  ),
  identity: const LibraryKindIdentity(
    kind: CatalogMediaKind.anime,
    singularLabel: 'Anime',
    pluralLabel: 'Anime',
    title: 'Anime',
    icon: Icons.movie_filter_outlined,
    accent: Color(0xFFC94DFF),
    preferencePrefix: 'anime',
  ),
  metadata: const LibraryMetadataCapability(
    defaultProviderId: 'anilist',
    providers: [anilistMetadataProvider],
  ),
  hierarchy: const LibraryHierarchyCapability(
    contentHierarchy: LibraryContentHierarchy.seasons,
    childrenTitleBuilder: _animeChildrenTitle,
    supportsMediaReleaseSplit: true,
    collectionExportTitleLabel: 'Title',
    mediaReleaseScopeLabel: 'Media',
  ),
  inspector: const LibraryInspectorCapability(
    showsDefaultPersonalSection: false,
  ),
  transfer: LibraryTransferCapability(
    kindFields: animeTransferableFields,
  ),
  add: const StandardLibraryAddCapability<AnimeAddDraft>(
    kind: CatalogMediaKind.anime,
    initialDraftBuilder: AnimeAddDraft.new,
    manualDraftBuilder: AnimeAddManualDraft.new,
    advancedFilterFieldsBuilder: buildAnimeAddAdvancedFilterFields,
    manualPaneBuilder: buildAnimeAddManualPane,
  ),
  edit: LibraryEditCapability(
    editDialogBuilder: buildAnimeLibraryEditDialog,
    vocabularies: StandardKindVocabularyCapability(AnimeVocabularies.all),
    mediaFields: const MediaEditFields(
      numberLabel: 'Edition no.',
      publisherLabel: 'Studio',
      releaseDateLabel: 'First aired',
    ),
    releaseFields: const ReleaseEditFields(
      variantLabel: 'Format / Edition',
      barcodeLabel: 'UPC / Barcode',
    ),
    createDraft: createAnimeEditDraft,
  ),
  providerMapper: const AnimeLibraryKindProviderMapper(),
  facets: const LibraryFacetModule(
    loadRows: LibraryPageUtilities.libraryFacetRowsForId,
  ),
  buildCardPresentation: buildAnimeCardPresentation,
);

String _animeChildrenTitle(int count) => 'Seasons ($count)';

Map<String, dynamic> _encodeAnimeMetadata(AnimeMetadata m) => m.toJson();

List<LibraryAddAdvancedFilterField> buildAnimeAddAdvancedFilterFields(
  LibraryAddModeBarRequest req,
) =>
    [
      if (req.seriesController != null)
        LibraryAddAdvancedFilterField(
          key: const ValueKey('library-add-series-field'),
          label: 'Series',
          controller: req.seriesController!,
        ),
      if (req.publisherController != null)
        LibraryAddAdvancedFilterField(
          key: const ValueKey('library-add-publisher-field'),
          label: 'Studio',
          controller: req.publisherController!,
        ),
      if (req.yearController != null)
        LibraryAddAdvancedFilterField(
          key: const ValueKey('library-add-year-field'),
          label: 'Year',
          controller: req.yearController!,
          width: 120,
        ),
    ];
