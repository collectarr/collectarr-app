import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:flutter/material.dart';

class AnimeAddManualDraft implements LibraryKindAddDraft {
  AnimeAddManualDraft({
    TextEditingController? nativeTitleController,
    TextEditingController? romajiTitleController,
    TextEditingController? englishTitleController,
    TextEditingController? alternateTitlesController,
    TextEditingController? formatController,
    TextEditingController? seasonController,
    TextEditingController? seasonYearController,
    TextEditingController? episodeCountController,
    TextEditingController? episodeRuntimeController,
    TextEditingController? airingStatusController,
    TextEditingController? sourceMaterialController,
    TextEditingController? startDateController,
    TextEditingController? endDateController,
    TextEditingController? studioController,
    TextEditingController? producersController,
    TextEditingController? licensorsController,
    TextEditingController? themesController,
    TextEditingController? numberController,
    TextEditingController? publisherController,
    TextEditingController? yearController,
    TextEditingController? barcodeController,
    TextEditingController? variantController,
    TextEditingController? physicalFormatLabelController,
    TextEditingController? coverController,
    TextEditingController? backCoverController,
    TextEditingController? creatorsController,
    TextEditingController? charactersController,
    TextEditingController? synopsisController,
    TextEditingController? genresEditController,
    TextEditingController? ageRatingController,
    TextEditingController? languageController,
    TextEditingController? countryController,
    TextEditingController? editionTitleController,
    TextEditingController? releaseDateController,
  })  : nativeTitleController =
            nativeTitleController ?? TextEditingController(),
        romajiTitleController =
            romajiTitleController ?? TextEditingController(),
        englishTitleController =
            englishTitleController ?? TextEditingController(),
        alternateTitlesController =
            alternateTitlesController ?? TextEditingController(),
        formatController = formatController ?? TextEditingController(),
        seasonController = seasonController ?? TextEditingController(),
        seasonYearController = seasonYearController ?? TextEditingController(),
        episodeCountController =
            episodeCountController ?? TextEditingController(),
        episodeRuntimeController =
            episodeRuntimeController ?? TextEditingController(),
        airingStatusController =
            airingStatusController ?? TextEditingController(),
        sourceMaterialController =
            sourceMaterialController ?? TextEditingController(),
        startDateController = startDateController ?? TextEditingController(),
        endDateController = endDateController ?? TextEditingController(),
        studioController = studioController ?? TextEditingController(),
        producersController = producersController ?? TextEditingController(),
        licensorsController = licensorsController ?? TextEditingController(),
        themesController = themesController ?? TextEditingController(),
        numberController = numberController ?? TextEditingController(),
        publisherController = publisherController ?? TextEditingController(),
        yearController = yearController ?? TextEditingController(),
        barcodeController = barcodeController ?? TextEditingController(),
        variantController = variantController ?? TextEditingController(),
        physicalFormatLabelController =
            physicalFormatLabelController ?? TextEditingController(),
        coverController = coverController ?? TextEditingController(),
        backCoverController = backCoverController ?? TextEditingController(),
        creatorsController = creatorsController ?? TextEditingController(),
        charactersController = charactersController ?? TextEditingController(),
        synopsisController = synopsisController ?? TextEditingController(),
        genresEditController = genresEditController ?? TextEditingController(),
        ageRatingController = ageRatingController ?? TextEditingController(),
        languageController = languageController ?? TextEditingController(),
        countryController = countryController ?? TextEditingController(),
        editionTitleController =
            editionTitleController ?? TextEditingController(),
        releaseDateController =
            releaseDateController ?? TextEditingController();

  final TextEditingController nativeTitleController;
  final TextEditingController romajiTitleController;
  final TextEditingController englishTitleController;
  final TextEditingController alternateTitlesController;
  final TextEditingController formatController;
  final TextEditingController seasonController;
  final TextEditingController seasonYearController;
  final TextEditingController episodeCountController;
  final TextEditingController episodeRuntimeController;
  final TextEditingController airingStatusController;
  final TextEditingController sourceMaterialController;
  final TextEditingController startDateController;
  final TextEditingController endDateController;
  final TextEditingController studioController;
  final TextEditingController producersController;
  final TextEditingController licensorsController;
  final TextEditingController themesController;
  final TextEditingController numberController;
  final TextEditingController publisherController;
  final TextEditingController yearController;
  final TextEditingController barcodeController;
  final TextEditingController variantController;
  final TextEditingController physicalFormatLabelController;
  final TextEditingController coverController;
  final TextEditingController backCoverController;
  final TextEditingController creatorsController;
  final TextEditingController charactersController;
  final TextEditingController synopsisController;
  final TextEditingController genresEditController;
  final TextEditingController ageRatingController;
  final TextEditingController languageController;
  final TextEditingController countryController;
  final TextEditingController editionTitleController;
  final TextEditingController releaseDateController;

  @override
  void dispose() {
    nativeTitleController.dispose();
    romajiTitleController.dispose();
    englishTitleController.dispose();
    alternateTitlesController.dispose();
    formatController.dispose();
    seasonController.dispose();
    seasonYearController.dispose();
    episodeCountController.dispose();
    episodeRuntimeController.dispose();
    airingStatusController.dispose();
    sourceMaterialController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    studioController.dispose();
    producersController.dispose();
    licensorsController.dispose();
    themesController.dispose();
    numberController.dispose();
    publisherController.dispose();
    yearController.dispose();
    barcodeController.dispose();
    variantController.dispose();
    physicalFormatLabelController.dispose();
    coverController.dispose();
    backCoverController.dispose();
    creatorsController.dispose();
    charactersController.dispose();
    synopsisController.dispose();
    genresEditController.dispose();
    ageRatingController.dispose();
    languageController.dispose();
    countryController.dispose();
    editionTitleController.dispose();
    releaseDateController.dispose();
  }
}
