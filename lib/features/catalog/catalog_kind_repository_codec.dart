import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_summary_reader.dart';

/// Persistence adapter for one catalog kind.
///
/// The catalog feature only aggregates the structural [CatalogItemDto]
/// projection. Each adapter owns the mapping to and from its typed domain
/// repository.
abstract interface class CatalogKindRepositoryCodec
    implements CatalogKindSummaryReader {
  /// Counts a vocabulary value in this kind's catalog projection.
  ///
  /// The pick-list host owns normalization and aggregation mechanics. The
  /// codec owns which serialized fields belong to the kind and how those
  /// fields are read at the catalog persistence boundary.
  Future<int> countCatalogValue(
    LocalDatabase db,
    String semanticName,
    String normalizedValue,
  );

  /// Returns the replacement value represented by this kind's catalog item.
  ///
  /// A kind may return null when its catalog has no replacement-value
  /// semantics. The generic host only aggregates the returned number.
  int? replacementValueCents(CatalogItemDto item);

  /// Decodes the API-bound catalog projection into this kind's concrete
  /// metadata value for derived-data contributors.
  Object? typedMetadataFromDto(CatalogItemDto item);

  /// Rehydrates a transport catalog projection into this kind's typed
  /// metadata at the persistence boundary.
  CatalogItemDto withTypedMetadata(CatalogItemDto item);

  Future<void> upsert(LocalDatabase db, CatalogItemDto item);

  Future<List<CatalogItemDto>> list(LocalDatabase db);
}
