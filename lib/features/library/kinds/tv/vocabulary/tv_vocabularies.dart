import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_entry_repository.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_definition.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_id.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_definition_contributor.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/tv/entries/tv_entry_details.dart';

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
  static Future<List<String>> entryOptions(
      LocalDatabase db, String semanticName) async {
    return [
      for (final item in await TvEntryRepository(db).listActive())
        ..._entryValues(item, semanticName)
            .whereType<String>()
            .where((value) => value.trim().isNotEmpty)
    ];
  }

  static Future<Map<String, int>> entryUsageCounts(LocalDatabase db, String semanticName) =>
    countPickListEntryUsages(items: TvEntryRepository(db).listActive(), valuesFrom: (item) => _entryValues(item, semanticName));

  static Future<PickListEntryMergeResult> previewEntryMerge(
    LocalDatabase db,
    String semanticName,
    Set<String> normalizedSourceValues,
  ) {
    return previewPickListEntryMerge(
      items: TvEntryRepository(db).listActive(),
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
      items: TvEntryRepository(db).listActive(),
      valuesFrom: (item) => _entryValues(item, semanticName),
      replaceValue: (item, sources, target) =>
          _replaceEntryValue(item, semanticName, sources, target),
      save: TvEntryRepository(db).upsert,
      normalizedSourceValues: normalizedSourceValues,
      targetValue: targetValue,
    );
  }

  static TvLibraryEntry _replaceEntryValue(
    TvLibraryEntry item,
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
          tags: replacePickListDelimitedValue(
            item.personal.tags,
            normalizedSourceValues,
            targetValue,
          ),
        ));
    }
    final key = switch (semanticName) {
      'features' => 'features',
      'region' => 'region',
      'packaging' => 'packaging',
      'distributor' => 'distributor',
      _ => null,
    };
    if (key == null) return item;
    final details = item.personal.details.toJson()..[key] = targetValue;
    return item.copyWith(
        personal:
            item.personal.copyWith(details: TvEntryDetails.fromJson(details)));
  }

  static Iterable<String?> _entryValues(
    TvLibraryEntry item,
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
      yield* item.personal.tags?.split(',') ?? const <String>[];
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
      yield* pickListTextValues(item.personal.details.toJson()[key]);
    }
    for (final vocabulary in all) {
      if (vocabulary.key.split('.').last == semanticName) {
        yield* vocabulary.valuesFrom?.call(item.metadata) ?? const <String>[];
      }
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
    valuesFrom: TypedVocabularyProjector<TvMetadata>(
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
    valuesFrom: TypedVocabularyProjector<TvMetadata>(_regionCatalogValues),
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
    valuesFrom: TypedVocabularyProjector<TvMetadata>(
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
    valuesFrom: TypedVocabularyProjector<TvMetadata>(
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
    valuesFrom: TypedVocabularyProjector<TvMetadata>(
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
    valuesFrom: TypedVocabularyProjector<TvMetadata>(_audioCatalogValues),
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
    valuesFrom: TypedVocabularyProjector<TvMetadata>(
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
    valuesFrom: TypedVocabularyProjector<TvMetadata>(_networkCatalogValues),
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
  TvMetadata metadata,
) sync* {
  yield* vocabularyValues([
    metadata.physicalFormatLabel,
    metadata.physicalFormat,
    metadata.media.map((media) => media.mediaType),
  ]);
}

Iterable<String?> _regionCatalogValues(TvMetadata metadata) {
  return vocabularyValues([
    metadata.region,
    metadata.media.map((media) => media.regionCode),
  ]);
}

Iterable<String?> _packagingCatalogValues(TvMetadata metadata) {
  return vocabularyValues([metadata.packaging]);
}

Iterable<String?> _distributorCatalogValues(TvMetadata metadata) {
  return vocabularyValues([metadata.distributor]);
}

Iterable<String?> _screenRatioCatalogValues(TvMetadata metadata) {
  return vocabularyValues([
    metadata.screenRatio,
    metadata.media.map((media) => media.aspectRatio),
  ]);
}

Iterable<String?> _audioCatalogValues(TvMetadata metadata) {
  return vocabularyValues([
    metadata.audioTracks,
    metadata.media.map((media) => media.audioTracks),
  ]);
}

Iterable<String?> _subtitlesCatalogValues(TvMetadata metadata) {
  return vocabularyValues([
    metadata.subtitles,
    metadata.media.map((media) => media.subtitles),
  ]);
}

Iterable<String?> _networkCatalogValues(TvMetadata metadata) {
  return vocabularyValues([metadata.network]);
}
