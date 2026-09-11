import 'package:collectarr_app/features/library/kinds/registry/library_kind_capabilities.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_options.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_bundle.dart';

/// Loads Add form options without owning dialog state or UI behavior.
class LibraryAddFormOptionsController {
  const LibraryAddFormOptionsController();

  Future<List<StorageLocation>> loadLocations(LocalDatabase database) {
    return LocationRepository(database).getAll();
  }

  Future<LibraryAddFormPickListOptions> loadPickLists({
    required LocalDatabase database,
    required LibraryKindRegistration type,
    required String selectedCondition,
    String? selectedTags,
  }) async {
    final conditionDefinition =
        type.edit.vocabularies?.definitionForSuffix('condition');
    final builtInConditions = conditionDefinition == null
        ? type.edit.conditions
        : [for (final value in conditionDefinition.builtIns) value.toString()];
    final conditionOptions = await loadConditionGradePickListOptions(
      database,
      mediaKind: type.kind.apiValue,
      builtInConditions: builtInConditions,
      conditionListName: conditionDefinition?.key,
      selectedCondition: selectedCondition,
    );
    final tags = await loadTagPickListOptions(
      database,
      mediaKind: type.kind.apiValue,
      selectedTags: splitPickListValues(selectedTags),
    );
    return LibraryAddFormPickListOptions(
      conditions: conditionOptions.conditions,
      tags: tags,
    );
  }
}

class LibraryAddFormPickListOptions {
  const LibraryAddFormPickListOptions({
    required this.conditions,
    required this.tags,
  });

  final List<String> conditions;
  final List<String> tags;
}
