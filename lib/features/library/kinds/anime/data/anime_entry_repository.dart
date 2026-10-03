import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/entries/typed_library_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_library_entry.dart';

/// Kind projection of the complete, independently editable local entry.
final class AnimeEntryRepository extends TypedLibraryEntryRepository<AnimeLibraryEntry> {
  const AnimeEntryRepository(super.database);
  @override
  CatalogMediaKind get kind => CatalogMediaKind.anime;
  @override
  AnimeLibraryEntry decode(Map<String, dynamic> json) => AnimeLibraryEntry.fromJson(json);
  @override
  Map<String, dynamic> encode(AnimeLibraryEntry item) => item.toJson();
  @override
  AnimeLibraryEntry deleted(AnimeLibraryEntry item, DateTime at) => item.copyWith(deletedAt: at, updatedAt: at);
}
