import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';

/// Persistence adapter for one catalog kind.
///
/// The catalog feature only aggregates the structural [CatalogItemDto]
/// projection. Each adapter owns the mapping to and from its typed domain
/// repository.
abstract interface class CatalogKindRepositoryCodec {
  CatalogMediaKind get kind;

  /// Decodes the API-bound catalog projection into this kind's concrete
  /// metadata value for derived-data contributors.
  Object? typedMetadataFromDto(CatalogItemDto item);

  /// Rehydrates a transport catalog projection into this kind's typed
  /// metadata at the persistence boundary.
  CatalogItemDto withTypedMetadata(CatalogItemDto item);

  Future<void> upsert(LocalDatabase db, CatalogItemDto item);

  Future<List<CatalogItemDto>> list(LocalDatabase db);
}
