import 'package:flutter/foundation.dart';

@immutable
final class BookMediaId {
  const BookMediaId(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      other is BookMediaId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

@immutable
final class BookReleaseId {
  const BookReleaseId(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      other is BookReleaseId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

typedef BookEditionId = BookReleaseId;

@immutable
final class BookOwnedItemId {
  const BookOwnedItemId(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      other is BookOwnedItemId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
