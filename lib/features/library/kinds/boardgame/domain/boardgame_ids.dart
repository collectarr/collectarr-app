import 'package:collectarr_app/features/library/domain/library_entity_id.dart';
import 'package:flutter/foundation.dart';

@immutable
final class BoardGameMediaId extends LibraryEntityId {
  const BoardGameMediaId(super.value);
}

@immutable
final class BoardGameEditionId extends LibraryEntityId {
  const BoardGameEditionId(super.value);
}

@immutable
final class BoardGameOwnedItemId extends LibraryEntityId {
  const BoardGameOwnedItemId(super.value);
}
