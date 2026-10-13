import 'package:collectarr_app/features/library/domain/library_entity_id.dart';
import 'package:flutter/foundation.dart';

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
final class MusicCreditId extends LibraryEntityId {
  const MusicCreditId(super.value);
}
