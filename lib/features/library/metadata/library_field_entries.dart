import 'package:flutter/foundation.dart';

enum LibraryFieldEntryPolicy {
  canonicalMetadata,
  personalLibrary,
  syncablePersonal,
}

enum PersonalLibraryFieldEditor {
  condition,
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
    this.minimum,
    this.defaultInteger,
    this.inputKind,
    this.area,
    this.editOrder,
    this.manualAddOrder,
    this.vocabularyListName,
    this.currencyFieldKey,
    this.options = const <String>[],
  });

  final String key;
  final String label;
  final String group;
  final bool syncable;
  final int? minimum;
  final int? defaultInteger;
  final PersonalLibraryFieldEditor? inputKind;
  final PersonalLibraryFieldArea? area;
  final int? editOrder;
  final int? manualAddOrder;
  final String? vocabularyListName;
  final String? currencyFieldKey;
  final List<String> options;
}

PersonalLibraryFieldSpec relabelPersonalLibraryField(
        PersonalLibraryFieldSpec field, String label) =>
    PersonalLibraryFieldSpec(
        key: field.key,
        label: label,
        group: field.group,
        syncable: field.syncable,
        inputKind: field.inputKind,
        area: field.area,
        editOrder: field.editOrder,
        manualAddOrder: field.manualAddOrder,
        vocabularyListName: field.vocabularyListName,
        currencyFieldKey: field.currencyFieldKey,
        options: field.options,
        minimum: field.minimum,
        defaultInteger: field.defaultInteger);
