import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/library/entries/typed_library_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_library_entry.dart';

/// Kind projection of the complete, independently editable local entry.
final class BoardGameEntryRepository
    extends TypedLibraryEntryRepository<BoardGameLibraryEntry> {
  const BoardGameEntryRepository(super.database);
  @override
  CatalogMediaKind get kind => CatalogMediaKind.boardgame;
  @override
  BoardGameLibraryEntry decode(Map<String, dynamic> json) =>
      BoardGameLibraryEntry.fromJson(json);
  @override
  Map<String, dynamic> encode(BoardGameLibraryEntry item) => item.toJson();
  @override
  BoardGameLibraryEntry deleted(BoardGameLibraryEntry item, DateTime at) =>
      item.copyWith(deletedAt: at, updatedAt: at);
}
