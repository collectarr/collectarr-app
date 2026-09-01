import 'package:collectarr_app/features/collection/vocabulary/vocabulary_definition.dart';
import 'package:collectarr_app/features/collection/vocabulary/vocabulary_id.dart';

abstract final class AnimeVocabularyIds {
  static const demographic = VocabularyId<String>('anime.demographic');
  static const format = VocabularyId<String>('anime.format');
  static const studio = VocabularyId<String>('anime.studio');
  static const season = VocabularyId<String>('anime.season');
}

abstract final class AnimeVocabularies {
  static const demographic = VocabularyDefinition<String>(
    id: AnimeVocabularyIds.demographic,
    label: 'Demographic',
    builtIns: [
      'Shounen',
      'Seinen',
      'Shoujo',
      'Josei',
      'Kids',
    ],
  );

  static const format = VocabularyDefinition<String>(
    id: AnimeVocabularyIds.format,
    label: 'Format',
    catalogValueReader: _formatCatalogValues,
    builtIns: [
      'TV Series',
      'Movie',
      'OVA',
      'ONA (Web)',
      'Special',
      'Music Video',
    ],
  );

  static const studio = VocabularyDefinition<String>(
    id: AnimeVocabularyIds.studio,
    label: 'Animation Studio',
    catalogValueReader: _studioCatalogValues,
    builtIns: [
      'Kyoto Animation',
      'MAPPA',
      'ufotable',
      'Madhouse',
      'Bones',
      'Wit Studio',
      'CloverWorks',
      'A-1 Pictures',
      'Production I.G',
      'Shaft',
      'Studio Ghibli',
      'Toei Animation',
      'Sunrise',
    ],
  );

  static const season = VocabularyDefinition<String>(
    id: AnimeVocabularyIds.season,
    label: 'Release Season',
    catalogValueReader: _seasonCatalogValues,
    builtIns: [
      'Winter',
      'Spring',
      'Summer',
      'Fall',
    ],
  );

  static const all = <VocabularyDefinition<dynamic>>[
    demographic,
    format,
    studio,
    season,
  ];
}

Iterable<String?> _formatCatalogValues(Map<String, dynamic> payload) sync* {
  yield* vocabularyPayloadValuesForKey(payload, 'format');
  yield* vocabularyPayloadValuesForKey(payload, 'physical_format_label');
}

Iterable<String?> _studioCatalogValues(Map<String, dynamic> payload) sync* {
  yield* vocabularyPayloadValuesForKey(payload, 'studio');
  yield* vocabularyPayloadValuesForKey(payload, 'animation_studio');
}

Iterable<String?> _seasonCatalogValues(Map<String, dynamic> payload) {
  return vocabularyPayloadValuesForKey(payload, 'season');
}
