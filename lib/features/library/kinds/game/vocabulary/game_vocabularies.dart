import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_entry_repository.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_definition.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_id.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_definition_contributor.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_entry_details.dart';

abstract final class GameVocabularyIds {
  static const platform = VocabularyId<String>('game.platform');
  static const region = VocabularyId<String>('game.region');
  static const edition = VocabularyId<String>('game.edition');
  static const ageRating = VocabularyId<String>('game.age_rating');
  static const condition = VocabularyId<String>('game.condition');
}

abstract final class GameVocabularies {
  static Future<List<String>> entryOptions(
      LocalDatabase db, String semanticName) async {
    return [
      for (final item in await GameEntryRepository(db).listActive())
        ..._entryValues(item, semanticName)
            .whereType<String>()
            .where((value) => value.trim().isNotEmpty)
    ];
  }

  static Future<Map<String, int>> entryUsageCounts(LocalDatabase db, String semanticName) =>
    countPickListEntryUsages(items: GameEntryRepository(db).listActive(), valuesFrom: (item) => _entryValues(item, semanticName));

  static Future<PickListEntryMergeResult> previewEntryMerge(
    LocalDatabase db,
    String semanticName,
    Set<String> normalizedSourceValues,
  ) {
    return previewPickListEntryMerge(
      items: GameEntryRepository(db).listActive(),
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
      items: GameEntryRepository(db).listActive(),
      valuesFrom: (item) => _entryValues(item, semanticName),
      replaceValue: (item, sources, target) =>
          _replaceEntryValue(item, semanticName, sources, target),
      save: GameEntryRepository(db).upsert,
      normalizedSourceValues: normalizedSourceValues,
      targetValue: targetValue,
    );
  }

  static GameLibraryEntry _replaceEntryValue(
    GameLibraryEntry item,
    String semanticName,
    Set<String> normalizedSourceValues,
    String targetValue,
  ) {
    switch (semanticName) {
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
          tags: replacePickListDelimitedValue(
            item.personal.tags,
            normalizedSourceValues,
            targetValue,
          ),
        ));
    }
    final key = switch (semanticName) {
      'game_completeness' => 'game_completeness',
      'region' => 'game_core_region',
      _ => null,
    };
    if (key == null) return item;
    final details = item.personal.details.toJson()..[key] = targetValue;
    return item.copyWith(
        personal: item.personal
            .copyWith(details: GameEntryDetails.fromJson(details)));
  }

  static Iterable<String?> _entryValues(
    GameLibraryEntry item,
    String semanticName,
  ) sync* {
    final standard = switch (semanticName) {
      'condition' => item.personal.condition,
      'grade' => item.personal.grade,
      'purchase_store' => item.personal.purchaseStore,
      'sold_to' => item.personal.soldTo,
      'collection_status' => item.personal.collectionStatus,
      _ => null,
    };
    if (standard != null) {
      yield standard;
      return;
    }
    if (semanticName == 'tags') {
      yield* item.personal.tags?.split(',') ?? const <String>[];
      return;
    }
    final key = switch (semanticName) {
      'game_completeness' => 'game_completeness',
      'region' => 'game_core_region',
      _ => null,
    };
    if (key != null) {
      yield* pickListTextValues(item.personal.details.toJson()[key]);
    }
    for (final vocabulary in all) {
      if (vocabulary.key.split('.').last == semanticName) {
        yield* vocabulary.valuesFrom?.call(item.metadata) ?? const <String>[];
      }
    }
  }

  static const platform = VocabularyDefinition<String>(
    id: GameVocabularyIds.platform,
    label: 'Platform',
    valuesFrom:
        TypedVocabularyProjector<GameCatalogMetadata>(_platformCatalogValues),
    builtIns: [
      'PlayStation 5',
      'PlayStation 4',
      'PlayStation 3',
      'PlayStation 2',
      'PlayStation',
      'PlayStation Portable',
      'PlayStation Vita',
      'Nintendo Switch',
      'Nintendo Wii U',
      'Nintendo Wii',
      'Nintendo GameCube',
      'Nintendo 64',
      'Super Nintendo Entertainment System',
      'Nintendo Entertainment System',
      'Nintendo 3DS',
      'Nintendo DS',
      'Game Boy Advance',
      'Game Boy Color',
      'Game Boy',
      'Xbox Series X/S',
      'Xbox One',
      'Xbox 360',
      'Xbox',
      'PC',
      'Sega Dreamcast',
      'Sega Saturn',
      'Sega Genesis',
    ],
  );

  static const region = VocabularyDefinition<String>(
    id: GameVocabularyIds.region,
    label: 'Region',
    valuesFrom:
        TypedVocabularyProjector<GameCatalogMetadata>(_regionCatalogValues),
    builtIns: [
      'NTSC-U/C (US/Canada)',
      'PAL (Europe/Australia)',
      'NTSC-J (Japan)',
      'NTSC-C (China)',
      'Region Free',
    ],
  );

  static const edition = VocabularyDefinition<String>(
    id: GameVocabularyIds.edition,
    label: 'Edition / Format',
    valuesFrom:
        TypedVocabularyProjector<GameCatalogMetadata>(_editionCatalogValues),
    builtIns: [
      'Standard Edition',
      "Collector's Edition",
      'Limited Edition',
      'Deluxe Edition',
      'Steelbook Edition',
      'Day One Edition',
      'Game of the Year Edition',
      'Complete Edition',
      'Greatest Hits / Platinum',
    ],
  );

  static const ageRating = VocabularyDefinition<String>(
    id: GameVocabularyIds.ageRating,
    label: 'Age Rating',
    valuesFrom:
        TypedVocabularyProjector<GameCatalogMetadata>(_ageRatingCatalogValues),
    builtIns: [
      'ESRB: Everyone (E)',
      'ESRB: Everyone 10+ (E10+)',
      'ESRB: Teen (T)',
      'ESRB: Mature 17+ (M)',
      'ESRB: Adults Only 18+ (AO)',
      'PEGI 3',
      'PEGI 7',
      'PEGI 12',
      'PEGI 16',
      'PEGI 18',
      'CERO A',
      'CERO B',
      'CERO C',
      'CERO D',
      'CERO Z',
    ],
  );

  static const condition = VocabularyDefinition<String>(
    id: GameVocabularyIds.condition,
    label: 'Condition',
    builtIns: [
      'Brand New / Sealed',
      'Complete in Box (CIB)',
      'Boxed (Missing Manual)',
      'Loose / Cartridge Only',
      'Disc Only',
      'Digital / Code',
    ],
  );

  static const all = <VocabularyDefinition<dynamic>>[
    platform,
    region,
    edition,
    ageRating,
    condition,
  ];
}

Iterable<String?> _platformCatalogValues(GameCatalogMetadata metadata) sync* {
  yield* vocabularyValues(metadata.platforms);
}

Iterable<String?> _regionCatalogValues(GameCatalogMetadata metadata) {
  return vocabularyValues([metadata.releaseRegion]);
}

Iterable<String?> _editionCatalogValues(GameCatalogMetadata metadata) sync* {
  yield* vocabularyValues([
    metadata.editionTitle,
    metadata.physicalFormatLabel,
    metadata.physicalFormat,
  ]);
}

Iterable<String?> _ageRatingCatalogValues(GameCatalogMetadata metadata) {
  return vocabularyValues([metadata.ageRating]);
}
