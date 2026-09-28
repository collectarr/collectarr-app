import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_copy_ref.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/data/owned_copy_v1_repository.dart';
import 'package:collectarr_app/features/library/domain/owned_copy_v1.dart';
import 'package:uuid/uuid.dart';

/// Source-neutral Catalog Item Add operations shared by all library kinds.
///
/// Provider search and provider ingestion intentionally do not participate in
/// this flow. The caller selects or creates a Core Catalog Item, then creates
/// one local Owned Copy row for every requested physical or digital copy.
final class LibraryCatalogItemV1AddService {
  const LibraryCatalogItemV1AddService({
    required ApiClient api,
    required OwnedCopyV1Repository ownedCopies,
    Uuid uuid = const Uuid(),
  })  : _api = api,
        _ownedCopies = ownedCopies,
        _uuid = uuid;

  final ApiClient _api;
  final OwnedCopyV1Repository _ownedCopies;
  final Uuid _uuid;

  Future<List<CatalogItemSummaryV1Dto>> search({
    required CatalogMediaKind kind,
    String? query,
    String? identifier,
    int limit = 50,
  }) {
    if (kind.isUnknown) {
      throw ArgumentError.value(kind, 'kind', 'A known kind is required.');
    }
    if (limit < 1 || limit > 200) {
      throw ArgumentError.value(limit, 'limit', 'Must be between 1 and 200.');
    }
    if ((query == null || query.trim().isEmpty) &&
        (identifier == null || identifier.trim().isEmpty)) {
      throw ArgumentError('Catalog Item search needs text or an identifier.');
    }
    return _api.searchCatalogItems(
      kind: kind,
      query: query,
      identifier: identifier,
      limit: limit,
    );
  }

  Future<CatalogItemV1Dto> get(CatalogItemRef ref) => _api.getCatalogItem(ref);

  Future<CatalogItemV1Dto> create(CatalogItemWriteV1Dto payload) =>
      _api.createCatalogItem(payload);

  Future<CatalogItemV1Dto> update(
    CatalogItemRef item,
    CatalogItemWriteV1Dto payload,
  ) =>
      _api.updateCatalogItem(item, payload);

  Future<List<OwnedCopyV1>> addCopies({
    required CatalogItemRef item,
    required int quantity,
    required OwnedCopyStatusV1 status,
    DateTime? now,
    int? startingIndex,
    String? locationId,
    OwnedCopyOwnerV1? owner,
    bool? isDigital,
    String? condition,
    PartialDate? purchaseDate,
    Money? purchasePrice,
    String? purchaseStore,
    Money? currentValue,
    PartialDate? soldAt,
    String? soldTo,
    Money? salePrice,
    int? rating,
    String? notes,
    Iterable<String> tags = const [],
    Iterable<OwnedCopyPersonalImageV1> personalImages = const [],
    Iterable<OwnedCopyCustomFieldV1> customFields = const [],
    OwnedCopyKindDetailsV1? kindDetails,
  }) async {
    if (quantity < 1) {
      throw ArgumentError.value(quantity, 'quantity', 'Must be positive.');
    }
    if (startingIndex != null && startingIndex < 0) {
      throw ArgumentError.value(
        startingIndex,
        'startingIndex',
        'Cannot be negative.',
      );
    }

    // Ownership is App-local. A previously selected Catalog Item remains
    // addable while Core is temporarily unavailable; Core is only required
    // when searching for or creating catalog data.
    final timestamp = (now ?? DateTime.now()).toUtc();
    final resolvedKindDetails =
        kindDetails ?? OwnedCopyKindDetailsV1.fromJson(item.kind, const {});
    final resolvedTags = List<String>.unmodifiable(tags);
    final resolvedPersonalImages =
        List<OwnedCopyPersonalImageV1>.unmodifiable(personalImages);
    final resolvedCustomFields =
        List<OwnedCopyCustomFieldV1>.unmodifiable(customFields);
    final copies = <OwnedCopyV1>[
      for (var offset = 0; offset < quantity; offset++)
        OwnedCopyV1(
          ref: OwnedCopyRef(
            kind: item.kind,
            itemId: item.id,
            copyId: _uuid.v4(),
          ),
          catalogItem: item,
          status: status,
          createdAt: timestamp,
          updatedAt: timestamp,
          indexNumber: startingIndex == null ? null : startingIndex + offset,
          locationId: locationId,
          owner: owner,
          isDigital: isDigital,
          condition: condition,
          purchaseDate: purchaseDate,
          purchasePrice: purchasePrice,
          purchaseStore: purchaseStore,
          currentValue: currentValue,
          soldAt: soldAt,
          soldTo: soldTo,
          salePrice: salePrice,
          rating: rating,
          notes: notes,
          tags: resolvedTags,
          personalImages: resolvedPersonalImages,
          customFields: resolvedCustomFields,
          kindDetails: resolvedKindDetails,
        ),
    ];
    await _ownedCopies.upsertAll(copies);
    return List.unmodifiable(copies);
  }
}
