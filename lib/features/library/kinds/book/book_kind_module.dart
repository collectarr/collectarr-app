import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/kinds/book/add/book_add_manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/book/add/book_add_manual_draft.dart';
import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/vocabulary/book_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/book/config.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/book_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/book/edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/book/provider/book_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/kinds/book/add/book_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_fields.dart';

import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_projector.dart';
import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';

import 'package:collectarr_app/features/library/kinds/book/stats/book_stats_capability.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';

final bookKindModule = LibraryKindSpec<BookWorkspaceDto, BookOwnedDetails>(
  type: booksLibraryConfig,
  projector: const BookWorkspaceProjector(),
  ownedDetailsCodec: const BookOwnedDetailsCodec(),
  fields: bookLibraryKindSchema.toRegistry(),
  catalogCodec: const DefaultCatalogKindCodec<BookCatalogMetadata>(
    BookCatalogMetadata.fromJson,
    _encodeBookMetadata,
  ),
  identity: const LibraryKindIdentity(
    kind: CatalogMediaKind.book,
    singularLabel: 'Book',
    pluralLabel: 'Books',
    title: 'Books',
    icon: Icons.book_outlined,
    accent: Color(0xFFC78446),
    preferencePrefix: 'books',
  ),
  metadata: const LibraryMetadataCapability(
    defaultProviderId: 'hardcover',
    providers: [
      hardcoverMetadataProvider,
      openLibraryMetadataProvider,
    ],
  ),
  hierarchy: const LibraryHierarchyCapability(
    contentHierarchy: LibraryContentHierarchy.volumes,
    fetchChildrenCallback: _fetchBookVolumes,
    supportsSeriesSubgroups: true,
    supportsMediaReleaseSplit: true,
    showsReadingQueue: true,
    collectionExportTitleLabel: 'Title',
    mediaReleaseScopeLabel: 'Media',
  ),
  inspector: const LibraryInspectorCapability(
    showsDefaultPersonalSection: true,
  ),
  transfer: LibraryTransferCapability(
    kindFields: bookTransferableFields,
  ),
  stats: const BookStatsCapability(),
  add: const StandardLibraryAddCapability<BookAddDraft>(
    kind: CatalogMediaKind.book,
    initialDraftBuilder: BookAddDraft.new,
    manualDraftBuilder: BookAddManualDraft.new,
    advancedFilterFieldsBuilder: buildBookAddAdvancedFilterFields,
    manualPaneBuilder: buildBookAddManualPane,
  ),
  edit: LibraryEditCapability(
    editDialogBuilder: buildBookLibraryEditDialog,
    presentation: const LibraryEditPresentation(
      builder: BookLibraryMediaEditPresentationBuilder(),
      mediaBuilder: BookLibraryMediaEditPresentationBuilder(),
      releaseBuilder: BookLibraryReleaseEditPresentationBuilder(),
    ),
    mediaFields: const MediaEditFields.print(
      numberLabel: 'Volume',
      publisherLabel: 'Publisher',
      releaseDateLabel: 'First published',
    ),
    releaseFields: const ReleaseEditFields(
      variantLabel: 'Edition / Binding',
      barcodeLabel: 'ISBN / Barcode',
    ),
    conditions: BookVocabularies.condition.builtIns,
    createDraft: createBookEditDraft,
  ),
  providerMapper: const BookLibraryKindProviderMapper(),
  facets: const LibraryFacetModule(
    loadRows: LibraryPageUtilities.libraryFacetRowsForId,
  ),
);

Future<List<LibraryHierarchyNode>> _fetchBookVolumes({
  required ApiClient api,
  required String itemId,
  String? provider,
  String? providerItemId,
}) async {
  return const [];
}

Map<String, dynamic> _encodeBookMetadata(BookCatalogMetadata m) => m.toJson();

Future<List<LibraryHierarchyNode>> _fetchBookVolumesFromApi({
  required ApiClient api,
  required String itemId,
}) async {
  final volumes = await api
      .getItemVolumes(itemId, kind: CatalogMediaKind.book.apiValue)
      .timeout(const Duration(seconds: 60));
  return [
    for (final volume in volumes)
      LibraryHierarchyNode(
        id: 'volume_${volume.seasonNumber}',
        label: volume.title,
        secondaryLabel:
            volume.episodeCount != null ? '${volume.episodeCount} items' : null,
        level: LibraryHierarchyLevel.container,
        imageUrl: volume.posterUrl,
        totalCount: volume.episodeCount,
        metadata: {
          'number': volume.seasonNumber,
          'airDate': volume.airDate,
        },
      ),
  ];
}

List<LibraryAddAdvancedFilterField> buildBookAddAdvancedFilterFields(
  LibraryAddModeBarRequest req,
) =>
    [
      if (req.seriesController != null)
        LibraryAddAdvancedFilterField(
          key: const ValueKey('library-add-series-field'),
          label: 'Author / Series',
          controller: req.seriesController!,
        ),
      if (req.publisherController != null)
        LibraryAddAdvancedFilterField(
          key: const ValueKey('library-add-publisher-field'),
          label: 'Publisher',
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
