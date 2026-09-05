import 'package:collectarr_app/features/pick_lists/models/vocabulary_definition.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_id.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';

abstract final class MovieVocabularyIds {
  static const physicalFormat = VocabularyId<String>('movie.physical_format');
  static const region = VocabularyId<String>('movie.region');
  static const packaging = VocabularyId<String>('movie.packaging');
  static const distributor = VocabularyId<String>('movie.distributor');
  static const screenRatio = VocabularyId<String>('movie.screen_ratio');
  static const audio = VocabularyId<String>('movie.audio');
  static const subtitles = VocabularyId<String>('movie.subtitles');
  static const hdr = VocabularyId<String>('movie.hdr');
}

abstract final class MovieVocabularies {
  static const physicalFormat = VocabularyDefinition<String>(
    id: MovieVocabularyIds.physicalFormat,
    label: 'Format',
    valuesFrom: TypedVocabularyProjector<MovieCatalogMetadata>(
      _physicalFormatCatalogValues,
    ),
    builtIns: [
      '4K Ultra HD Blu-ray',
      'Blu-ray 3D',
      'Blu-ray',
      'DVD',
      'LaserDisc',
      'VHS',
      'Digital',
    ],
  );

  static const region = VocabularyDefinition<String>(
    id: MovieVocabularyIds.region,
    label: 'Region',
    valuesFrom:
        TypedVocabularyProjector<MovieCatalogMetadata>(_regionCatalogValues),
    builtIns: [
      'Region A / Region 1',
      'Region B / Region 2',
      'Region C / Region 3',
      'Region Free (All Regions)',
    ],
  );

  static const packaging = VocabularyDefinition<String>(
    id: MovieVocabularyIds.packaging,
    label: 'Packaging',
    valuesFrom: TypedVocabularyProjector<MovieCatalogMetadata>(
      _packagingCatalogValues,
    ),
    builtIns: [
      'Standard Keep Case',
      'Steelbook',
      'Digibook',
      'Slipcover',
      'Slipbox / Hardbox',
      'Box Set',
      "Collector's Edition Box",
      'Digipak',
      'Custom Mediabook',
    ],
  );

  static const distributor = VocabularyDefinition<String>(
    id: MovieVocabularyIds.distributor,
    label: 'Distributor / Boutique Label',
    valuesFrom: TypedVocabularyProjector<MovieCatalogMetadata>(
      _distributorCatalogValues,
    ),
    builtIns: [
      'Criterion Collection',
      'Arrow Video',
      'Shout! Factory / Scream Factory',
      'Kino Lorber',
      'Eureka Entertainment (Masters of Cinema)',
      'BFI',
      'Vinegar Syndrome',
      'Second Sight Films',
      'Warner Bros. Home Entertainment',
      'Universal Pictures Home Entertainment',
      'Sony Pictures Home Entertainment',
      'Walt Disney Studios Home Entertainment',
      'Paramount Home Media Distribution',
      'Lionsgate Home Entertainment',
      'A24',
    ],
  );

  static const screenRatio = VocabularyDefinition<String>(
    id: MovieVocabularyIds.screenRatio,
    label: 'Screen Ratio',
    valuesFrom: TypedVocabularyProjector<MovieCatalogMetadata>(
      _screenRatioCatalogValues,
    ),
    builtIns: [
      '1.78:1 (16:9 Widescreen)',
      '1.85:1 (Theatrical Widescreen)',
      '2.39:1 (Anamorphic Panavision)',
      '2.35:1 (Widescreen)',
      '1.33:1 (4:3 Academy / Fullscreen)',
      '1.66:1 (European Widescreen)',
      '1.43:1 (IMAX Full Frame)',
    ],
  );

  static const audio = VocabularyDefinition<String>(
    id: MovieVocabularyIds.audio,
    label: 'Audio Tracks',
    valuesFrom:
        TypedVocabularyProjector<MovieCatalogMetadata>(_audioCatalogValues),
    builtIns: [
      'Dolby Atmos',
      'DTS:X',
      'DTS-HD Master Audio 7.1',
      'DTS-HD Master Audio 5.1',
      'Dolby TrueHD 7.1',
      'Dolby TrueHD 5.1',
      'Dolby Digital 5.1 (AC-3)',
      'LPCM 2.0 Uncompressed',
      'DTS-HD Master Audio 2.0 Mono',
      'Original Mono',
    ],
  );

  static const subtitles = VocabularyDefinition<String>(
    id: MovieVocabularyIds.subtitles,
    label: 'Subtitles',
    valuesFrom: TypedVocabularyProjector<MovieCatalogMetadata>(
      _subtitlesCatalogValues,
    ),
    builtIns: [
      'English SDH',
      'English',
      'Spanish',
      'French',
      'German',
      'Japanese',
      'Italian',
      'Portuguese',
      'Dutch',
      'Korean',
      'Chinese (Mandarin)',
      'Chinese (Cantonese)',
    ],
  );

  static const hdr = VocabularyDefinition<String>(
    id: MovieVocabularyIds.hdr,
    label: 'HDR / Video Format',
    valuesFrom:
        TypedVocabularyProjector<MovieCatalogMetadata>(_hdrCatalogValues),
    builtIns: [
      'Dolby Vision',
      'HDR10+',
      'HDR10',
      'SDR',
    ],
  );

  static const all = <VocabularyDefinition<dynamic>>[
    physicalFormat,
    region,
    packaging,
    distributor,
    screenRatio,
    audio,
    subtitles,
    hdr,
  ];
}

Iterable<String?> _physicalFormatCatalogValues(
  MovieCatalogMetadata metadata,
) sync* {
  yield* vocabularyValues([
    metadata.physicalFormatLabel,
    metadata.physicalFormat,
    metadata.releases.map((release) => release.physicalFormat),
  ]);
}

Iterable<String?> _regionCatalogValues(MovieCatalogMetadata metadata) {
  return vocabularyValues([
    metadata.region,
    metadata.releases.map((release) => release.region),
  ]);
}

Iterable<String?> _packagingCatalogValues(MovieCatalogMetadata metadata) {
  return vocabularyValues([
    metadata.packaging,
    metadata.releases.map((release) => release.packaging),
  ]);
}

Iterable<String?> _distributorCatalogValues(MovieCatalogMetadata metadata) {
  return vocabularyValues([
    metadata.distributor,
    metadata.releases.map((release) => release.distributor),
  ]);
}

Iterable<String?> _screenRatioCatalogValues(MovieCatalogMetadata metadata) {
  return vocabularyValues([
    metadata.screenRatio,
    metadata.releases.map((release) => release.screenRatio),
  ]);
}

Iterable<String?> _audioCatalogValues(MovieCatalogMetadata metadata) {
  return vocabularyValues([
    metadata.audioTracks,
    metadata.releases.expand((release) => release.audioTracks),
  ]);
}

Iterable<String?> _subtitlesCatalogValues(MovieCatalogMetadata metadata) {
  return vocabularyValues([
    metadata.subtitles,
    metadata.releases.expand((release) => release.subtitles),
  ]);
}

Iterable<String?> _hdrCatalogValues(MovieCatalogMetadata metadata) {
  return vocabularyValues([
    metadata.hdr,
    metadata.releases.expand((release) => release.hdrFormats),
  ]);
}
