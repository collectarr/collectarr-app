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
  static const condition = VocabularyId<String>('game.condition');
  static const audienceRating = VocabularyId<String>('game.audience_rating');
  static const series = VocabularyId<String>('game.series');
  static const developer = VocabularyId<String>('game.developer');
  static const publisher = VocabularyId<String>('game.publisher');
  static const genre = VocabularyId<String>('game.genre');
  static const format = VocabularyId<String>('game.format');
  static const storageDevice = VocabularyId<String>('game.storage_device');
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

  static Future<Map<String, int>> entryUsageCounts(
          LocalDatabase db, String semanticName) =>
      countPickListEntryUsages(
          items: GameEntryRepository(db).listActive(),
          valuesFrom: (item) => _entryValues(item, semanticName));

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
          tags: replacePickListValueInList(
            item.personal.tags,
            normalizedSourceValues,
            targetValue,
          ),
        ));
    }
    final key = switch (semanticName) {
      'game_completeness' => 'game_completeness',
      'region' => 'game_core_region',
      'storage_device' => 'game_storage_device',
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
      yield* item.personal.tags;
      return;
    }
    final key = switch (semanticName) {
      'game_completeness' => 'game_completeness',
      'region' => 'game_core_region',
      'storage_device' => 'game_storage_device',
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
  );

  static const region = VocabularyDefinition<String>(
    id: GameVocabularyIds.region,
    label: 'Region',
    valuesFrom:
        TypedVocabularyProjector<GameCatalogMetadata>(_regionCatalogValues),
  );

  static const condition = VocabularyDefinition<String>(
    id: GameVocabularyIds.condition,
    label: 'Condition',
  );

  static const audienceRating = VocabularyDefinition<String>(
    id: GameVocabularyIds.audienceRating,
    label: 'Audience Rating',
    valuesFrom: TypedVocabularyProjector<GameCatalogMetadata>(
        _audienceRatingCatalogValues),
  );

  static const series = VocabularyDefinition<String>(
    id: GameVocabularyIds.series,
    label: 'Series',
    valuesFrom:
        TypedVocabularyProjector<GameCatalogMetadata>(_seriesCatalogValues),
  );

  static const developer = VocabularyDefinition<String>(
    id: GameVocabularyIds.developer,
    label: 'Developer',
    valuesFrom:
        TypedVocabularyProjector<GameCatalogMetadata>(_developerCatalogValues),
  );

  static const publisher = VocabularyDefinition<String>(
    id: GameVocabularyIds.publisher,
    label: 'Publisher',
    valuesFrom:
        TypedVocabularyProjector<GameCatalogMetadata>(_publisherCatalogValues),
  );

  static const genre = VocabularyDefinition<String>(
    id: GameVocabularyIds.genre,
    label: 'Genre',
    valuesFrom:
        TypedVocabularyProjector<GameCatalogMetadata>(_genreCatalogValues),
  );

  static const format = VocabularyDefinition<String>(
    id: GameVocabularyIds.format,
    label: 'Format',
    valuesFrom:
        TypedVocabularyProjector<GameCatalogMetadata>(_formatCatalogValues),
  );

  static const storageDevice = VocabularyDefinition<String>(
    id: GameVocabularyIds.storageDevice,
    label: 'Storage Device',
  );

  static const all = <VocabularyDefinition<dynamic>>[
    platform,
    region,
    condition,
    audienceRating,
    series,
    developer,
    publisher,
    genre,
    format,
    storageDevice,
  ];
}

Iterable<String?> _platformCatalogValues(GameCatalogMetadata metadata) sync* {
  yield* vocabularyValues(metadata.platforms);
}

Iterable<String?> _regionCatalogValues(GameCatalogMetadata metadata) {
  return vocabularyValues([metadata.releaseRegion]);
}

Iterable<String?> _audienceRatingCatalogValues(GameCatalogMetadata metadata) =>
    vocabularyValues([metadata.audienceRating]);

Iterable<String?> _seriesCatalogValues(GameCatalogMetadata metadata) =>
    vocabularyValues([metadata.seriesTitle]);

Iterable<String?> _developerCatalogValues(GameCatalogMetadata metadata) =>
    vocabularyValues(metadata.developers);

Iterable<String?> _publisherCatalogValues(GameCatalogMetadata metadata) =>
    vocabularyValues(splitGamePublishers(metadata.publisher));

Iterable<String?> _genreCatalogValues(GameCatalogMetadata metadata) =>
    vocabularyValues(metadata.genres);

Iterable<String?> _formatCatalogValues(GameCatalogMetadata metadata) =>
    vocabularyValues([metadata.physicalFormatLabel]);

/// Core stores one publisher string; the editor lists several, as the
/// reference does, joined with a slash.
List<String> splitGamePublishers(String? publisher) => [
      for (final name in (publisher ?? '').split(' / '))
        if (name.trim().isNotEmpty) name.trim(),
    ];

String joinGamePublishers(Iterable<String> names) => names
    .map((name) => name.trim())
    .where((name) => name.isNotEmpty)
    .join(' / ');
