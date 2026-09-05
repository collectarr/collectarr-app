import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/catalog/serial/serial_authority_repository.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_definition_contributor.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';

final class LibraryCatalogDerivedDataService {
  const LibraryCatalogDerivedDataService(
    this._db, {
    required this.contributors,
  });

  final LocalDatabase _db;
  final Iterable<PickListDefinitionContributor> contributors;

  Future<void> capture(Iterable<CatalogItem> items) async {
    final list = items.toList(growable: false);
    if (list.isEmpty) return;

    final byKind = <CatalogMediaKind, List<Object?>>{};
    for (final item in list) {
      byKind
          .putIfAbsent(item.mediaKind, () => <Object?>[])
          .add(item.kindMetadata);
    }

    final pickLists = PickListRepository(_db);
    final serialAuthority = SerialAuthorityRepository(_db);
    await _db.transaction(() async {
      for (final entry in byKind.entries) {
        for (final contributor in contributors) {
          if (contributor.kind != entry.key) continue;
          for (final projected in contributor.catalogValues(entry.value)) {
            await pickLists.captureValuesWithoutTransaction(
              projected.listName,
              projected.values,
              mediaKind: entry.key.apiValue,
            );
          }
        }
      }
      await serialAuthority.captureCatalogItemsWithoutTransaction(list);
    });
  }
}
