import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_options.dart';
import 'package:collectarr_app/features/collection/repositories/pick_list_repository.dart';
import 'package:collectarr_app/features/collection/vocabulary/vocabulary_definition.dart';

abstract interface class VocabularyRepository {
  Future<List<String>> loadOptions<T>({
    required String mediaKind,
    required VocabularyDefinition<T> definition,
    Iterable<String?> selectedValues = const [],
  });

  Future<void> saveCustomValue<T>({
    required String mediaKind,
    required VocabularyDefinition<T> definition,
    required String value,
  });

  Future<void> removeCustomValue<T>({
    required String mediaKind,
    required VocabularyDefinition<T> definition,
    required String value,
  });
}

class DatabaseVocabularyRepository implements VocabularyRepository {
  DatabaseVocabularyRepository(this._db);

  final LocalDatabase _db;
  late final _pickLists = PickListRepository(_db);

  @override
  Future<List<String>> loadOptions<T>({
    required String mediaKind,
    required VocabularyDefinition<T> definition,
    Iterable<String?> selectedValues = const [],
  }) async {
    final customValues = await _pickLists.getValues(
      definition.key,
      mediaKind: mediaKind,
    );

    final builtInStrings = definition.builtIns
        .map((item) => item.toString())
        .toList(growable: false);

    return mergePickListValues(
      builtInValues: builtInStrings,
      customValues: customValues,
      selectedValues: selectedValues,
    );
  }

  @override
  Future<void> saveCustomValue<T>({
    required String mediaKind,
    required VocabularyDefinition<T> definition,
    required String value,
  }) async {
    if (!definition.allowCustomValues || value.trim().isEmpty) return;
    await _pickLists.addValue(
      definition.key,
      value.trim(),
      mediaKind: mediaKind,
    );
  }

  @override
  Future<void> removeCustomValue<T>({
    required String mediaKind,
    required VocabularyDefinition<T> definition,
    required String value,
  }) async {
    final values = await _pickLists.valuesForList(
      listName: definition.key,
      mediaKind: mediaKind,
    );
    final target = values.where(
      (item) => item.value.trim().toLowerCase() == value.trim().toLowerCase(),
    );
    for (final item in target) {
      await _pickLists.deleteValue(item.id);
    }
  }
}
