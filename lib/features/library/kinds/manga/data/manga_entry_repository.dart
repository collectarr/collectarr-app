import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/library/entries/typed_library_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_library_entry.dart';

/// Kind projection of the complete, independently editable local entry.
final class MangaEntryRepository
    extends TypedLibraryEntryRepository<MangaLibraryEntry> {
  const MangaEntryRepository(super.database);
  @override
  CatalogMediaKind get kind => CatalogMediaKind.manga;
  @override
  MangaLibraryEntry decode(Map<String, dynamic> json) =>
      MangaLibraryEntry.fromJson(json);
  @override
  Map<String, dynamic> encode(MangaLibraryEntry item) => item.toJson();
  @override
  MangaLibraryEntry deleted(MangaLibraryEntry item, DateTime at) =>
      item.copyWith(deletedAt: at, updatedAt: at);
}
