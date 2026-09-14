import 'package:flutter/foundation.dart';

@immutable
final class ComicMediaId {
  const ComicMediaId(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      other is ComicMediaId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

@immutable
final class ComicReleaseId {
  const ComicReleaseId(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      other is ComicReleaseId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

@immutable
final class ComicOwnedItemId {
  const ComicOwnedItemId(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      other is ComicOwnedItemId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
