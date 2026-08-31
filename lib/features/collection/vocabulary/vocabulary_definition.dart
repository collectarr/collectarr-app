import 'package:collectarr_app/features/collection/vocabulary/vocabulary_id.dart';
import 'package:flutter/foundation.dart';

@immutable
final class VocabularyDefinition<T> {
  const VocabularyDefinition({
    required this.id,
    this.label,
    this.builtIns = const [],
    this.allowCustomValues = true,
    this.multiValue = false,
  });

  final VocabularyId<T> id;
  final String? label;
  final List<T> builtIns;
  final bool allowCustomValues;
  final bool multiValue;

  String get key => id.value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VocabularyDefinition &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'VocabularyDefinition(${id.value})';
}
