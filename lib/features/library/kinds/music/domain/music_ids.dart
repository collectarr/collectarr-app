import 'package:collectarr_app/features/library/domain/library_entity_id.dart';
import 'package:flutter/foundation.dart';

@immutable
final class MusicReleaseGroupId extends LibraryEntityId {
  const MusicReleaseGroupId(super.value);
}

@immutable
final class MusicReleaseId extends LibraryEntityId {
  const MusicReleaseId(super.value);
}

/// A physical disc, tape, vinyl record, or digital medium belonging to a
/// concrete [MusicRelease].
@immutable
final class MusicMediumId extends LibraryEntityId {
  const MusicMediumId(super.value);
}

@immutable
final class MusicTrackId extends LibraryEntityId {
  const MusicTrackId(super.value);
}

@immutable
final class MusicReleaseContributionId extends LibraryEntityId {
  const MusicReleaseContributionId(super.value);
}

@immutable
final class MusicReleaseIdentifierId extends LibraryEntityId {
  const MusicReleaseIdentifierId(super.value);
}

@immutable
final class MusicOwnedItemId extends LibraryEntityId {
  const MusicOwnedItemId(super.value);
}
