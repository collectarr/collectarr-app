import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_owned_repository.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_definition.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_id.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_definition_contributor.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_owned_item.dart';

abstract final class TvVocabularyIds {
  static const condition = VocabularyId<String>('tv.condition');
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
  static Future<int> countOwnedValue(
    LocalDatabase db,
    String semanticName,
    String normalizedValue,
  ) {
    return countPickListOwnedValues(
      items: TvOwnedRepository(db).listActive(),
      normalizedValue: normalizedValue,
      valuesFrom: (item) => _ownedValues(item, semanticName),
    );
  }

  static Iterable<String?> _ownedValues(
    TvOwnedItem item,
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
      'features' => 'features',
      'region' => 'region',
      'packaging' => 'packaging',
      'distributor' => 'distributor',
      _ => null,
    };
    if (key != null) {
      yield* pickListTextValues(item.details.toJson()[key]);
    }
  }

  static const condition = VocabularyDefinition<String>(
    id: TvVocabularyIds.condition,
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

  static const physicalFormat = VocabularyDefinition<String>(
    id: TvVocabularyIds.physicalFormat,
    label: 'Format',
    valuesFrom: TypedVocabularyProjector<TvSeriesMetadata>(
      _physicalFormatCatalogValues,
    ),
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
    valuesFrom:
        TypedVocabularyProjector<TvSeriesMetadata>(_regionCatalogValues),
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
    valuesFrom: TypedVocabularyProjector<TvSeriesMetadata>(
      _packagingCatalogValues,
    ),
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
    valuesFrom: TypedVocabularyProjector<TvSeriesMetadata>(
      _distributorCatalogValues,
    ),
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
    valuesFrom: TypedVocabularyProjector<TvSeriesMetadata>(
      _screenRatioCatalogValues,
    ),
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
    valuesFrom: TypedVocabularyProjector<TvSeriesMetadata>(_audioCatalogValues),
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
    valuesFrom: TypedVocabularyProjector<TvSeriesMetadata>(
      _subtitlesCatalogValues,
    ),
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
    valuesFrom:
        TypedVocabularyProjector<TvSeriesMetadata>(_networkCatalogValues),
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
    condition,
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

Iterable<String?> _physicalFormatCatalogValues(
  TvSeriesMetadata metadata,
) sync* {
  yield* vocabularyValues([
    metadata.physicalFormatLabel,
    metadata.physicalFormat,
  ]);
}

Iterable<String?> _regionCatalogValues(TvSeriesMetadata metadata) {
  return vocabularyValues([
    metadata.region,
    metadata.releases.map((release) => release.region),
  ]);
}

Iterable<String?> _packagingCatalogValues(TvSeriesMetadata metadata) {
  return vocabularyValues([
    metadata.packaging,
    metadata.releases.map((release) => release.packaging),
  ]);
}

Iterable<String?> _distributorCatalogValues(TvSeriesMetadata metadata) {
  return vocabularyValues([metadata.distributor]);
}

Iterable<String?> _screenRatioCatalogValues(TvSeriesMetadata metadata) {
  return vocabularyValues([metadata.screenRatio]);
}

Iterable<String?> _audioCatalogValues(TvSeriesMetadata metadata) {
  return vocabularyValues([
    metadata.audioTracks,
    metadata.releases.expand((release) => release.audioTracks),
  ]);
}

Iterable<String?> _subtitlesCatalogValues(TvSeriesMetadata metadata) {
  return vocabularyValues([
    metadata.subtitles,
    metadata.releases.expand((release) => release.subtitles),
  ]);
}

Iterable<String?> _networkCatalogValues(TvSeriesMetadata metadata) {
  return vocabularyValues([metadata.network]);
}
