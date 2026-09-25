import 'package:collectarr_app/features/library/domain/library_entity_id.dart';
import 'package:flutter/foundation.dart';

@immutable
final class TvSeriesId extends LibraryEntityId {
  const TvSeriesId(super.value);
}

@immutable
final class TvSeasonId extends LibraryEntityId {
  const TvSeasonId(super.value);
}

@immutable
final class TvEpisodeId extends LibraryEntityId {
  const TvEpisodeId(super.value);
}

@immutable
final class TvReleaseId extends LibraryEntityId {
  const TvReleaseId(super.value);
}

@immutable
final class TvReleaseMediaId extends LibraryEntityId {
  const TvReleaseMediaId(super.value);
}

@immutable
final class TvOwnedItemId extends LibraryEntityId {
  const TvOwnedItemId(super.value);
}

@immutable
final class TvReleaseEpisodeMapId extends LibraryEntityId {
  const TvReleaseEpisodeMapId(super.value);
}
