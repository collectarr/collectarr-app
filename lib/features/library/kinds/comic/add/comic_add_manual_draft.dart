import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:flutter/material.dart';

class ComicAddManualDraft implements LibraryKindAddDraft {
  ComicAddManualDraft({
    TextEditingController? numberController,
    TextEditingController? publisherController,
    TextEditingController? yearController,
    TextEditingController? barcodeController,
    TextEditingController? variantController,
    TextEditingController? physicalFormatLabelController,
    TextEditingController? coverController,
    TextEditingController? rawOrSlabbedController,
    TextEditingController? gradingCompanyController,
    TextEditingController? graderNotesController,
    TextEditingController? signedByController,
    TextEditingController? labelTypeController,
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
        rawOrSlabbedController =
            rawOrSlabbedController ?? TextEditingController(),
        gradingCompanyController =
            gradingCompanyController ?? TextEditingController(),
        graderNotesController =
            graderNotesController ?? TextEditingController(),
        signedByController = signedByController ?? TextEditingController(),
        labelTypeController = labelTypeController ?? TextEditingController(),
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
  final TextEditingController rawOrSlabbedController;
  final TextEditingController gradingCompanyController;
  final TextEditingController graderNotesController;
  final TextEditingController signedByController;
  final TextEditingController labelTypeController;
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
    rawOrSlabbedController.dispose();
    gradingCompanyController.dispose();
    graderNotesController.dispose();
    signedByController.dispose();
    labelTypeController.dispose();
    pageQualityController.dispose();
    certificationNumberController.dispose();
  }
}
