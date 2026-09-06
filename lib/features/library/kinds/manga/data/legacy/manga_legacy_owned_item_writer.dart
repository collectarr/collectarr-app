import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/legacy/manga_owned_item_legacy_adapter.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/legacy_owned_item_writer.dart';

/// Manga-owned compatibility writer. Manga owns the legacy-to-typed mapping.
final class MangaLegacyOwnedItemWriter implements LegacyOwnedItemWriter {
  MangaLegacyOwnedItemWriter(LocalDatabase database)
      : _repository = MangaOwnedRepository(database);

  final MangaOwnedRepository _repository;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.manga;

  @override
  Future<void> upsert(OwnedItem item) {
    return _repository.upsert(MangaOwnedItemLegacyAdapter.fromLegacy(item));
  }
}
