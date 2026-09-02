import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/kinds/book/add/book_add_manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/book/add/book_add_manual_draft.dart';
import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/book/vocabulary/book_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/book_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/book/edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/book/provider/book_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/config/library_toolbar_config.dart';

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/library_add_ranking.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/kinds/book/presentation.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_cache_workflow.dart';
import 'package:collectarr_app/features/library/kinds/book/add/book_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_fields.dart';

import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_projector.dart';
import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';
import 'package:collectarr_app/features/library/config/library_kind_browser_delegate.dart';
import 'package:collectarr_app/features/library/generic/transferable_field.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';

import 'package:collectarr_app/features/library/kinds/book/stats/book_stats_capability.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';

const _bookAuthorFilterId = LibraryAddFilterId('book.author');
const _bookIsbnFilterId = LibraryAddFilterId('book.isbn');
const _bookPublisherFilterId = LibraryAddFilterId('book.publisher');
const _bookYearFilterId = LibraryAddFilterId('book.year');

final _bookTransferableFields = <TransferableField>[
  TransferableField(
    key: 'signedBy',
    label: 'Signed by',
    icon: Icons.draw_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.bookDetails?.signedBy,
    write: (item, value) {
      final details = item.bookDetails ?? const BookOwnedDetails();
      return item.copyWith(details: details.copyWith(signedBy: value));
    },
  ),
  TransferableField(
    key: 'dustJacketPresent',
    label: 'Dust jacket',
    icon: Icons.book_outlined,
    type: TransferableFieldType.boolean,
    scope: LibraryEditScope.release,
    read: (item) =>
        (item.bookDetails?.dustJacketPresent == true) ? 'true' : null,
    write: (item, value) {
      final details = item.bookDetails ?? const BookOwnedDetails();
      return item.copyWith(
        details: details.copyWith(dustJacketPresent: value == 'true'),
      );
    },
  ),
  TransferableField(
    key: 'dustJacketCondition',
    label: 'Dust jacket condition',
    icon: Icons.grade_outlined,
    type: TransferableFieldType.text,
    scope: LibraryEditScope.release,
    read: (item) => item.bookDetails?.dustJacketCondition,
    write: (item, value) {
      final details = item.bookDetails ?? const BookOwnedDetails();
      return item.copyWith(
        details: details.copyWith(dustJacketCondition: value),
      );
    },
  ),
];

final Set<LibraryGroupIdRuntime> _bookMediaGroupModes = Set.unmodifiable({
  BookGroupIds.author,
  BookGroupIds.publisher,
  BookGroupIds.series,
  BookGroupIds.condition,
  BookGroupIds.location,
  BookGroupIds.rating,
});

final Set<LibraryGroupIdRuntime> _bookReleaseGroupModes = Set.unmodifiable({
  BookGroupIds.author,
  BookGroupIds.publisher,
  BookGroupIds.series,
  BookGroupIds.condition,
  BookGroupIds.location,
  BookGroupIds.rating,
});

final Set<LibrarySortIdRuntime> _bookMediaSortColumns = Set.unmodifiable({
  BookSortIds.status,
  BookSortIds.title,
  BookSortIds.author,
  BookSortIds.publisher,
  BookSortIds.releaseDate,
  BookSortIds.pageCount,
  BookSortIds.series,
  BookSortIds.rating,
  BookSortIds.pricePaid,
  BookSortIds.updatedAt,
});

final Set<LibrarySortIdRuntime> _bookReleaseSortColumns = Set.unmodifiable({
  BookSortIds.status,
  BookSortIds.title,
  BookSortIds.author,
  BookSortIds.publisher,
  BookSortIds.releaseDate,
  BookSortIds.pageCount,
  BookSortIds.series,
  BookSortIds.rating,
  BookSortIds.pricePaid,
  BookSortIds.updatedAt,
});

Iterable<String?> _bookLinkedMetadataValues(BookCatalogMetadata metadata) => [
      metadata.seriesTitle,
      metadata.series?.seriesTitle,
      metadata.itemNumber,
      metadata.publisher,
      metadata.originalPublisher,
      metadata.publishing?.originalPublisher,
      metadata.variant,
      metadata.publishing?.imprint,
      metadata.country,
      metadata.language,
      ...metadata.creators.map((credit) => credit['name']?.toString()),
      ...metadata.genres,
    ];

