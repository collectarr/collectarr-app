import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';

/// Persistence adapter for one catalog kind.
///
/// The catalog feature only aggregates the compatibility [CatalogItem]
/// projection. Each adapter owns the mapping to and from its typed domain
/// repository.
abstract interface class CatalogKindRepositoryCodec {
  String get kind;

  Future<void> upsert(LocalDatabase db, CatalogItem item);

  Future<List<CatalogItem>> list(LocalDatabase db);
}
