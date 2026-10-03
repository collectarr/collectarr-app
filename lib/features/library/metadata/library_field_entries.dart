import 'package:flutter/foundation.dart';

enum LibraryFieldEntryPolicy {
  canonicalMetadata,
  personalLibrary,
  syncablePersonal,
}

enum PersonalLibraryFieldEditor {
  partialDate,
  money,
  singleVocabulary,
  multiVocabulary,
  currency,
  rating,
  notes,
  collectionStatus,
  integer,
  location,
}

enum PersonalLibraryFieldArea {
  personalFields,
  statusStrip,
  rating,
  notes,
}

@immutable
class PersonalLibraryFieldSpec {
  const PersonalLibraryFieldSpec({
    required this.key,
    required this.label,
    required this.group,
    this.syncable = false,
    this.editor,
    this.area,
    this.editOrder,
    this.vocabularyListName,
    this.currencyFieldKey,
    this.options = const <String>[],
  });

  final String key;
  final String label;
  final String group;
  final bool syncable;
  final PersonalLibraryFieldEditor? editor;
  final PersonalLibraryFieldArea? area;
  final int? editOrder;
  final String? vocabularyListName;
  final String? currencyFieldKey;
  final List<String> options;
}
