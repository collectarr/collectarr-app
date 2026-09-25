import 'package:collectarr_app/features/library/domain/library_entity_id.dart';
import 'package:flutter/foundation.dart';

@immutable
final class AnimeMediaId extends LibraryEntityId {
  const AnimeMediaId(super.value);
}

@immutable
final class AnimeEpisodeId extends LibraryEntityId {
  const AnimeEpisodeId(super.value);
}

@immutable
final class AnimeReleaseId extends LibraryEntityId {
  const AnimeReleaseId(super.value);
}

@immutable
final class AnimeOwnedItemId extends LibraryEntityId {
  const AnimeOwnedItemId(super.value);
}
