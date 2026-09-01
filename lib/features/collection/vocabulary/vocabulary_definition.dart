import 'package:collectarr_app/features/collection/vocabulary/vocabulary_id.dart';
import 'package:flutter/foundation.dart';

typedef VocabularyCatalogValueReader = Iterable<String?> Function(
  Map<String, dynamic> payload,
);

@immutable
final class VocabularyDefinition<T> {
  const VocabularyDefinition({
    required this.id,
    this.label,
    this.builtIns = const [],
    this.allowCustomValues = true,
    this.multiValue = false,
    this.catalogValueReader,
  });

  final VocabularyId<T> id;
  final String? label;
  final List<T> builtIns;
  final bool allowCustomValues;
  final bool multiValue;
  final VocabularyCatalogValueReader? catalogValueReader;

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

Iterable<String?> vocabularyPayloadValuesForKey(
  Map<String, dynamic> payload,
  String key,
) {
  return _vocabularyValues(payload[key]);
}

Iterable<String?> vocabularyNestedPayloadValuesForKey(
  Map<String, dynamic> payload,
  String parentKey,
  String key,
) {
  final nested = payload[parentKey];
  if (nested is! Map) {
    return const [];
  }
  return _vocabularyValues(nested[key]);
}

Iterable<String?> _vocabularyValues(Object? value) {
  if (value is Iterable) {
    return value.map((item) => item?.toString());
  }
  return [value?.toString()];
}
