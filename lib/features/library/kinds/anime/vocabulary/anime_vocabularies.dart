import 'package:collectarr_app/features/pick_lists/models/vocabulary_definition.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_id.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';

abstract final class AnimeVocabularyIds {
  static const condition = VocabularyId<String>('anime.condition');
  static const demographic = VocabularyId<String>('anime.demographic');
  static const format = VocabularyId<String>('anime.format');
  static const studio = VocabularyId<String>('anime.studio');
  static const season = VocabularyId<String>('anime.season');
  static const physicalFormat = VocabularyId<String>('anime.physical_format');
  static const region = VocabularyId<String>('anime.region');
  static const packaging = VocabularyId<String>('anime.packaging');
  static const distributor = VocabularyId<String>('anime.distributor');
  static const hdr = VocabularyId<String>('anime.hdr');
}

abstract final class AnimeVocabularies {
  static const condition = VocabularyDefinition<String>(
    id: AnimeVocabularyIds.condition,
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

  static const physicalFormat = VocabularyDefinition<String>(
    id: AnimeVocabularyIds.physicalFormat,
    label: 'Physical format',
    valuesFrom: TypedVocabularyProjector<AnimeMetadata>(
      _physicalFormatCatalogValues,
    ),
    builtIns: [
      '4K Ultra HD Blu-ray',
      'Blu-ray',
      'DVD',
      'LaserDisc',
      'VHS',
      'Digital',
    ],
  );

  static const region = VocabularyDefinition<String>(
    id: AnimeVocabularyIds.region,
    label: 'Region',
    valuesFrom: TypedVocabularyProjector<AnimeMetadata>(_regionCatalogValues),
    builtIns: [
      'Region A / Region 1',
      'Region B / Region 2',
      'Region C / Region 3',
      'Region Free',
    ],
  );

  static const packaging = VocabularyDefinition<String>(
    id: AnimeVocabularyIds.packaging,
    label: 'Packaging',
    valuesFrom:
        TypedVocabularyProjector<AnimeMetadata>(_packagingCatalogValues),
    builtIns: [
      'Complete Series Box Set',
      'Season Box Set',
      'Multi-Disc Keep Case',
      'Steelbook',
      'Digipak',
      'Slipcover',
    ],
  );

  static const distributor = VocabularyDefinition<String>(
    id: AnimeVocabularyIds.distributor,
    label: 'Distributor / Studio',
    valuesFrom:
        TypedVocabularyProjector<AnimeMetadata>(_distributorCatalogValues),
    builtIns: [
      'Aniplex',
      'Crunchyroll',
      'Discotek Media',
      'Funimation',
      'GKIDS',
      'Sentai Filmworks',
      'Right Stuf',
      'Toei Animation',
    ],
  );

  static const hdr = VocabularyDefinition<String>(
    id: AnimeVocabularyIds.hdr,
    label: 'HDR / Video format',
    valuesFrom: TypedVocabularyProjector<AnimeMetadata>(_hdrCatalogValues),
    builtIns: [
      'Dolby Vision',
      'HDR10+',
      'HDR10',
      'SDR',
    ],
  );

  static const all = <VocabularyDefinition<dynamic>>[
    condition,
    demographic,
    format,
    studio,
    season,
    physicalFormat,
    region,
    packaging,
    distributor,
    hdr,
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

Iterable<String?> _physicalFormatCatalogValues(AnimeMetadata metadata) sync* {
  yield* vocabularyValues([
    metadata.physicalFormatLabel,
    metadata.physicalFormat,
    metadata.editions.map((edition) => edition.physicalFormatLabel),
    metadata.editions.map((edition) => edition.physicalFormat),
  ]);
}

Iterable<String?> _regionCatalogValues(AnimeMetadata metadata) sync* {
  yield* vocabularyValues([
    metadata.country,
    metadata.editions.map((edition) => edition.region),
  ]);
}

Iterable<String?> _packagingCatalogValues(AnimeMetadata metadata) sync* {
  yield* vocabularyValues([
    metadata.editions.map(
      (edition) => _rawText(edition.metadata?['packaging']),
    ),
  ]);
}

Iterable<String?> _distributorCatalogValues(AnimeMetadata metadata) sync* {
  yield* vocabularyValues([
    metadata.publisher,
    metadata.studios,
    metadata.editions.map((edition) => edition.publisher),
  ]);
}

Iterable<String?> _hdrCatalogValues(AnimeMetadata metadata) sync* {
  yield* vocabularyValues([
    metadata.editions.map((edition) =>
        ((edition.metadata?['hdr_formats'] as Iterable?)?.map(_rawText))),
  ]);
}

String? _rawText(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}
