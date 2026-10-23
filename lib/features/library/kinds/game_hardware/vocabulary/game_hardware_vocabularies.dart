import '../domain/game_hardware_library_entry.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_definition_contributor.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_definition.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_id.dart';
import '../domain/game_hardware_metadata.dart';
import '../data/game_hardware_entry_repository.dart';

abstract final class GameHardwareVocabularies {
  static const platform = VocabularyDefinition<String>(
      id: VocabularyId('game_hardware.platform'),
      label: 'Platform',
      builtIns: [
        'PlayStation 5',
        'PlayStation 4',
        'Nintendo Switch',
        'Xbox Series X',
        'Xbox One',
        'PC',
        'Other'
      ],
      valuesFrom: TypedVocabularyProjector<GameHardwareCatalogMetadata>(
          _platformValues));
  static const series = VocabularyDefinition<String>(
      id: VocabularyId('game_hardware.series'),
      label: 'Series',
      builtIns: [],
      valuesFrom:
          TypedVocabularyProjector<GameHardwareCatalogMetadata>(_seriesValues));
  static const condition = VocabularyDefinition<String>(
      id: VocabularyId('game_hardware.condition'),
      label: 'Condition',
      builtIns: ['Mint', 'Near Mint', 'Very Good', 'Good', 'Fair', 'Poor']);
  static const all = <VocabularyDefinition<dynamic>>[
    platform,
    series,
    condition
  ];
  static Future<List<String>> entryOptions(
      LocalDatabase db, String semanticName) async {
    return [
      for (final item in await GameHardwareEntryRepository(db).listActive())
        ..._entryValues(item, semanticName)
            .whereType<String>()
            .where((value) => value.trim().isNotEmpty)
    ];
  }

  static Future<Map<String, int>> entryUsageCounts(
          LocalDatabase db, String semanticName) =>
      countPickListEntryUsages(
          items: GameHardwareEntryRepository(db).listActive(),
          valuesFrom: (item) => _entryValues(item, semanticName));

  static Future<PickListEntryMergeResult> previewEntryMerge(
    LocalDatabase db,
    String semanticName,
    Set<String> normalizedSourceValues,
  ) {
    return previewPickListEntryMerge(
      items: GameHardwareEntryRepository(db).listActive(),
      idFrom: (item) => item.id.value,
      valuesFrom: (item) => _entryValues(item, semanticName),
      normalizedSourceValues: normalizedSourceValues,
    );
  }

  static Future<void> applyEntryMerge(
    LocalDatabase db,
    String semanticName,
    Set<String> normalizedSourceValues,
    String targetValue,
  ) {
    return applyPickListEntryMerge(
      items: GameHardwareEntryRepository(db).listActive(),
      valuesFrom: (item) => _entryValues(item, semanticName),
      replaceValue: (item, sources, target) =>
          _replaceEntryValue(item, semanticName, sources, target),
      save: GameHardwareEntryRepository(db).upsert,
      normalizedSourceValues: normalizedSourceValues,
      targetValue: targetValue,
    );
  }

  static GameHardwareLibraryEntry _replaceEntryValue(
    GameHardwareLibraryEntry item,
    String semanticName,
    Set<String> normalizedSourceValues,
    String targetValue,
  ) {
    switch (semanticName) {
      case 'owner_label':
        return item.copyWith(
            personal: item.personal.copyWith(ownerLabel: targetValue));
      case 'condition':
        return item.copyWith(
            personal: item.personal.copyWith(condition: targetValue));
      case 'grade':
        return item.copyWith(
            personal: item.personal.copyWith(grade: targetValue));
      case 'purchase_store':
        return item.copyWith(
            personal: item.personal.copyWith(purchaseStore: targetValue));
      case 'sold_to':
        return item.copyWith(
            personal: item.personal.copyWith(soldTo: targetValue));
      case 'collection_status':
        return item.copyWith(
            personal: item.personal.copyWith(collectionStatus: targetValue));
      case 'tags':
        return item.copyWith(
            personal: item.personal.copyWith(
          tags: replacePickListValueInList(
            item.personal.tags,
            normalizedSourceValues,
            targetValue,
          ),
        ));
    }
    return item;
  }

  static Iterable<String?> _entryValues(
          GameHardwareLibraryEntry item, String semanticName) =>
      [
        if (semanticName == 'condition') item.personal.condition,
        if (semanticName == 'grade') item.personal.grade,
        if (semanticName == 'purchase_store') item.personal.purchaseStore,
        if (semanticName == 'owner_label') item.personal.ownerLabel,
        if (semanticName == 'sold_to') item.personal.soldTo,
        if (semanticName == 'collection_status') item.personal.collectionStatus,
        if (semanticName == 'tags') ...item.personal.tags,
      ];
}

Iterable<String?> _platformValues(GameHardwareCatalogMetadata metadata) =>
    [metadata.platform];
Iterable<String?> _seriesValues(GameHardwareCatalogMetadata metadata) =>
    [metadata.seriesTitle];
