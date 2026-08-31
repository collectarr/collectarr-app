import 'package:flutter/foundation.dart';

@immutable
final class VocabularyId<T> {
  const VocabularyId(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VocabularyId &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'VocabularyId<$T>($value)';
}
