import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/legacy/comic_owned_item_legacy_adapter.dart';
import 'package:collectarr_app/features/library/kinds/registry/legacy_owned_item_writer.dart';

/// Comic-owned compatibility writer. Comic owns the legacy-to-typed mapping.
final class ComicLegacyOwnedItemWriter implements LegacyOwnedItemWriter {
  ComicLegacyOwnedItemWriter(LocalDatabase database)
      : _repository = ComicOwnedRepository(database);

  final ComicOwnedRepository _repository;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.comic;

  @override
  Future<void> upsert(OwnedItem item) {
    return _repository.upsert(ComicOwnedItemLegacyAdapter.fromLegacy(item));
  }
}
