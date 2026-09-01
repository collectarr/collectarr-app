import 'package:collectarr_app/features/collection/vocabulary/vocabulary_definition.dart';
import 'package:collectarr_app/features/collection/vocabulary/vocabulary_id.dart';

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
    catalogValueReader: _physicalFormatCatalogValues,
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
    catalogValueReader: _regionCatalogValues,
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
    catalogValueReader: _packagingCatalogValues,
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
    catalogValueReader: _distributorCatalogValues,
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
    catalogValueReader: _screenRatioCatalogValues,
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
    catalogValueReader: _audioCatalogValues,
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
    catalogValueReader: _subtitlesCatalogValues,
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
    catalogValueReader: _hdrCatalogValues,
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
  Map<String, dynamic> payload,
) sync* {
  yield* vocabularyPayloadValuesForKey(payload, 'physical_format_label');
  yield* vocabularyPayloadValuesForKey(payload, 'physical_format');
}

Iterable<String?> _regionCatalogValues(Map<String, dynamic> payload) sync* {
  yield* vocabularyPayloadValuesForKey(payload, 'region');
  yield* vocabularyNestedPayloadValuesForKey(payload, 'video', 'region');
}

Iterable<String?> _packagingCatalogValues(Map<String, dynamic> payload) sync* {
  yield* vocabularyPayloadValuesForKey(payload, 'packaging');
  yield* vocabularyNestedPayloadValuesForKey(payload, 'video', 'packaging');
}

Iterable<String?> _distributorCatalogValues(
  Map<String, dynamic> payload,
) sync* {
  yield* vocabularyPayloadValuesForKey(payload, 'distributor');
  yield* vocabularyNestedPayloadValuesForKey(payload, 'video', 'distributor');
}

Iterable<String?> _screenRatioCatalogValues(
  Map<String, dynamic> payload,
) {
  return vocabularyNestedPayloadValuesForKey(payload, 'video', 'screen_ratio');
}

Iterable<String?> _audioCatalogValues(Map<String, dynamic> payload) {
  return vocabularyNestedPayloadValuesForKey(payload, 'video', 'audio_tracks');
}

Iterable<String?> _subtitlesCatalogValues(Map<String, dynamic> payload) {
  return vocabularyNestedPayloadValuesForKey(payload, 'video', 'subtitles');
}

Iterable<String?> _hdrCatalogValues(Map<String, dynamic> payload) {
  return vocabularyPayloadValuesForKey(payload, 'hdr');
}
