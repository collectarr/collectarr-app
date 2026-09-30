import 'package:collectarr_app/features/library/kinds/music/data/music_album_image_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album_image.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final musicAlbumImagesProvider =
    FutureProvider.family<List<MusicAlbumImage>, String>((ref, albumId) {
  return MusicAlbumImageRepository(ref.watch(localDatabaseProvider))
      .listForAlbum(albumId);
});
