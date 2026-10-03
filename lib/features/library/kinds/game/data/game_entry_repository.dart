import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/entries/typed_library_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_library_entry.dart';

/// Kind projection of the complete, independently editable local entry.
final class GameEntryRepository extends TypedLibraryEntryRepository<GameLibraryEntry> {
  const GameEntryRepository(super.database);
  @override
  CatalogMediaKind get kind => CatalogMediaKind.game;
  @override
  GameLibraryEntry decode(Map<String, dynamic> json) => GameLibraryEntry.fromJson(json);
  @override
  Map<String, dynamic> encode(GameLibraryEntry item) => item.toJson();
  @override
  GameLibraryEntry deleted(GameLibraryEntry item, DateTime at) => item.copyWith(deletedAt: at, updatedAt: at);
}
