import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/entries/typed_library_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_library_entry.dart';

/// Kind projection of the complete, independently editable local entry.
final class MusicEntryRepository
    extends TypedLibraryEntryRepository<MusicLibraryEntry> {
  const MusicEntryRepository(super.database);
  @override
  CatalogMediaKind get kind => CatalogMediaKind.music;
  @override
  MusicLibraryEntry decode(Map<String, dynamic> json) =>
      MusicLibraryEntry.fromJson(json);
  @override
  Map<String, dynamic> encode(MusicLibraryEntry item) => item.toJson();
  @override
  MusicLibraryEntry deleted(MusicLibraryEntry item, DateTime at) =>
      item.copyWith(deletedAt: at, updatedAt: at);
}
