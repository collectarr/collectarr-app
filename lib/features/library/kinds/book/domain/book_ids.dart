import 'package:collectarr_app/features/library/domain/library_entity_id.dart';
import 'package:flutter/foundation.dart';

@immutable
final class BookMediaId extends LibraryEntityId {
  const BookMediaId(super.value);
}

@immutable
final class BookReleaseId extends LibraryEntityId {
  const BookReleaseId(super.value);
}

@immutable
final class BookOwnedCopyId extends LibraryEntityId {
  const BookOwnedCopyId(super.value);
}
