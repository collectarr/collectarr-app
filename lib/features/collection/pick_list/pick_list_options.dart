import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/collection/repositories/pick_list_repository.dart';

const String kConditionPickListName = 'conditions';
const String kGradePickListName = 'grades';
const String kTagPickListName = 'tags';
const String kPublisherPickListName = 'publishers';
const String kImprintPickListName = 'imprints';
const String kSeriesGroupPickListName = 'series_groups';
const String kPhysicalFormatPickListName = 'physical_formats';
const String kCountryPickListName = 'countries';
const String kLanguagePickListName = 'languages';
const String kAgeRatingPickListName = 'age_ratings';
const String kGenrePickListName = 'genres';
const String kCrossoverPickListName = 'crossovers';
const String kStoryArcPickListName = 'story_arcs';

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
    listName: kTagPickListName,
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
  String? selectedCondition,
  String? selectedGrade,
}) async {
  final repo = PickListRepository(db);
  final results = await Future.wait([
    repo.getValues(kConditionPickListName, mediaKind: mediaKind),
    repo.getValues(kGradePickListName, mediaKind: mediaKind),
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
