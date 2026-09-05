import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/collection/repositories/pick_list_repository.dart';
import 'package:collectarr_app/features/library/kinds/_shared/serial/authority/serial_authority_repository.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';

final class CatalogCacheDerivedDataService {
  const CatalogCacheDerivedDataService(this._db);

  final LocalDatabase _db;

  Future<void> capture(Iterable<Object> items) async {
    final list = items.toList(growable: false);
    if (list.isEmpty) {
      return;
    }
    final byKind = <String, List<dynamic>>{};
    for (final item in list) {
      final kindMetadata = _kindMetadataFor(item);
      final kind = (item as CatalogItem).kind;
      byKind
          .putIfAbsent(
            kind,
            () => <dynamic>[],
          )
          .add(kindMetadata);
    }

    final pickLists = PickListRepository(_db);
    final serialAuthority = SerialAuthorityRepository(_db);
    await _db.transaction(() async {
      for (final entry in byKind.entries) {
        final runtime = libraryKindRuntimeForKind(
          catalogMediaKindFromApiValue(entry.key),
        );
        final definitions = runtime.edit.vocabularies?.definitions ?? const [];
        for (final definition in definitions) {
          final valuesFrom = definition.valuesFrom;
          if (valuesFrom == null) {
            continue;
          }
          final values = <String?>[];
          for (final metadata in entry.value) {
            values.addAll(valuesFrom(metadata));
          }
          await pickLists.captureValuesWithoutTransaction(
            definition.key,
            values,
            mediaKind: entry.key,
          );
        }
      }
      await serialAuthority.captureCatalogItemsWithoutTransaction(list);
    });
  }

  static dynamic _kindMetadataFor(Object item) {
    return (item as CatalogItem).kindMetadata;
  }
}
