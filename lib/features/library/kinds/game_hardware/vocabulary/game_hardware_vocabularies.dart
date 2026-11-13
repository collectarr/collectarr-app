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
      valuesFrom: TypedVocabularyProjector<GameHardwareCatalogMetadata>(
          _platformValues),
      // Platforms are filed by their name.
      hasSortName: false);
  static const series = VocabularyDefinition<String>(
      id: VocabularyId('game_hardware.series'),
      label: 'Series',
      valuesFrom:
          TypedVocabularyProjector<GameHardwareCatalogMetadata>(_seriesValues));
  static const hardwareType = VocabularyDefinition<String>(
      id: VocabularyId('game_hardware.hardware_type'),
      label: 'Hardware Type',
      builtIns: ['Console', 'Controller', 'Accessory'],
      valuesFrom: TypedVocabularyProjector<GameHardwareCatalogMetadata>(
          _hardwareTypeValues),
      // Hardware types are filed by their name.
      hasSortName: false);
  static const condition = VocabularyDefinition<String>(
      id: VocabularyId('game_hardware.condition'),
      label: 'Condition',
      // Conditions are filed by their name.
      hasSortName: false);
  static const all = <VocabularyDefinition<dynamic>>[
    platform,
    series,
    hardwareType,
    condition
  ];
  static const entries = PickListEntryValues<GameHardwareLibraryEntry>(
    listActive: _listActive,
    idFrom: _entryId,
    valuesFrom: _entryValues,
    replaceValue: _replaceEntryValue,
    save: _save,
  );

  static Future<List<GameHardwareLibraryEntry>> _listActive(LocalDatabase db) =>
      GameHardwareEntryRepository(db).listActive();

  static String _entryId(GameHardwareLibraryEntry item) => item.id.value;

  static Future<void> _save(LocalDatabase db, GameHardwareLibraryEntry item) =>
      GameHardwareEntryRepository(db).upsert(item);

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
Iterable<String?> _hardwareTypeValues(GameHardwareCatalogMetadata metadata) =>
    [metadata.hardwareType];
