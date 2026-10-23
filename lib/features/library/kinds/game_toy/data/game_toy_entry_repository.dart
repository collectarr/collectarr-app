import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/entries/typed_library_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/domain/game_toy_library_entry.dart';

/// Kind projection of the complete, independently editable local entry.
final class GameToyEntryRepository
    extends TypedLibraryEntryRepository<GameToyLibraryEntry> {
  const GameToyEntryRepository(super.database);
  @override
  CatalogMediaKind get kind => CatalogMediaKind.gameToy;
  @override
  GameToyLibraryEntry decode(Map<String, dynamic> json) =>
      GameToyLibraryEntry.fromJson(json);
  @override
  Map<String, dynamic> encode(GameToyLibraryEntry item) => item.toJson();
  @override
  GameToyLibraryEntry deleted(GameToyLibraryEntry item, DateTime at) =>
      item.copyWith(deletedAt: at, updatedAt: at);
}
