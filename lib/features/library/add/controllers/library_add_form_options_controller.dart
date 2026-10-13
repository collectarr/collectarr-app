import 'package:collectarr_app/features/library/kinds/registry/library_kind_contributors.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_options.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';

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
    String? selectedOwner,
    String? selectedPurchaseStore,
  }) async {
    final conditionDefinition = libraryEditPresentationForKind(type.kind)
        .vocabularies
        ?.definitionForSuffix('condition');
    final builtInConditions = conditionDefinition == null
        ? libraryEditPresentationForKind(type.kind).conditions
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
    final owners = await loadSingleValuePickListOptions(
      database,
      listName: UniversalVocabularies.owners.key,
      mediaKind: type.kind.apiValue,
      selectedValue: selectedOwner,
    );
    final purchaseStores = await loadSingleValuePickListOptions(
      database,
      listName: UniversalVocabularies.purchaseStore.key,
      mediaKind: type.kind.apiValue,
      selectedValue: selectedPurchaseStore,
    );
    return LibraryAddFormPickListOptions(
      conditions: conditionOptions.conditions,
      tags: tags,
      owners: owners,
      purchaseStores: purchaseStores,
    );
  }
}

class LibraryAddFormPickListOptions {
  const LibraryAddFormPickListOptions({
    required this.conditions,
    required this.tags,
    required this.owners,
    required this.purchaseStores,
  });

  final List<String> conditions;
  final List<String> tags;
  final List<String> owners;
  final List<String> purchaseStores;
}
