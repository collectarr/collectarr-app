import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/book/book_physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/book/add/book_add_manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/book/add/book_add_manual_draft.dart';
import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details_codec.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_copy_semantics.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/kinds/book/vocabulary/book_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/book_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/media/book_media_edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/release/book_release_edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/book/edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_source.dart';
import 'package:collectarr_app/features/library/config/library_page_utilities.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/config/library_facet_module.dart';
import 'package:collectarr_app/features/library/config/library_toolbar_config.dart';

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/library_add_ranking.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/kinds/book/presentation.dart';
import 'package:collectarr_app/features/library/kinds/book/tracking/book_tracking_profile.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/core/api/dto/metadata_search_query.dart';
import 'package:collectarr_app/features/library/kinds/book/add/book_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_fields.dart';

import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_workspace.dart';
import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';
import 'package:collectarr_app/features/library/config/library_kind_browser_delegate.dart';
import 'package:collectarr_app/features/library/generic/transferable_field.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';

import 'package:collectarr_app/features/library/kinds/book/stats/book_stats_capability.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_hierarchy_mapper.dart';
import 'package:collectarr_app/features/library/kinds/book/data/remote/book_core_mapper.dart';

const _bookAuthorFilterId = LibraryAddFilterId('book.author');
const _bookIsbnFilterId = LibraryAddFilterId('book.isbn');
const _bookPublisherFilterId = LibraryAddFilterId('book.publisher');
const _bookYearFilterId = LibraryAddFilterId('book.year');

TransferableField _bookTransferField({
  required String key,
  required String label,
  required IconData icon,
  required TransferableFieldType type,
  required String? Function(BookOwnedItem item) read,
  required BookOwnedItem Function(BookOwnedItem item, String? value) write,
  LibraryEditScope scope = LibraryEditScope.all,
}) {
  return TransferableField.typed<BookOwnedItem>(
    key: key,
    label: label,
    icon: icon,
    type: type,
    scope: scope,
    decode: (value) => value as BookOwnedItem,
    read: read,
    write: write,
  );
}

final _bookUniversalTransferableFields =
    TransferableField.universalForTyped<BookOwnedItem>(
  decode: (value) => value as BookOwnedItem,
  readCondition: (item) => item.condition,
  writeCondition: (item, value) => item.copyWith(condition: value),
  readPersonalNotes: (item) => item.personalNotes,
  writePersonalNotes: (item, value) => item.copyWith(personalNotes: value),
  readLocationId: (item) => item.locationId,
  writeLocationId: (item, value) => item.copyWith(locationId: value),
  readTags: (item) => item.tags,
  writeTags: (item, value) => item.copyWith(tags: value),
  readCurrency: (item) => item.currency,
  writeCurrency: (item, value) => item.copyWith(currency: value),
  readSoldTo: (item) => item.soldTo,
  writeSoldTo: (item, value) => item.copyWith(soldTo: value),
  readPurchaseStore: (item) => item.purchaseStore,
  writePurchaseStore: (item, value) => item.copyWith(purchaseStore: value),
  readPricePaidCents: (item) => item.pricePaidCents?.toString(),
  writePricePaidCents: (item, value) => item.copyWith(
    pricePaidCents: value == null ? null : int.tryParse(value),
  ),
  readSellPriceCents: (item) => item.sellPriceCents?.toString(),
  writeSellPriceCents: (item, value) => item.copyWith(
    sellPriceCents: value == null ? null : int.tryParse(value),
  ),
  readQuantity: (item) => item.quantity.toString(),
  writeQuantity: (item, value) => item.copyWith(
    quantity: value == null ? 1 : int.tryParse(value) ?? 1,
  ),
  readIndexNumber: (item) => item.indexNumber?.toString(),
  writeIndexNumber: (item, value) => item.copyWith(
    indexNumber: value == null ? null : int.tryParse(value),
  ),
  readPurchaseDate: (item) => item.purchaseDate?.toIso8601String(),
  writePurchaseDate: (item, value) => item.copyWith(
    purchaseDate: value == null ? null : DateTime.tryParse(value),
  ),
  readSoldAt: (item) => item.soldAt?.toIso8601String(),
  writeSoldAt: (item, value) => item.copyWith(
    soldAt: value == null ? null : DateTime.tryParse(value),
  ),
);

