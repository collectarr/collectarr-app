import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/kinds/music/data/legacy/music_owned_item_legacy_adapter.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/legacy_owned_item_writer.dart';

/// Music-owned compatibility writer. Music owns the legacy-to-typed mapping.
final class MusicLegacyOwnedItemWriter implements LegacyOwnedItemWriter {
  MusicLegacyOwnedItemWriter(LocalDatabase database)
      : _repository = MusicOwnedRepository(database);

  final MusicOwnedRepository _repository;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.music;

  @override
  Future<void> upsert(OwnedItem item) {
    return _repository.upsert(MusicOwnedItemLegacyAdapter.fromLegacy(item));
  }
}
