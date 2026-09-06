import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/legacy/boardgame_owned_item_legacy_adapter.dart';
import 'package:collectarr_app/features/library/kinds/registry/legacy_owned_item_writer.dart';

/// BoardGame-owned compatibility writer. BoardGame owns the mapping.
final class BoardGameLegacyOwnedItemWriter implements LegacyOwnedItemWriter {
  BoardGameLegacyOwnedItemWriter(LocalDatabase database)
      : _repository = BoardGameOwnedRepository(database);

  final BoardGameOwnedRepository _repository;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.boardgame;

  @override
  Future<void> upsert(OwnedItem item) {
    return _repository.upsert(BoardGameOwnedItemLegacyAdapter.fromLegacy(item));
  }
}
