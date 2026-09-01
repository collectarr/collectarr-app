import 'package:collectarr_app/features/collection/vocabulary/vocabulary_definition.dart';
import 'package:collectarr_app/features/collection/vocabulary/vocabulary_id.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';

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
    valuesFrom: TypedVocabularyProjector<AnimeMetadata>(_formatCatalogValues),
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
    valuesFrom: TypedVocabularyProjector<AnimeMetadata>(_studioCatalogValues),
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
    valuesFrom: TypedVocabularyProjector<AnimeMetadata>(_seasonCatalogValues),
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

Iterable<String?> _formatCatalogValues(AnimeMetadata metadata) sync* {
  yield* vocabularyValues([
    metadata.format.label,
    metadata.physicalFormatLabel,
    metadata.physicalFormat,
  ]);
}

Iterable<String?> _studioCatalogValues(AnimeMetadata metadata) sync* {
  yield* vocabularyValues([metadata.studios]);
}

Iterable<String?> _seasonCatalogValues(AnimeMetadata metadata) {
  return vocabularyValues([metadata.season?.label]);
}
