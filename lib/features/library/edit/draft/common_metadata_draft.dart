import 'package:flutter/material.dart';

class CommonMetadataDraft {
  CommonMetadataDraft({
    required this.titleController,
    required this.numberController,
    required this.publisherController,
    required this.coverDateController,
    required this.coverDateYearPartController,
    required this.coverDateMonthPartController,
    required this.coverDateDayPartController,
    required this.releaseDateController,
    required this.releaseDateYearPartController,
    required this.releaseDateMonthPartController,
    required this.releaseDateDayPartController,
    required this.releaseYearController,
    required this.editionTitleController,
    required this.barcodeController,
    required this.variantController,
    required this.physicalFormatLabelController,
    required this.coverController,
    required this.thumbnailController,
    required this.synopsisController,
    required this.displayTitleController,
    required this.sortKeyController,
    required this.originalTitleController,
    required this.localizedTitleController,
    required this.searchAliasesController,
    required this.countryController,
    required this.languageController,
    required this.seriesTitleController,
    required this.physicalFormatId,
    required this.seriesId,
  });

  final TextEditingController titleController;
  final TextEditingController numberController;
  final TextEditingController publisherController;
  final TextEditingController coverDateController;
  final TextEditingController coverDateYearPartController;
  final TextEditingController coverDateMonthPartController;
  final TextEditingController coverDateDayPartController;
  final TextEditingController releaseDateController;
  final TextEditingController releaseDateYearPartController;
  final TextEditingController releaseDateMonthPartController;
  final TextEditingController releaseDateDayPartController;
  final TextEditingController releaseYearController;
  final TextEditingController editionTitleController;
  final TextEditingController barcodeController;
  final TextEditingController variantController;
  final TextEditingController physicalFormatLabelController;
  final TextEditingController coverController;
  final TextEditingController thumbnailController;
  final TextEditingController synopsisController;
  final TextEditingController displayTitleController;
  final TextEditingController sortKeyController;
  final TextEditingController originalTitleController;
  final TextEditingController localizedTitleController;
  final TextEditingController searchAliasesController;
  final TextEditingController countryController;
  final TextEditingController languageController;
  final TextEditingController seriesTitleController;

  String? physicalFormatId;
  String? seriesId;
}
