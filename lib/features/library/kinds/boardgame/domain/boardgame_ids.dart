import 'package:flutter/foundation.dart';

@immutable
final class BoardGameMediaId {
  const BoardGameMediaId(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      other is BoardGameMediaId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

@immutable
final class BoardGameEditionId {
  const BoardGameEditionId(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      other is BoardGameEditionId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

typedef BoardGameReleaseId = BoardGameEditionId;

@immutable
final class BoardGameOwnedItemId {
  const BoardGameOwnedItemId(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      other is BoardGameOwnedItemId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
