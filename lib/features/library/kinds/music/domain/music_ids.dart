import 'package:collectarr_app/features/library/domain/library_entity_id.dart';
import 'package:flutter/foundation.dart';

@immutable
final class MusicAlbumId extends LibraryEntityId {
  const MusicAlbumId(super.value);
}

/// A physical disc, tape, vinyl record, or digital medium belonging to a
/// concrete [MusicAlbum].
@immutable
final class MusicMediumId extends LibraryEntityId {
  const MusicMediumId(super.value);
}

@immutable
final class MusicTrackId extends LibraryEntityId {
  const MusicTrackId(super.value);
}

@immutable
final class MusicAlbumContributionId extends LibraryEntityId {
  const MusicAlbumContributionId(super.value);
}

@immutable
final class MusicAlbumIdentifierId extends LibraryEntityId {
  const MusicAlbumIdentifierId(super.value);
}

@immutable
final class MusicOwnedCopyId extends LibraryEntityId {
  const MusicOwnedCopyId(super.value);
}
