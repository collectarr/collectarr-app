import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_entry_repository.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_definition.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_id.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_definition_contributor.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/movie/entries/movie_entry_details.dart';

abstract final class MovieVocabularyIds {
  static const condition = VocabularyId<String>('movie.condition');
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
  static Future<int> countEntryValue(
    LocalDatabase db,
    String semanticName,
    String normalizedValue,
  ) {
    return countPickListEntryValues(
      items: MovieEntryRepository(db).listActive(),
      normalizedValue: normalizedValue,
      valuesFrom: (item) => _entryValues(item, semanticName),
    );
  }

  static Future<PickListEntryMergeResult> previewEntryMerge(
    LocalDatabase db,
    String semanticName,
    Set<String> normalizedSourceValues,
  ) {
    return previewPickListEntryMerge(
      items: MovieEntryRepository(db).listActive(),
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
      items: MovieEntryRepository(db).listActive(),
      valuesFrom: (item) => _entryValues(item, semanticName),
      replaceValue: (item, sources, target) =>
          _replaceEntryValue(item, semanticName, sources, target),
      save: MovieEntryRepository(db).upsert,
      normalizedSourceValues: normalizedSourceValues,
      targetValue: targetValue,
    );
  }

  static MovieLibraryEntry _replaceEntryValue(
    MovieLibraryEntry item,
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
    final key = switch (semanticName) {
      'features' => 'features',
      'region' => 'region',
      'packaging' => 'packaging',
      'distributor' => 'distributor',
      _ => null,
    };
    if (key == null) return item;
    final details = item.details.toJson()..[key] = targetValue;
    return item.copyWith(details: MovieEntryDetails.fromJson(details));
  }

  static Iterable<String?> _entryValues(
    MovieLibraryEntry item,
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
    id: MovieVocabularyIds.condition,
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
    condition,
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
  ]);
}

Iterable<String?> _regionCatalogValues(MovieCatalogMetadata metadata) {
  return vocabularyValues([
    metadata.region,
  ]);
}

Iterable<String?> _packagingCatalogValues(MovieCatalogMetadata metadata) {
  return vocabularyValues([
    metadata.packaging,
  ]);
}

Iterable<String?> _distributorCatalogValues(MovieCatalogMetadata metadata) {
  return vocabularyValues([
    metadata.distributor,
  ]);
}

Iterable<String?> _screenRatioCatalogValues(MovieCatalogMetadata metadata) {
  return vocabularyValues([
    metadata.screenRatio,
  ]);
}

Iterable<String?> _audioCatalogValues(MovieCatalogMetadata metadata) {
  return vocabularyValues([
    metadata.audioTracks,
  ]);
}

Iterable<String?> _subtitlesCatalogValues(MovieCatalogMetadata metadata) {
  return vocabularyValues([
    metadata.subtitles,
  ]);
}

Iterable<String?> _hdrCatalogValues(MovieCatalogMetadata metadata) {
  return vocabularyValues([
    metadata.hdr,
  ]);
}
