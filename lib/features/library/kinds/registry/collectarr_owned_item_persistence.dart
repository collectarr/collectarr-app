import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_legacy_owned_item_writers.dart';
import 'package:collectarr_app/features/library/kinds/registry/legacy_owned_item_writer.dart';

/// Composition-root dispatch for the transitional common Owned write path.
///
/// This is intentionally only a dispatch boundary for the transitional common
/// [OwnedItem] value. Each writer delegates legacy-to-typed translation to its
/// owning kind; Collection commands retain their compatibility cache for now,
/// but every mutation also reaches the owning kind's repository immediately.
final class CollectarrOwnedItemPersistence {
  CollectarrOwnedItemPersistence(LocalDatabase database)
      : _writers = {
          for (final writer in collectarrLegacyOwnedItemWriters(database))
            writer.kind: writer,
        };

  final Map<CatalogMediaKind, LegacyOwnedItemWriter> _writers;

  Future<void> upsert(OwnedItem item) async {
    final writer = _writers[item.catalogRef.mediaKind];
    if (writer == null) {
      // Older collection imports may not carry a kind. The common cache
      // remains the compatibility fallback until the item is classified.
      return;
    }
    await writer.upsert(item);
  }

  Future<void> upsertAll(Iterable<OwnedItem> items) async {
    for (final item in items) {
      await upsert(item);
    }
  }
}
