import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:flutter/material.dart';

class MusicAddManualDraft implements LibraryKindAddDraft {
  MusicAddManualDraft({
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
  })  : numberController = numberController ?? TextEditingController(),
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
