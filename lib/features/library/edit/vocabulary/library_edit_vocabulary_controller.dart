import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/features/collection/pick_list/pick_list_options.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/series/series_registry_repository.dart';
import 'package:drift/drift.dart' show QueryRow;

class LibraryEditVocabularyRequest {
  const LibraryEditVocabularyRequest({
    required this.db,
    required this.mediaKind,
    required this.selectedPublisher,
    required this.selectedImprint,
    required this.selectedSeriesGroup,
    required this.selectedPhysicalFormat,
    required this.selectedCondition,
    required this.selectedGrade,
    required this.selectedCountry,
    required this.selectedLanguage,
    required this.selectedAgeRating,
    required this.selectedAudienceRating,
    required this.selectedRegion,
    required this.selectedPackaging,
    required this.selectedDistributor,
    required this.selectedScreenRatio,
    required this.selectedAudioTracks,
    required this.selectedSubtitles,
    required this.selectedLayers,
    required this.selectedColor,
    required this.selectedGamePlatforms,
    required this.selectedCrossover,
    required this.selectedStoryArc,
    required this.selectedPageQuality,
    required this.selectedKeyCategory,
    required this.selectedGenreValues,
    required this.selectedTagValues,
    required this.selectedSeriesTitle,
    required this.selectedSeriesId,
    required this.builtInPhysicalFormats,
  });

  final LocalDatabase db;
  final String mediaKind;
  final String? selectedPublisher;
  final String? selectedImprint;
  final String? selectedSeriesGroup;
  final String? selectedPhysicalFormat;
  final String? selectedCondition;
  final String? selectedGrade;
  final String? selectedCountry;
  final String? selectedLanguage;
  final String? selectedAgeRating;
  final String? selectedAudienceRating;
  final String? selectedRegion;
  final String? selectedPackaging;
  final String? selectedDistributor;
  final String? selectedScreenRatio;
  final String? selectedAudioTracks;
  final String? selectedSubtitles;
  final String? selectedLayers;
  final String? selectedColor;
  final String? selectedGamePlatforms;
  final String? selectedCrossover;
  final String? selectedStoryArc;
  final String? selectedPageQuality;
  final String? selectedKeyCategory;
  final String? selectedGenreValues;
  final String? selectedTagValues;
  final String? selectedSeriesTitle;
  final String? selectedSeriesId;
  final List<PhysicalMediaFormat> builtInPhysicalFormats;
}

class LibraryEditVocabularyOptions {
  const LibraryEditVocabularyOptions({
    required this.publisherOptions,
    required this.imprintOptions,
    required this.seriesGroupOptions,
    required this.physicalFormatOptions,
    required this.conditionOptions,
    required this.gradeOptions,
    required this.countryOptions,
    required this.languageOptions,
    required this.ageRatingOptions,
    required this.audienceRatingOptions,
    required this.regionOptions,
    required this.packagingOptions,
    required this.distributorOptions,
    required this.screenRatioOptions,
    required this.audioTrackOptions,
    required this.subtitleOptions,
    required this.layersOptions,
    required this.colorOptions,
    required this.gamePlatformOptions,
    required this.crossoverOptions,
    required this.storyArcOptions,
    required this.pageQualityOptions,
    required this.keyCategoryOptions,
    required this.ownerOptions,
    required this.seriesEntries,
    required this.genreOptions,
    required this.tagOptions,
  });

  final List<String> publisherOptions;
  final List<String> imprintOptions;
  final List<String> seriesGroupOptions;
  final List<String> physicalFormatOptions;
  final List<String> conditionOptions;
  final List<String> gradeOptions;
  final List<String> countryOptions;
  final List<String> languageOptions;
  final List<String> ageRatingOptions;
  final List<String> audienceRatingOptions;
  final List<String> regionOptions;
  final List<String> packagingOptions;
  final List<String> distributorOptions;
  final List<String> screenRatioOptions;
  final List<String> audioTrackOptions;
  final List<String> subtitleOptions;
  final List<String> layersOptions;
  final List<String> colorOptions;
  final List<String> gamePlatformOptions;
  final List<String> crossoverOptions;
  final List<String> storyArcOptions;
  final List<String> pageQualityOptions;
  final List<String> keyCategoryOptions;
  final List<String> ownerOptions;
  final List<SeriesRegistryEntry> seriesEntries;
  final List<String> genreOptions;
  final List<String> tagOptions;
}

