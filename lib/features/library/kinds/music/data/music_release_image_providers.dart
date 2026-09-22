import 'package:collectarr_app/features/library/kinds/music/data/music_release_image_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_image.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final musicReleaseImagesProvider =
    FutureProvider.family<List<MusicReleaseImage>, String>((ref, releaseId) {
  return MusicReleaseImageRepository(ref.watch(localDatabaseProvider))
      .listForRelease(releaseId);
});