final _bookTransferableFields = <TransferableField>[
  _bookTransferField(
    key: 'grade',
    label: 'Grade',
    icon: Icons.workspace_premium_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.grade,
    write: (item, value) => item.copyWith(grade: value),
  ),
  _bookTransferField(
    key: 'signedBy',
    label: 'Signed by',
    icon: Icons.draw_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.details.signedBy,
    write: (item, value) {
      return item.copyWith(details: item.details.copyWith(signedBy: value));
    },
  ),
  _bookTransferField(
    key: 'dustJacketPresent',
    label: 'Dust jacket',
    icon: Icons.book_outlined,
    type: TransferableFieldType.boolean,
    scope: LibraryEditScope.release,
    read: (item) => item.details.dustJacketPresent ? 'true' : null,
    write: (item, value) {
      return item.copyWith(
        details: item.details.copyWith(dustJacketPresent: value == 'true'),
      );
    },
  ),
  _bookTransferField(
    key: 'dustJacketCondition',
    label: 'Dust jacket condition',
    icon: Icons.grade_outlined,
    type: TransferableFieldType.text,
    scope: LibraryEditScope.release,
    read: (item) => item.details.dustJacketCondition,
    write: (item, value) {
      return item.copyWith(
        details: item.details.copyWith(dustJacketCondition: value),
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

BookCatalogMetadata? _bookLinkedMetadata(LibraryWorkspaceSource source) {
  final metadata = source.catalogTransport?.toTransportItem().kindMetadata;
  return metadata is BookCatalogMetadata ? metadata : null;
}

MetadataSearchQuery _bookMetadataSearchQuery({
  required LibraryWorkspaceSource source,
  required String title,
}) {
  final item = source.catalogTransport;
  return MetadataSearchQuery(
    query: title,
    barcode: item?.toTransportItem().identifierCode,
    publisher: item?.toTransportItem().publisher,
    year: item?.releaseYear,
    limit: 5,
  );
}

final bookLibraryFacetModule = TypedLibraryFacetModule<BookWorkspaceDto>(
  loadRows: LibraryPageUtilities.libraryFacetRowsForId,
  getFacetValues: _getBookFacetValues,
  externalFacetBucketIdsByMode: {
    'book.genre': BookFacetIds.genre,
    'book.subject': BookFacetIds.subject,
  },
);

BookOwnedItem _bookTransferOwnedItem(Object value) {
  if (value is BookOwnedItem) return value;
  throw ArgumentError.value(value, 'updated', 'Expected BookOwnedItem');
}

final bookKindModule = LibraryKindSpec<BookWorkspaceDto>(
  presentation: bookLibraryMediaPresentation,
  physicalMediaFormats: bookPhysicalMediaFormats,
  trackingProfile: bookTrackingProfile,
  identity: const LibraryKindIdentity(
    kind: CatalogMediaKind.book,
    singularLabel: 'Book',
    pluralLabel: 'Books',
    title: 'Books',
    icon: Icons.book_outlined,
    accent: Color(0xFFC78446),
    preferencePrefix: 'books',
    routeSegments: ['books', 'book'],
    mediaFamily: 'print',
    toolbarActions: [
      ...kDefaultLibraryToolbarActions,
      LibraryToolbarActionId.readingQueue,
    ],
  ),
  metadata: const LibraryMetadataCapability(
    defaultProviderId: 'hardcover',
    searchQueryBuilder: _bookMetadataSearchQuery,
    providers: [
      hardcoverMetadataProvider,
      openLibraryMetadataProvider,
    ],
  ),
  hierarchy: LibraryHierarchyCapability(
    browserDelegateBuilder: buildReleaseFolderBrowserDelegate,
    fetchChildrenCallback: _fetchBookVolumes,
    childrenTitleBuilder: _bookChildrenTitle,
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
    _bookLinkedMetadata,
    _bookLinkedMetadataValues,
  ),
  transfer: LibraryTransferCapability(
    transferableFieldKeys: [
      ...kDefaultTransferableFieldKeys,
      for (final field in _bookTransferableFields) field.key,
    ],
    kindFields: [
      ..._bookUniversalTransferableFields,
      ..._bookTransferableFields,
    ],
  ),
  stats: const BookStatsCapability(),
  add: StandardLibraryAddCapability<BookAddDraft>(
    kind: CatalogMediaKind.book,
    initialDraftBuilder: BookAddDraft.new,
    manualDraftBuilder: BookAddManualDraft.new,
    ownedPayloadBuilder: (item, common, draft, details, {kindValue}) =>
        BookOwnedItemCreatePayload(
      catalogRef: item.catalogRef,
      details: details as BookOwnedDetailsDraft,
      condition: common.condition,
      grade: kindValue ?? draft.grade,
      purchaseDate: common.purchaseDate,
      pricePaidCents: common.pricePaidCents,
      currency: common.currency,
      personalNotes: common.personalNotes,
      quantity: common.quantity,
      tags: common.tags,
      locationId: common.locationId,
      purchaseStore: common.purchaseStore,
      collectionStatus: common.collectionStatus,
      isDigital: common.isDigital,
    ),
    digitalCopyFlagBuilder: (item) {
      final payload = item.toTransportItem().payload;
      final direct = payload['is_digital'];
      if (direct is bool) return direct;
      final format =
          (payload['physical_format'] ?? payload['physical_format_label'])
              ?.toString()
              .toLowerCase();
      if (format == 'digital' || format == 'ebook' || format == 'web') {
        return true;
      }
      final series = payload['series'];
      if (series is Map && series['is_digital'] is bool) {
        return series['is_digital'] as bool;
      }
      final publishing = payload['publishing'];
      if (publishing is Map && publishing['is_digital'] is bool) {
        return publishing['is_digital'] as bool;
      }
      return null;
    },
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
              final metadata = item.toTransportItem().kindMetadata;
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
              final metadata = item.toTransportItem().kindMetadata;
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
              final metadata = item.toTransportItem().kindMetadata;
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
              final metadata = item.toTransportItem().kindMetadata;
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
    mediaEditDialogBuilder: buildBookMediaLibraryEditDialog,
    releaseEditDialogBuilder: buildBookReleaseLibraryEditDialog,
    vocabularies: StandardKindVocabularyCapability(BookVocabularies.all),
    presentation: const LibraryEditPresentation(
      builder: BookLibraryMediaEditPresentationBuilder(),
      mediaBuilder: BookLibraryMediaEditPresentationBuilder(),
      releaseBuilder: BookLibraryReleaseEditPresentationBuilder(),
    ),
    conditions: BookVocabularies.condition.builtIns,
    ownedCollectionValueReader: (ownedItem) => ownedItem?.collectionValue,
    defaultCondition: 'Near Mint',
    defaultCollectionValue: 'Ungraded',
    createDraft: createBookEditDraft,
    ownedDigitalFlagResolver: resolveBookOwnedDigitalFlag,
    ownedFormatHintResolver: resolveBookOwnedFormatHint,
    ownedIndexUpdatePayloadBuilder: (ownedItemId, indexNumber) =>
        BookOwnedItemUpdatePayload.partial(
      indexNumber: Patch.set(indexNumber),
    ),
    ownedConditionValueUpdatePayloadBuilder:
        (ownedItemId, condition, collectionValue) =>
            BookOwnedItemUpdatePayload.partial(
      condition: Patch.set(condition),
      grade: Patch.set(collectionValue),
    ),
    ownedBulkUpdatePayloadBuilder:
        (ownedItemId, condition, collectionValue, locationId, tags) =>
            BookOwnedItemUpdatePayload.partial(
      condition:
          condition == null ? const Patch.unchanged() : Patch.set(condition),
      grade: collectionValue == null
          ? const Patch.unchanged()
          : Patch.set(collectionValue),
      locationId:
          locationId == null ? const Patch.unchanged() : Patch.set(locationId),
      tags: tags == null ? const Patch.unchanged() : Patch.set(tags),
    ),
    ownedPersonalDetailsUpdatePayloadBuilder: (
      ownedItemId,
      purchaseDate,
      pricePaidCents,
      currency,
      personalNotes,
      purchaseStore,
      locationChanged,
      locationId,
    ) =>
        BookOwnedItemUpdatePayload.partial(
      purchaseDate: Patch.set(purchaseDate),
      pricePaidCents: Patch.set(pricePaidCents),
      currency: Patch.set(currency),
      personalNotes: Patch.set(personalNotes),
      purchaseStore: Patch.set(purchaseStore),
      locationId:
          locationChanged ? Patch.set(locationId) : const Patch.unchanged(),
    ),
    ownedTransferUpdatePayloadBuilder: (ownedItemId, updated) {
      final typed = _bookTransferOwnedItem(updated);
      return BookOwnedItemUpdatePayload.partial(
        condition: Patch.set(typed.condition),
        grade: Patch.set(typed.grade),
        personalNotes: Patch.set(typed.personalNotes),
        locationId: Patch.set(typed.locationId),
        tags: Patch.set(typed.tags),
        currency: Patch.set(typed.currency),
        soldTo: Patch.set(typed.soldTo),
        purchaseStore: Patch.set(typed.purchaseStore),
        pricePaidCents: Patch.set(typed.pricePaidCents),
        sellPriceCents: Patch.set(typed.sellPriceCents),
        quantity: Patch.set(typed.quantity),
        indexNumber: Patch.set(typed.indexNumber),
        purchaseDate: Patch.set(typed.purchaseDate),
        soldAt: Patch.set(typed.soldAt),
        details: Patch.set(
          const BookOwnedDetailsCodec().draftFromDetails(
            typed.details,
          ),
        ),
      );
    },
    ownedDetailsResetPayloadBuilder: () =>
        BookOwnedItemUpdatePayload.partial(details: const Patch.clear()),
  ),
);

Future<List<LibraryHierarchyNode>> _fetchBookVolumes({
  required ApiClient api,
  required String itemId,
  String? provider,
  String? providerItemId,
}) async {
  final work =
      await api.getBookWorkDto(itemId).timeout(const Duration(seconds: 60));
  final book = BookCoreMapper.fromWorkDto(work);
  return BookHierarchyMapper.toLibraryNodes(book.editions);
}

String _bookChildrenTitle(int count) => 'Editions ($count)';

Iterable<String> _getBookFacetValues(
  BookWorkspaceDto dto,
  LibraryFacetIdRuntime facetId,
) {
  for (final definition in bookLibraryFacetDefinitions) {
    if (definition.id.sameIdentityAs(facetId)) {
      return definition.extractValues(dto);
    }
  }
  return const [];
}

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

MetadataSearchQuery _buildBookCoreSearchInput(
  LibraryAddSearchContext context, {
  required int limit,
}) {
  final author = context.textValueFor(_bookAuthorFilterId);
  final isbn = context.textValueFor(_bookIsbnFilterId);
  return MetadataSearchQuery(
    query:
        _optionalBookText(buildLibraryAddSearchQuery([context.query, author])),
    publisher: _optionalBookText(
      context.textValueFor(_bookPublisherFilterId),
    ),
    year: int.tryParse(context.textValueFor(_bookYearFilterId)),
    barcode: _optionalBookText(isbn.isNotEmpty ? isbn : context.identifierCode),
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
    context.identifierCode,
  ]);
}

String? _optionalBookText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

final bookKindWorkspace = TypedLibraryKindWorkspace<BookWorkspaceDto>(
  fields: bookLibraryKindSchema.toRegistry(),
  projector: const BookWorkspaceProjector(),
  hierarchy: bookKindModule.hierarchy,
);