class LibraryEditVocabularyController {
  const LibraryEditVocabularyController();

  Future<List<StorageLocation>> loadAvailableLocations(LocalDatabase db) {
    return LocationRepository(db).getAll();
  }

  Future<LibraryEditVocabularyOptions> loadVocabularyOptions(
    LibraryEditVocabularyRequest request,
  ) async {
    final seriesRegistry = SeriesRegistryRepository(request.db);
    final results = await Future.wait<dynamic>([
      loadSingleValuePickListOptions(
        request.db,
        listName: kPublisherPickListName,
        mediaKind: request.mediaKind,
        selectedValue: request.selectedPublisher,
      ),
      loadSingleValuePickListOptions(
        request.db,
        listName: kImprintPickListName,
        mediaKind: request.mediaKind,
        selectedValue: request.selectedImprint,
      ),
      loadSingleValuePickListOptions(
        request.db,
        listName: kSeriesGroupPickListName,
        mediaKind: request.mediaKind,
        selectedValue: request.selectedSeriesGroup,
      ),
      loadSingleValuePickListOptions(
        request.db,
        listName: kPhysicalFormatPickListName,
        mediaKind: request.mediaKind,
        builtInValues: [
          for (final format in request.builtInPhysicalFormats) format.label
        ],
        selectedValue: request.selectedPhysicalFormat,
      ),
      loadConditionGradePickListOptions(
        request.db,
        mediaKind: request.mediaKind,
        builtInConditions: const ['Near Mint', 'Very Fine', 'Fine', 'Good'],
        builtInGrades: const ['9.8', '9.6', '9.4', '9.2', '9.0', '8.5'],
        selectedCondition: request.selectedCondition,
        selectedGrade: request.selectedGrade,
      ),
      loadSingleValuePickListOptions(
        request.db,
        listName: kCountryPickListName,
        mediaKind: request.mediaKind,
        selectedValue: request.selectedCountry,
      ),
      loadSingleValuePickListOptions(
        request.db,
        listName: kLanguagePickListName,
        mediaKind: request.mediaKind,
        selectedValue: request.selectedLanguage,
      ),
      loadSingleValuePickListOptions(
        request.db,
        listName: kAgeRatingPickListName,
        mediaKind: request.mediaKind,
        selectedValue: request.selectedAgeRating,
      ),
      loadSingleValuePickListOptions(
        request.db,
        listName: kAudienceRatingPickListName,
        mediaKind: request.mediaKind,
        selectedValue: request.selectedAudienceRating,
      ),
      loadSingleValuePickListOptions(
        request.db,
        listName: kRegionPickListName,
        mediaKind: request.mediaKind,
        selectedValue: request.selectedRegion,
      ),
      loadSingleValuePickListOptions(
        request.db,
        listName: kPackagingPickListName,
        mediaKind: request.mediaKind,
        selectedValue: request.selectedPackaging,
      ),
      loadSingleValuePickListOptions(
        request.db,
        listName: kDistributorPickListName,
        mediaKind: request.mediaKind,
        selectedValue: request.selectedDistributor,
      ),
      loadSingleValuePickListOptions(
        request.db,
        listName: kScreenRatioPickListName,
        mediaKind: request.mediaKind,
        selectedValue: request.selectedScreenRatio,
      ),
      loadMultiValuePickListOptions(
        request.db,
        listName: kAudioTrackPickListName,
        mediaKind: request.mediaKind,
        selectedValues: splitPickListValues(request.selectedAudioTracks),
      ),
      loadMultiValuePickListOptions(
        request.db,
        listName: kSubtitlePickListName,
        mediaKind: request.mediaKind,
        selectedValues: splitPickListValues(request.selectedSubtitles),
      ),
      loadSingleValuePickListOptions(
        request.db,
        listName: kLayersPickListName,
        mediaKind: request.mediaKind,
        selectedValue: request.selectedLayers,
      ),
      loadSingleValuePickListOptions(
        request.db,
        listName: kColorPickListName,
        mediaKind: request.mediaKind,
        selectedValue: request.selectedColor,
      ),
      loadMultiValuePickListOptions(
        request.db,
        listName: kGamePlatformPickListName,
        mediaKind: request.mediaKind,
        selectedValues: splitPickListValues(request.selectedGamePlatforms),
      ),
      loadSingleValuePickListOptions(
        request.db,
        listName: kCrossoverPickListName,
        mediaKind: request.mediaKind,
        selectedValue: request.selectedCrossover,
      ),
      loadSingleValuePickListOptions(
        request.db,
        listName: kStoryArcPickListName,
        mediaKind: request.mediaKind,
        selectedValue: request.selectedStoryArc,
      ),
      loadSingleValuePickListOptions(
        request.db,
        listName: kPageQualityPickListName,
        mediaKind: request.mediaKind,
        builtInValues: const [
          'White',
          'Off-White to White',
          'Cream to Off-White',
          'Brittle',
        ],
        selectedValue: request.selectedPageQuality,
      ),
      loadSingleValuePickListOptions(
        request.db,
        listName: kKeyCategoryPickListName,
        mediaKind: request.mediaKind,
        builtInValues: const [
          'First appearance',
          'First issue',
          'Origin',
          'Death',
          'Cameo',
          'Classic cover',
        ],
        selectedValue: request.selectedKeyCategory,
      ),
      request.db.customSelect(
        '''
SELECT DISTINCT owner_label
FROM owned_items_cache
WHERE owner_label IS NOT NULL
  AND TRIM(owner_label) <> ''
ORDER BY owner_label COLLATE NOCASE
''',
      ).get(),
      seriesRegistry.searchEntries(
        mediaKind: request.mediaKind,
        selectedTitle: request.selectedSeriesTitle,
        selectedSeriesId: request.selectedSeriesId,
      ),
      loadMultiValuePickListOptions(
        request.db,
        listName: kGenrePickListName,
        mediaKind: request.mediaKind,
        selectedValues: splitPickListValues(request.selectedGenreValues),
      ),
      loadTagPickListOptions(
        request.db,
        mediaKind: request.mediaKind,
        selectedTags: splitPickListValues(request.selectedTagValues),
      ),
    ]);

    return LibraryEditVocabularyOptions(
      publisherOptions: List<String>.from(results[0] as List<String>),
      imprintOptions: List<String>.from(results[1] as List<String>),
      seriesGroupOptions: List<String>.from(results[2] as List<String>),
      physicalFormatOptions: List<String>.from(results[3] as List<String>),
      conditionOptions:
          (results[4] as PickListConditionGradeOptions).conditions,
      gradeOptions: (results[4] as PickListConditionGradeOptions).grades,
      countryOptions: List<String>.from(results[5] as List<String>),
      languageOptions: List<String>.from(results[6] as List<String>),
      ageRatingOptions: List<String>.from(results[7] as List<String>),
      audienceRatingOptions: List<String>.from(results[8] as List<String>),
      regionOptions: List<String>.from(results[9] as List<String>),
      packagingOptions: List<String>.from(results[10] as List<String>),
      distributorOptions: List<String>.from(results[11] as List<String>),
      screenRatioOptions: List<String>.from(results[12] as List<String>),
      audioTrackOptions: List<String>.from(results[13] as List<String>),
      subtitleOptions: List<String>.from(results[14] as List<String>),
      layersOptions: List<String>.from(results[15] as List<String>),
      colorOptions: List<String>.from(results[16] as List<String>),
      gamePlatformOptions: List<String>.from(results[17] as List<String>),
      crossoverOptions: List<String>.from(results[18] as List<String>),
      storyArcOptions: List<String>.from(results[19] as List<String>),
      pageQualityOptions: List<String>.from(results[20] as List<String>),
      keyCategoryOptions: List<String>.from(results[21] as List<String>),
      ownerOptions: [
        for (final row in (results[22] as List<QueryRow>))
          row.read<String>('owner_label'),
      ],
      seriesEntries: List<SeriesRegistryEntry>.from(
        results[23] as List<SeriesRegistryEntry>,
      ),
      genreOptions: List<String>.from(results[24] as List<String>),
      tagOptions: List<String>.from(results[25] as List<String>),
    );
  }
}
