import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:flutter/material.dart';

class MangaAddManualDraft implements LibraryKindAddDraft {
  MangaAddManualDraft({
    TextEditingController? numberController,
    TextEditingController? publisherController,
    TextEditingController? yearController,
    TextEditingController? barcodeController,
    TextEditingController? variantController,
    TextEditingController? physicalFormatLabelController,
    TextEditingController? coverController,
    TextEditingController? backCoverController,
    TextEditingController? imprintController,
    TextEditingController? seriesGroupController,
    TextEditingController? pageCountController,
    TextEditingController? creatorsController,
    TextEditingController? charactersController,
    TextEditingController? synopsisController,
    TextEditingController? genresEditController,
    TextEditingController? ageRatingController,
    TextEditingController? languageController,
    TextEditingController? countryController,
    TextEditingController? editionTitleController,
    TextEditingController? releaseDateController,
    TextEditingController? rawOrSlabbedController,
    TextEditingController? gradingCompanyController,
    TextEditingController? graderNotesController,
    TextEditingController? labelTypeController,
    TextEditingController? customLabelController,
    TextEditingController? pageQualityController,
    TextEditingController? certificationNumberController,
  })  : numberController = numberController ?? TextEditingController(),
        publisherController = publisherController ?? TextEditingController(),
        yearController = yearController ?? TextEditingController(),
        barcodeController = barcodeController ?? TextEditingController(),
        variantController = variantController ?? TextEditingController(),
        physicalFormatLabelController =
            physicalFormatLabelController ?? TextEditingController(),
        coverController = coverController ?? TextEditingController(),
        backCoverController = backCoverController ?? TextEditingController(),
        imprintController = imprintController ?? TextEditingController(),
        seriesGroupController =
            seriesGroupController ?? TextEditingController(),
        pageCountController = pageCountController ?? TextEditingController(),
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
            releaseDateController ?? TextEditingController(),
        rawOrSlabbedController =
            rawOrSlabbedController ?? TextEditingController(),
        gradingCompanyController =
            gradingCompanyController ?? TextEditingController(),
        graderNotesController =
            graderNotesController ?? TextEditingController(),
        labelTypeController = labelTypeController ?? TextEditingController(),
        customLabelController =
            customLabelController ?? TextEditingController(),
        pageQualityController =
            pageQualityController ?? TextEditingController(),
        certificationNumberController =
            certificationNumberController ?? TextEditingController();

  final TextEditingController numberController;
  final TextEditingController publisherController;
  final TextEditingController yearController;
  final TextEditingController barcodeController;
  final TextEditingController variantController;
  final TextEditingController physicalFormatLabelController;
  final TextEditingController coverController;
  final TextEditingController backCoverController;
  final TextEditingController imprintController;
  final TextEditingController seriesGroupController;
  final TextEditingController pageCountController;
  final TextEditingController creatorsController;
  final TextEditingController charactersController;
  final TextEditingController synopsisController;
  final TextEditingController genresEditController;
  final TextEditingController ageRatingController;
  final TextEditingController languageController;
  final TextEditingController countryController;
  final TextEditingController editionTitleController;
  final TextEditingController releaseDateController;
  final TextEditingController rawOrSlabbedController;
  final TextEditingController gradingCompanyController;
  final TextEditingController graderNotesController;
  final TextEditingController labelTypeController;
  final TextEditingController customLabelController;
  final TextEditingController pageQualityController;
  final TextEditingController certificationNumberController;

  @override
  void dispose() {
    numberController.dispose();
    publisherController.dispose();
    yearController.dispose();
    barcodeController.dispose();
    variantController.dispose();
    physicalFormatLabelController.dispose();
    coverController.dispose();
    backCoverController.dispose();
    imprintController.dispose();
    seriesGroupController.dispose();
    pageCountController.dispose();
    creatorsController.dispose();
    charactersController.dispose();
    synopsisController.dispose();
    genresEditController.dispose();
    ageRatingController.dispose();
    languageController.dispose();
    countryController.dispose();
    editionTitleController.dispose();
    releaseDateController.dispose();
    rawOrSlabbedController.dispose();
    gradingCompanyController.dispose();
    graderNotesController.dispose();
    labelTypeController.dispose();
    customLabelController.dispose();
    pageQualityController.dispose();
    certificationNumberController.dispose();
  }
}
