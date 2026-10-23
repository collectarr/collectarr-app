import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_lookup.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_item_cache_repository.dart';
import '../../domain/game_toy_metadata.dart';

final class GameToyCatalogLookup implements CatalogKindLookup {
  const GameToyCatalogLookup(this.db);
  final LocalDatabase db;
  @override
  CatalogMediaKind get kind => CatalogMediaKind.gameToy;
  @override
  Future<CatalogSearchHit?> resolve(CatalogLookupQuery query) async {
    final value = normalizeCatalogLookupValue(query.value ?? '');
    final title = normalizeCatalogLookupTitle(query.title ?? '');
    for (final item
        in await CatalogItemCacheRepository(db).findAll(kind: kind)) {
      final metadata = GameToyCatalogMetadata.fromJson(item.kindData);
      if ((value.isNotEmpty &&
              normalizeCatalogLookupValue(metadata.barcode ?? '') == value) ||
          (title.isNotEmpty &&
              normalizeCatalogLookupTitle(metadata.title) == title)) {
        return catalogLookupHit(kind: kind, id: item.id, title: metadata.title);
      }
    }
    return null;
  }
}
