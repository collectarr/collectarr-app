import 'package:collectarr_app/features/library/domain/library_entity_id.dart';
import 'package:flutter/foundation.dart';

@immutable
final class ComicMediaId extends LibraryEntityId {
  const ComicMediaId(super.value);
}

@immutable
final class ComicReleaseId extends LibraryEntityId {
  const ComicReleaseId(super.value);
}

@immutable
final class ComicOwnedCopyId extends LibraryEntityId {
  const ComicOwnedCopyId(super.value);
}
