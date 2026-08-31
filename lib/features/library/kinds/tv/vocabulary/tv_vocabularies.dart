import 'package:collectarr_app/features/collection/vocabulary/vocabulary_definition.dart';
import 'package:collectarr_app/features/collection/vocabulary/vocabulary_id.dart';

abstract final class TvVocabularyIds {
  static const physicalFormat = VocabularyId<String>('tv.physical_format');
  static const region = VocabularyId<String>('tv.region');
  static const packaging = VocabularyId<String>('tv.packaging');
  static const distributor = VocabularyId<String>('tv.distributor');
  static const screenRatio = VocabularyId<String>('tv.screen_ratio');
  static const audio = VocabularyId<String>('tv.audio');
  static const subtitles = VocabularyId<String>('tv.subtitles');
  static const network = VocabularyId<String>('tv.network');
}

abstract final class TvVocabularies {
  static const physicalFormat = VocabularyDefinition<String>(
    id: TvVocabularyIds.physicalFormat,
    label: 'Format',
    builtIns: [
      '4K Ultra HD Blu-ray',
      'Blu-ray',
      'DVD',
      'Digital',
    ],
  );

  static const region = VocabularyDefinition<String>(
    id: TvVocabularyIds.region,
    label: 'Region',
    builtIns: [
      'Region A / Region 1',
      'Region B / Region 2',
      'Region C / Region 3',
      'Region Free',
    ],
  );

  static const packaging = VocabularyDefinition<String>(
    id: TvVocabularyIds.packaging,
    label: 'Packaging',
    builtIns: [
      'Complete Series Box Set',
      'Season Box Set',
      'Multi-Disc Keep Case',
      'Steelbook Season',
      'Digipak',
      'Slipcover',
    ],
  );

  static const distributor = VocabularyDefinition<String>(
    id: TvVocabularyIds.distributor,
    label: 'Distributor / Studio',
    builtIns: [
      'HBO Home Entertainment',
      'Warner Bros. Television',
      'Sony Pictures Television',
      'BBC Studios',
      'Universal Television',
      'Paramount Television',
      'Disney Television Studios',
    ],
  );

  static const screenRatio = VocabularyDefinition<String>(
    id: TvVocabularyIds.screenRatio,
    label: 'Screen Ratio',
    builtIns: [
      '1.78:1 (16:9)',
      '1.33:1 (4:3 Fullscreen)',
      '2.00:1 (Univisium)',
      '2.39:1 (Widescreen)',
    ],
  );

  static const audio = VocabularyDefinition<String>(
    id: TvVocabularyIds.audio,
    label: 'Audio',
    builtIns: [
      'Dolby Atmos',
      'DTS-HD Master Audio 5.1',
      'Dolby Digital 5.1',
      'Dolby Digital 2.0 Stereo',
      'Original Broadcast Audio',
    ],
  );

  static const subtitles = VocabularyDefinition<String>(
    id: TvVocabularyIds.subtitles,
    label: 'Subtitles',
    builtIns: [
      'English SDH',
      'Spanish',
      'French',
      'German',
      'Japanese',
    ],
  );

  static const network = VocabularyDefinition<String>(
    id: TvVocabularyIds.network,
    label: 'Original Network',
    builtIns: [
      'HBO',
      'Netflix',
      'AMC',
      'BBC One',
      'FX',
      'Showtime',
      'Apple TV+',
      'Amazon Prime Video',
      'Disney+',
      'Hulu',
      'NBC',
      'CBS',
      'ABC',
      'FOX',
      'The CW',
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
    network,
  ];
}