final bookKindModule = LibraryKindSpec<BookWorkspaceDto, BookOwnedDetails>(
  presentation: bookLibraryMediaPresentation,
  trackingProfile: readingTrackingProfile,
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
    toolbarActions: [
      ...kDefaultLibraryToolbarActions,
      LibraryToolbarActionId.readingQueue,
    ],
  ),
  metadata: const LibraryMetadataCapability(
    defaultProviderId: 'hardcover',
    providers: [
      hardcoverMetadataProvider,
      openLibraryMetadataProvider,
    ],
  ),
  hierarchy: LibraryHierarchyCapability(
    browserDelegateBuilder: buildReleaseFolderBrowserDelegate,
    fetchChildrenCallback: _fetchBookVolumes,
    supportsMediaReleaseSplit: true,
    mediaScopeGroupIds: _bookMediaGroupModes,
    releaseScopeGroupIds: _bookReleaseGroupModes,
    mediaScopeSortIds: _bookMediaSortColumns,
    releaseScopeSortIds: _bookReleaseSortColumns,
  ),
  inspector: const LibraryInspectorCapability(
    showsDefaultPersonalSection: true,
    showsCreatorSpotlight: true,
    supportsOwnedItemImages: false,
  ),
  linkedMetadata: TypedLibraryLinkedMetadataCapability<BookCatalogMetadata>(
    _bookLinkedMetadataValues,
  ),
  transfer: LibraryTransferCapability(
    kindFields: _bookTransferableFields,
  ),
  stats: const BookStatsCapability(),
  add: StandardLibraryAddCapability<BookAddDraft>(
    kind: CatalogMediaKind.book,
    initialDraftBuilder: BookAddDraft.new,
    manualDraftBuilder: BookAddManualDraft.new,
    search: LibraryAddSearchCapability(
      advancedFilterDescriptorsBuilder: buildBookAddAdvancedFilterFields,
      coreSearchInputBuilder: _buildBookCoreSearchInput,
      providerQueryBuilder: _buildBookProviderQuery,
      ranking: buildLibraryAddSearchRanking(
        fields: [
          LibraryAddSearchRankField(
            id: _bookAuthorFilterId,
            exactWeight: 110,
            containsWeight: 44,
            metadataValues: (item) {
              final metadata = item.kindMetadata;
              return metadata is BookCatalogMetadata
                  ? metadata.authors
                  : const <Object?>[];
            },
            providerValues: (candidate) => [candidate.summary],
          ),
          LibraryAddSearchRankField(
            id: _bookIsbnFilterId,
            exactWeight: 90,
            containsWeight: 30,
            metadataValues: (item) {
              final metadata = item.kindMetadata;
              return metadata is BookCatalogMetadata
                  ? [metadata.barcode, metadata.itemNumber]
                  : const <Object?>[];
            },
            providerValues: (candidate) => [candidate.providerItemId],
          ),
          LibraryAddSearchRankField(
            id: _bookPublisherFilterId,
            exactWeight: 60,
            containsWeight: 24,
            metadataValues: (item) {
              final metadata = item.kindMetadata;
              return metadata is BookCatalogMetadata
                  ? [metadata.publisher, metadata.originalPublisher]
                  : const <Object?>[];
            },
            providerValues: (candidate) => [candidate.publisher],
          ),
          LibraryAddSearchRankField(
            id: _bookYearFilterId,
            exactWeight: 55,
            containsWeight: 20,
            metadataValues: (item) {
              final metadata = item.kindMetadata;
              return metadata is BookCatalogMetadata
                  ? [metadata.originalPublicationDate?.year]
                  : const <Object?>[];
            },
            providerValues: (candidate) => [candidate.series?.volumeStartYear],
          ),
        ],
      ),
    ),
    manualPaneBuilder: buildBookAddManualPane,
  ),
  edit: LibraryEditCapability(
    editDialogBuilder: buildBookLibraryEditDialog,
    vocabularies: StandardKindVocabularyCapability(BookVocabularies.all),
    presentation: const LibraryEditPresentation(
      builder: BookLibraryMediaEditPresentationBuilder(),
      mediaBuilder: BookLibraryMediaEditPresentationBuilder(),
      releaseBuilder: BookLibraryReleaseEditPresentationBuilder(),
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

List<LibraryAddAdvancedFilterField<String>> buildBookAddAdvancedFilterFields(
  LibraryAddModeBarRequest req,
) =>
    [
      LibraryAddAdvancedFilterField<String>(
        id: _bookAuthorFilterId,
        key: const ValueKey('library-add-author-field'),
        label: 'Author',
        value: req.advancedFilterText(_bookAuthorFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: _bookIsbnFilterId,
        key: const ValueKey('library-add-isbn-field'),
        label: 'ISBN',
        value: req.advancedFilterText(_bookIsbnFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: _bookPublisherFilterId,
        key: const ValueKey('library-add-publisher-field'),
        label: 'Publisher',
        value: req.advancedFilterText(_bookPublisherFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: _bookYearFilterId,
        key: const ValueKey('library-add-year-field'),
        label: 'Year',
        value: req.advancedFilterText(_bookYearFilterId),
        parse: (text) => text.trim(),
        width: 120,
      ),
    ];

LibraryMetadataSearchInput _buildBookCoreSearchInput(
  LibraryAddSearchContext context, {
  required int limit,
}) {
  final author = context.textValueFor(_bookAuthorFilterId);
  final isbn = context.textValueFor(_bookIsbnFilterId);
  return LibraryMetadataSearchInput(
    query:
        _optionalBookText(buildLibraryAddSearchQuery([context.query, author])),
    publisher: _optionalBookText(
      context.textValueFor(_bookPublisherFilterId),
    ),
    year: int.tryParse(context.textValueFor(_bookYearFilterId)),
    barcode: _optionalBookText(isbn.isNotEmpty ? isbn : context.barcode),
    limit: limit,
  );
}

String _buildBookProviderQuery(LibraryAddSearchContext context) {
  return buildLibraryAddSearchQuery([
    context.query,
    context.textValueFor(_bookAuthorFilterId),
    context.textValueFor(_bookIsbnFilterId),
    context.textValueFor(_bookPublisherFilterId),
    context.textValueFor(_bookYearFilterId),
    context.barcode,
  ]);
}

String? _optionalBookText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
