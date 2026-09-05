import 'package:collectarr_app/features/collection/vocabulary/vocabulary_id.dart';
import 'package:flutter/foundation.dart';

abstract interface class VocabularyCatalogValueProjector {
  Iterable<String?> call(Object? metadata);
}

final class TypedVocabularyProjector<T>
    implements VocabularyCatalogValueProjector {
  const TypedVocabularyProjector(this._project);

  final Iterable<String?> Function(T metadata) _project;

  @override
  Iterable<String?> call(Object? metadata) {
    if (metadata is! T) {
      return const [];
    }
    return _project(metadata);
  }
}

@immutable
final class VocabularyDefinition<T> {
  const VocabularyDefinition({
    required this.id,
    this.label,
    this.builtIns = const [],
    this.allowCustomValues = true,
    this.multiValue = false,
    this.valuesFrom,
  });

  final VocabularyId<T> id;
  final String? label;
  final List<T> builtIns;
  final bool allowCustomValues;
  final bool multiValue;
  final VocabularyCatalogValueProjector? valuesFrom;

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

Iterable<String?> vocabularyValues(Iterable<Object?> values) sync* {
  for (final value in values) {
    if (value is Iterable) {
      yield* value.map((item) => item?.toString());
    } else {
      yield value?.toString();
    }
  }
}
