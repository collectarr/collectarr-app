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
  static const genre = VocabularyId<String>('movie.genre');
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
  static Future<List<String>> entryOptions(
      LocalDatabase db, String semanticName) async {
    return [
      for (final item in await MovieEntryRepository(db).listActive())
        ..._entryValues(item, semanticName)
            .whereType<String>()
            .where((value) => value.trim().isNotEmpty)
    ];
  }

  static Future<Map<String, int>> entryUsageCounts(LocalDatabase db, String semanticName) =>
    countPickListEntryUsages(items: MovieEntryRepository(db).listActive(), valuesFrom: (item) => _entryValues(item, semanticName));

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
        personal: item.personal
            .copyWith(details: MovieEntryDetails.fromJson(details)));
  }

  static Iterable<String?> _entryValues(
    MovieLibraryEntry item,
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

  static const genre = VocabularyDefinition<String>(
    id: MovieVocabularyIds.genre,
    label: 'Genre',
    multiValue: true,
    valuesFrom: TypedVocabularyProjector<MovieCatalogMetadata>(_genreValues),
    builtIns: [
      'Action',
      'Adventure',
      'Animation',
      'Biography',
      'Comedy',
      'Crime',
      'Documentary',
      'Drama',
      'Family',
      'Fantasy',
      'History',
      'Horror',
      'Music',
      'Mystery',
      'Romance',
      'Science Fiction',
      'Sport',
      'Thriller',
      'War',
      'Western',
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
    builtIns: [
      'Dolby Vision',
      'HDR10+',
      'HDR10',
      'SDR',
    ],
  );

  static const all = <VocabularyDefinition<dynamic>>[
    condition,
    genre,
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

Iterable<String?> _genreValues(MovieCatalogMetadata metadata) =>
    vocabularyValues([metadata.genres]);

Iterable<String?> _physicalFormatCatalogValues(
  MovieCatalogMetadata metadata,
) sync* {
  yield* vocabularyValues([
    metadata.physicalFormat,
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
