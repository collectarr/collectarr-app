import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/game/data/legacy/game_owned_item_legacy_adapter.dart';
import 'package:collectarr_app/features/library/kinds/registry/legacy_owned_item_writer.dart';

/// Game-owned compatibility writer. Game owns the legacy-to-typed mapping.
final class GameLegacyOwnedItemWriter implements LegacyOwnedItemWriter {
  GameLegacyOwnedItemWriter(LocalDatabase database)
      : _repository = GameOwnedRepository(database);

  final GameOwnedRepository _repository;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.game;

  @override
  Future<void> upsert(OwnedItem item) {
    return _repository.upsert(GameOwnedItemLegacyAdapter.fromLegacy(item));
  }
}
