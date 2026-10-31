import 'package:flutter/foundation.dart';

/// Base behavior for strongly typed identifiers in a library kind.
@immutable
abstract base class LibraryEntityId {
  const LibraryEntityId(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      other is LibraryEntityId &&
      other.runtimeType == runtimeType &&
      other.value == value;

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @override
  String toString() => value;
}
