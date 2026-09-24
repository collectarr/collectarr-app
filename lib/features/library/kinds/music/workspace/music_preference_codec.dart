import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_preference_codec.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';

class MusicPreferenceCodec
    extends IdentityLibraryWorkspacePreferenceCodec<MusicKind> {
  const MusicPreferenceCodec();

  @override
  LibraryFieldId<MusicKind, Object?>? decodeColumn(
    String persisted,
    LibraryEntityScope scope,
  ) {
    final canonical = switch ((scope, persisted)) {
      (LibraryEntityScope.work, 'music.release_date') =>
        'music.release_group.release_date',
      (LibraryEntityScope.release, 'music.release_date') =>
        'music.release.release_date',
      (LibraryEntityScope.work, 'music.track_count') =>
        'music.release_group.track_count',
      (LibraryEntityScope.release, 'music.track_count') =>
        'music.release.track_count',
      _ => persisted,
    };
    return LibraryFieldId<MusicKind, Object?>(canonical);
  }

  @override
  LibrarySortId<MusicKind>? decodeSort(
    String persisted,
    LibraryEntityScope scope,
  ) {
    final canonical = switch ((scope, persisted)) {
      (LibraryEntityScope.work, 'music.release_date') =>
        'music.release_group.release_date',
      (LibraryEntityScope.release, 'music.release_date') =>
        'music.release.release_date',
      (LibraryEntityScope.work, 'music.track_count') =>
        'music.release_group.track_count',
      (LibraryEntityScope.release, 'music.track_count') =>
        'music.release.track_count',
      _ => persisted,
    };
    return LibrarySortId<MusicKind>(canonical);
  }
}
