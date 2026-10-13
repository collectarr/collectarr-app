import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_personal_data.dart';

MusicAlbum musicAlbumFixture({
  String title = 'Test Album',
  List<MusicDisc> discs = const [],
}) =>
    MusicAlbum(title: title, discs: discs);

MusicLibraryEntry musicLibraryEntryFixture({
  String id = 'music-entry-1',
  MusicAlbum? metadata,
  CatalogItemRef? sourceCatalogRef,
  MusicPersonalData personal = const MusicPersonalData(),
  DateTime? updatedAt,
}) =>
    MusicLibraryEntry(
      id: LibraryEntryId(id),
      metadata: metadata ?? musicAlbumFixture(),
      sourceCatalogRef: sourceCatalogRef,
      personal: personal,
      updatedAt: updatedAt ?? DateTime.utc(2026, 1, 1),
    );
