import 'package:flutter/foundation.dart';

@immutable
final class MangaOwnedItemId {
  const MangaOwnedItemId(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      other is MangaOwnedItemId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
