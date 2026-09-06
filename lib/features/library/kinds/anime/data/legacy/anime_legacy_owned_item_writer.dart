import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/legacy/anime_owned_item_legacy_adapter.dart';
import 'package:collectarr_app/features/library/kinds/registry/legacy_owned_item_writer.dart';

/// Anime-owned compatibility writer. Anime owns the legacy-to-typed mapping.
final class AnimeLegacyOwnedItemWriter implements LegacyOwnedItemWriter {
  AnimeLegacyOwnedItemWriter(LocalDatabase database)
      : _repository = AnimeOwnedRepository(database);

  final AnimeOwnedRepository _repository;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.anime;

  @override
  Future<void> upsert(OwnedItem item) {
    return _repository.upsert(AnimeOwnedItemLegacyAdapter.fromLegacy(item));
  }
}
