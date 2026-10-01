import 'package:collectarr_app/features/library/domain/library_entity_id.dart';
import 'package:flutter/foundation.dart';

@immutable
final class BoardGameCatalogItemId extends LibraryEntityId {
  const BoardGameCatalogItemId(super.value);
}

@immutable
final class BoardGameOwnedCopyId extends LibraryEntityId {
  const BoardGameOwnedCopyId(super.value);
}
