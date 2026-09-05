import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/pick_lists/models/universal_vocabularies.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';

export 'package:collectarr_app/features/pick_lists/models/universal_vocabularies.dart';

class PickListConditionGradeOptions {
  const PickListConditionGradeOptions({
    required this.conditions,
    required this.grades,
  });

  final List<String> conditions;
  final List<String> grades;
}

Future<List<String>> loadTagPickListOptions(
  LocalDatabase db, {
  required String mediaKind,
  Iterable<String?> selectedTags = const [],
}) async {
  return loadMultiValuePickListOptions(
    db,
    listName: UniversalVocabularies.tags.key,
    mediaKind: mediaKind,
    selectedValues: selectedTags,
  );
}

Future<List<String>> loadMultiValuePickListOptions(
  LocalDatabase db, {
  required String listName,
  required String mediaKind,
  List<String> builtInValues = const [],
  Iterable<String?> selectedValues = const [],
}) async {
  final repo = PickListRepository(db);
  final values = await repo.getValues(listName, mediaKind: mediaKind);
  return mergePickListValues(
    builtInValues: builtInValues,
    customValues: values,
    selectedValues: selectedValues,
  );
}

List<String> splitPickListValues(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return const [];
  }
  return mergePickListValues(
    builtInValues: raw.split(','),
  );
}

String? joinPickListValues(Iterable<String> values) {
  final normalized = mergePickListValues(
    builtInValues: values.toList(growable: false),
  );
  if (normalized.isEmpty) {
    return null;
  }
  return normalized.join(', ');
}

Future<List<String>> loadSingleValuePickListOptions(
  LocalDatabase db, {
  required String listName,
  required String mediaKind,
  List<String> builtInValues = const [],
  String? selectedValue,
}) async {
  final repo = PickListRepository(db);
  final values = await repo.getValues(listName, mediaKind: mediaKind);
  return mergePickListValues(
    builtInValues: builtInValues,
    customValues: values,
    selectedValues: [selectedValue],
  );
}

Future<PickListConditionGradeOptions> loadConditionGradePickListOptions(
  LocalDatabase db, {
  required String mediaKind,
  required List<String> builtInConditions,
  required List<String> builtInGrades,
  String? conditionListName,
  String? gradeListName,
  String? selectedCondition,
  String? selectedGrade,
}) async {
  final repo = PickListRepository(db);
  final conditionKey = conditionListName ?? UniversalVocabularies.condition.key;
  final gradeKey = gradeListName ?? UniversalVocabularies.grade.key;
  final results = await Future.wait([
    repo.getValues(conditionKey, mediaKind: mediaKind),
    repo.getValues(gradeKey, mediaKind: mediaKind),
  ]);
  return PickListConditionGradeOptions(
    conditions: mergePickListValues(
      builtInValues: builtInConditions,
      customValues: results[0],
      selectedValues: [selectedCondition],
    ),
    grades: mergePickListValues(
      builtInValues: builtInGrades,
      customValues: results[1],
      selectedValues: [selectedGrade],
    ),
  );
}

List<String> mergePickListValues({
  required List<String> builtInValues,
  List<String> customValues = const [],
  Iterable<String?> selectedValues = const [],
}) {
  final merged = <String>[];
  final seen = <String>{};

  void addValue(String? raw) {
    final trimmed = raw?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return;
    }
    if (seen.add(trimmed.toLowerCase())) {
      merged.add(trimmed);
    }
  }

  for (final value in builtInValues) {
    addValue(value);
  }
  for (final value in customValues) {
    addValue(value);
  }
  for (final value in selectedValues) {
    addValue(value);
  }

  return List<String>.unmodifiable(merged);
}
