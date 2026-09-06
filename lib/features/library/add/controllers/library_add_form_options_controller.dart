import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_options.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';

/// Loads Add form options without owning dialog state or UI behavior.
class LibraryAddFormOptionsController {
  const LibraryAddFormOptionsController();

  Future<List<StorageLocation>> loadLocations(LocalDatabase database) {
    return LocationRepository(database).getAll();
  }

  Future<LibraryAddFormPickListOptions> loadPickLists({
    required LocalDatabase database,
    required LibraryKindModule type,
    required String selectedCondition,
    required String selectedGrade,
    String? selectedTags,
  }) async {
    final conditionDefinition =
        type.edit.vocabularies?.definitionForSuffix('condition');
    final gradeDefinition =
        type.edit.vocabularies?.definitionForSuffix('grade');
    final builtInConditions = conditionDefinition == null
        ? type.edit.conditions
        : [for (final value in conditionDefinition.builtIns) value.toString()];
    final builtInGrades = gradeDefinition == null
        ? type.edit.grades
        : [for (final value in gradeDefinition.builtIns) value.toString()];
    final conditionGradeOptions = await loadConditionGradePickListOptions(
      database,
      mediaKind: type.kind.apiValue,
      builtInConditions: builtInConditions,
      builtInGrades: builtInGrades,
      conditionListName: conditionDefinition?.key,
      gradeListName: gradeDefinition?.key,
      selectedCondition: selectedCondition,
      selectedGrade: selectedGrade,
    );
    final tags = await loadTagPickListOptions(
      database,
      mediaKind: type.kind.apiValue,
      selectedTags: splitPickListValues(selectedTags),
    );
    return LibraryAddFormPickListOptions(
      conditions: conditionGradeOptions.conditions,
      grades: conditionGradeOptions.grades,
      tags: tags,
    );
  }
}

class LibraryAddFormPickListOptions {
  const LibraryAddFormPickListOptions({
    required this.conditions,
    required this.grades,
    required this.tags,
  });

  final List<String> conditions;
  final List<String> grades;
  final List<String> tags;
}
