import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/entries/typed_library_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/domain/game_hardware_library_entry.dart';

/// Kind projection of the complete, independently editable local entry.
final class GameHardwareEntryRepository
    extends TypedLibraryEntryRepository<GameHardwareLibraryEntry> {
  const GameHardwareEntryRepository(super.database);
  @override
  CatalogMediaKind get kind => CatalogMediaKind.gameHardware;
  @override
  GameHardwareLibraryEntry decode(Map<String, dynamic> json) =>
      GameHardwareLibraryEntry.fromJson(json);
  @override
  Map<String, dynamic> encode(GameHardwareLibraryEntry item) => item.toJson();
  @override
  GameHardwareLibraryEntry deleted(
          GameHardwareLibraryEntry item, DateTime at) =>
      item.copyWith(deletedAt: at, updatedAt: at);
}
