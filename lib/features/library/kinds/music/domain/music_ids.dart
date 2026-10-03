import 'package:collectarr_app/features/library/domain/library_entity_id.dart';
import 'package:flutter/foundation.dart';

@immutable
final class MusicAlbumId extends LibraryEntityId {
  const MusicAlbumId(super.value);
}

/// A disc contained by a concrete [MusicAlbum].
@immutable
final class MusicDiscId extends LibraryEntityId {
  const MusicDiscId(super.value);
}

@immutable
final class MusicTrackId extends LibraryEntityId {
  const MusicTrackId(super.value);
}

@immutable
final class MusicAlbumContributionId extends LibraryEntityId {
  const MusicAlbumContributionId(super.value);
}
