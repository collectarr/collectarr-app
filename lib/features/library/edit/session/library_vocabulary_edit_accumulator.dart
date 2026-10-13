import 'package:collectarr_app/features/library/edit/contracts/library_vocabulary_edit_change.dart';

typedef LibraryPendingVocabularyValue = ({
  String listName,
  String value,
  String? mediaKind,
});

/// Collects proposed vocabulary values by field for one edit session.
///
/// Replacing a field's selection drops its previous pending values, while
/// case-insensitive keys prevent duplicate options from being added.
final class LibraryVocabularyEditAccumulator {
  final Map<String, Map<String, LibraryPendingVocabularyValue>> _byField = {};

  bool get isEmpty => _byField.isEmpty;

  Iterable<LibraryPendingVocabularyValue> get values sync* {
    for (final fieldValues in _byField.values) {
      yield* fieldValues.values;
    }
  }

  void replaceValue({
    required String fieldId,
    required String? listName,
    required String? value,
    String? mediaKind,
  }) {
    replaceValues(
      fieldId: fieldId,
      listName: listName,
      values: value == null ? const [] : [value],
      mediaKind: mediaKind,
    );
  }

  void replaceValues({
    required String fieldId,
    required String? listName,
    required Iterable<String> values,
    String? mediaKind,
  }) {
    _byField.remove(fieldId);
    if (listName == null) return;

    final next = <String, LibraryPendingVocabularyValue>{};
    for (final value in values) {
      final normalized = value.trim();
      if (normalized.isEmpty) continue;
      next[normalized.toLowerCase()] = (
        listName: listName,
        value: normalized,
        mediaKind: mediaKind,
      );
    }
    if (next.isNotEmpty) _byField[fieldId] = next;
  }

  void removeField(String fieldId) => _byField.remove(fieldId);

  void mergeFrom(LibraryVocabularyEditAccumulator other) {
    for (final entry in other._byField.entries) {
      final fieldValues = entry.value.values.iterator;
      if (!fieldValues.moveNext()) continue;
      final first = fieldValues.current;
      replaceValues(
        fieldId: entry.key,
        listName: first.listName,
        values: entry.value.values.map((value) => value.value),
        mediaKind: first.mediaKind,
      );
    }
  }

  LibraryVocabularyEditChange toEditChange({String? defaultMediaKind}) =>
      LibraryVocabularyEditChange([
        for (final pending in values)
          (
            listName: pending.listName,
            value: pending.value,
            mediaKind: pending.mediaKind ?? defaultMediaKind,
          ),
      ]);

  void clear() => _byField.clear();
}
