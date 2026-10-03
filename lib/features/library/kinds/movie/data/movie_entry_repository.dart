import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/entries/typed_library_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_library_entry.dart';

/// Kind projection of the complete, independently editable local entry.
final class MovieEntryRepository
    extends TypedLibraryEntryRepository<MovieLibraryEntry> {
  const MovieEntryRepository(super.database);
  @override
  CatalogMediaKind get kind => CatalogMediaKind.movie;
  @override
  MovieLibraryEntry decode(Map<String, dynamic> json) =>
      MovieLibraryEntry.fromJson(json);
  @override
  Map<String, dynamic> encode(MovieLibraryEntry item) => item.toJson();
  @override
  MovieLibraryEntry deleted(MovieLibraryEntry item, DateTime at) =>
      item.copyWith(deletedAt: at, updatedAt: at);
}
