import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/library/entries/typed_library_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_library_entry.dart';

/// Kind projection of the complete, independently editable local entry.
final class TvEntryRepository
    extends TypedLibraryEntryRepository<TvLibraryEntry> {
  const TvEntryRepository(super.database);
  @override
  CatalogMediaKind get kind => CatalogMediaKind.tv;
  @override
  TvLibraryEntry decode(Map<String, dynamic> json) =>
      TvLibraryEntry.fromJson(json);
  @override
  Map<String, dynamic> encode(TvLibraryEntry item) => item.toJson();
  @override
  TvLibraryEntry deleted(TvLibraryEntry item, DateTime at) =>
      item.copyWith(deletedAt: at, updatedAt: at);
}
