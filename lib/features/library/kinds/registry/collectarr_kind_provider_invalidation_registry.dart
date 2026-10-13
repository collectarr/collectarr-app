import 'package:collectarr_app/features/library/kinds/music/music_module.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final List<void Function(Ref)> kindSyncProjectionInvalidators = [
  (ref) => ref.invalidate(musicListeningRepositoryProvider),
];

final List<void Function(WidgetRef)>
    kindDatabaseMaintenanceProjectionInvalidators = [
  (ref) => ref.invalidate(musicListeningEventsProvider),
  (ref) => ref.invalidate(musicAlbumImagesProvider),
];
