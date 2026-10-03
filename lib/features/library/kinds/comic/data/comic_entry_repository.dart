import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/entries/typed_library_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_library_entry.dart';

/// Kind projection of the complete, independently editable local entry.
final class ComicEntryRepository extends TypedLibraryEntryRepository<ComicLibraryEntry> {
  const ComicEntryRepository(super.database);
  @override
  CatalogMediaKind get kind => CatalogMediaKind.comic;
  @override
  ComicLibraryEntry decode(Map<String, dynamic> json) => ComicLibraryEntry.fromJson(json);
  @override
  Map<String, dynamic> encode(ComicLibraryEntry item) => item.toJson();
  @override
  ComicLibraryEntry deleted(ComicLibraryEntry item, DateTime at) => item.copyWith(deletedAt: at, updatedAt: at);
}
