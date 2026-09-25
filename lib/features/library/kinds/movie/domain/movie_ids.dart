import 'package:collectarr_app/features/library/domain/library_entity_id.dart';
import 'package:flutter/foundation.dart';

@immutable
final class MovieMediaId extends LibraryEntityId {
  const MovieMediaId(super.value);
}

@immutable
final class MovieReleaseId extends LibraryEntityId {
  const MovieReleaseId(super.value);
}

@immutable
final class MovieReleaseMediaId extends LibraryEntityId {
  const MovieReleaseMediaId(super.value);
}

@immutable
final class MovieOwnedItemId extends LibraryEntityId {
  const MovieOwnedItemId(super.value);
}
