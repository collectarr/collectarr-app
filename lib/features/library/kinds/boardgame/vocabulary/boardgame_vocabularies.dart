import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_owned_repository.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_definition.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_id.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_definition_contributor.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_owned_item.dart';

abstract final class BoardGameVocabularyIds {
  static const condition = VocabularyId<String>('boardgame.condition');
  static const publisher = VocabularyId<String>('boardgame.publisher');
  static const format = VocabularyId<String>('boardgame.format');
  static const category = VocabularyId<String>('boardgame.category');
}

abstract final class BoardGameVocabularies {
  static Future<int> countOwnedValue(
    LocalDatabase db,
    String semanticName,
    String normalizedValue,
  ) {
    return countPickListOwnedValues(
      items: BoardGameOwnedRepository(db).listActive(),
      normalizedValue: normalizedValue,
      valuesFrom: (item) => _ownedValues(item, semanticName),
    );
  }

  static Future<PickListOwnedMergeResult> previewOwnedMerge(
    LocalDatabase db,
    String semanticName,
    Set<String> normalizedSourceValues,
  ) {
    return previewPickListOwnedMerge(
      items: BoardGameOwnedRepository(db).listActive(),
      idFrom: (item) => item.id.value,
      valuesFrom: (item) => _ownedValues(item, semanticName),
      normalizedSourceValues: normalizedSourceValues,
    );
  }

  static Future<void> applyOwnedMerge(
    LocalDatabase db,
    String semanticName,
    Set<String> normalizedSourceValues,
    String targetValue,
  ) {
    return applyPickListOwnedMerge(
      items: BoardGameOwnedRepository(db).listActive(),
      valuesFrom: (item) => _ownedValues(item, semanticName),
      replaceValue: (item, sources, target) =>
          _replaceOwnedValue(item, semanticName, sources, target),
      save: BoardGameOwnedRepository(db).upsert,
      normalizedSourceValues: normalizedSourceValues,
      targetValue: targetValue,
    );
  }

  static BoardGameOwnedItem _replaceOwnedValue(
    BoardGameOwnedItem item,
    String semanticName,
    Set<String> normalizedSourceValues,
    String targetValue,
  ) {
    switch (semanticName) {
      case 'condition':
        return item.copyWith(condition: targetValue);
      case 'grade':
        return item.copyWith(grade: targetValue);
      case 'purchase_store':
        return item.copyWith(purchaseStore: targetValue);
      case 'sold_to':
        return item.copyWith(soldTo: targetValue);
      case 'collection_status':
        return item.copyWith(collectionStatus: targetValue);
      case 'tags':
        return item.copyWith(
          tags: replacePickListDelimitedValue(
            item.tags,
            normalizedSourceValues,
            targetValue,
          ),
        );
    }
    return item;
  }

  static Iterable<String?> _ownedValues(
    BoardGameOwnedItem item,
    String semanticName,
  ) sync* {
    final standard = switch (semanticName) {
      'condition' => item.condition,
      'grade' => item.grade,
      'purchase_store' => item.purchaseStore,
      'sold_to' => item.soldTo,
      'collection_status' => item.collectionStatus,
      _ => null,
    };
    if (standard != null) {
      yield standard;
      return;
    }
    if (semanticName == 'tags') {
      yield* item.tags?.split(',') ?? const <String>[];
      return;
    }
    final key = switch (semanticName) {
      'region' => 'edition_region',
      'condition' => 'component_condition',
      'game_completeness' => 'component_completeness',
      _ => null,
    };
    if (key != null) {
      yield* pickListTextValues(item.details.toJson()[key]);
    }
  }

  static const condition = VocabularyDefinition<String>(
    id: BoardGameVocabularyIds.condition,
    label: 'Condition',
    builtIns: [
      'Mint',
      'Near Mint',
      'Very Good',
      'Good',
      'Fair',
      'Poor',
    ],
  );

  static const publisher = VocabularyDefinition<String>(
    id: BoardGameVocabularyIds.publisher,
    label: 'Publisher',
    valuesFrom:
        TypedVocabularyProjector<BoardGameMetadata>(_publisherCatalogValues),
    builtIns: [
      'Fantasy Flight Games',
      'Asmodee',
      'Stonemaier Games',
      'Days of Wonder',
      'Czech Games Edition',
      'Z-Man Games',
      'Ravensburger',
      'Lookout Games',
      'Kosmos',
      'Cephalofair Games',
      'Leder Games',
    ],
  );

  static const format = VocabularyDefinition<String>(
    id: BoardGameVocabularyIds.format,
    label: 'Edition / Format',
    valuesFrom:
        TypedVocabularyProjector<BoardGameMetadata>(_formatCatalogValues),
    builtIns: [
      'Base Game',
      'Expansion',
      'Standalone Expansion',
      'Deluxe Edition',
      'Kickstarter / Crowdfunded Edition',
      "Collector's Big Box",
      'Promo / Mini-Expansion',
    ],
  );

  static const category = VocabularyDefinition<String>(
    id: BoardGameVocabularyIds.category,
    label: 'Category',
    valuesFrom:
        TypedVocabularyProjector<BoardGameMetadata>(_categoryCatalogValues),
    builtIns: [
      'Strategy',
      'Eurogame',
      'Thematic / Ameritrash',
      'Deck Building',
      'Worker Placement',
      'Cooperative',
      'Party Game',
      'Wargame',
      'Abstract',
      'Legacy / Campaign',
    ],
  );

  static const all = <VocabularyDefinition<dynamic>>[
    condition,
    publisher,
    format,
    category,
  ];
}

Iterable<String?> _publisherCatalogValues(BoardGameMetadata metadata) sync* {
  yield* vocabularyValues([metadata.publisher, metadata.publishers]);
}

Iterable<String?> _formatCatalogValues(BoardGameMetadata metadata) sync* {
  yield* vocabularyValues([
    metadata.physicalFormatLabel,
    metadata.physicalFormat,
  ]);
}

Iterable<String?> _categoryCatalogValues(BoardGameMetadata metadata) {
  return vocabularyValues([metadata.categories]);
}
