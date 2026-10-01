import 'package:collectarr_app/features/library/domain/library_entity_id.dart';
import 'package:flutter/foundation.dart';

@immutable
final class ComicCatalogItemId extends LibraryEntityId {
  const ComicCatalogItemId(super.value);
}

@immutable
final class ComicOwnedCopyId extends LibraryEntityId {
  const ComicOwnedCopyId(super.value);
}
