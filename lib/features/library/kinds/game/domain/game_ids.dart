import 'package:collectarr_app/features/library/domain/library_entity_id.dart';
import 'package:flutter/foundation.dart';

@immutable
final class GameMediaId extends LibraryEntityId {
  const GameMediaId(super.value);
}

@immutable
final class GameReleaseId extends LibraryEntityId {
  const GameReleaseId(super.value);
}

@immutable
final class GameOwnedItemId extends LibraryEntityId {
  const GameOwnedItemId(super.value);
}
