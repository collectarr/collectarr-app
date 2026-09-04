import 'package:flutter/foundation.dart';

@immutable
final class GameMediaId {
  const GameMediaId(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      other is GameMediaId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

@immutable
final class GameReleaseId {
  const GameReleaseId(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      other is GameReleaseId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

typedef GameEditionId = GameReleaseId;
