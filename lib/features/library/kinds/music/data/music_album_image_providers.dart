import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/collection/repositories/item_image_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album_image.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final musicAlbumImagesProvider =
    FutureProvider.family<List<MusicAlbumImage>, String>((ref, albumId) async {
  return loadMusicAlbumImages(ref.watch(localDatabaseProvider), albumId);
});

Future<List<MusicAlbumImage>> loadMusicAlbumImages(
  LocalDatabase database,
  String albumId,
) async {
  final storedImages =
      await ItemImageRepository(database).listForLibraryEntryRef(
    LibraryEntryRef(
      kind: CatalogMediaKind.music,
      id: LibraryEntryId(albumId),
    ),
  );
  return [
    for (final image in storedImages)
      MusicAlbumImage.fromItemImageContent(albumId: albumId, image: image),
  ];
}
