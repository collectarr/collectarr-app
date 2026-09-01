import 'package:collectarr_app/features/collection/vocabulary/vocabulary_definition.dart';
import 'package:collectarr_app/features/collection/vocabulary/vocabulary_id.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';

abstract final class BoardGameVocabularyIds {
  static const publisher = VocabularyId<String>('boardgame.publisher');
  static const format = VocabularyId<String>('boardgame.format');
  static const category = VocabularyId<String>('boardgame.category');
}

abstract final class BoardGameVocabularies {
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
