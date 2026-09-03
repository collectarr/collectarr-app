import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
import 'package:flutter/material.dart';

final class ComicOwnedEditDraft {
  factory ComicOwnedEditDraft.fromDetails(ComicOwnedDetails details) {
    return ComicOwnedEditDraft(
      rawOrSlabbedController: TextEditingController(text: details.rawOrSlabbed),
      gradingCompanyController:
          TextEditingController(text: details.gradingCompany),
      graderNotesController: TextEditingController(text: details.graderNotes),
      signedByController: TextEditingController(text: details.signedBy),
      labelTypeController: TextEditingController(text: details.labelType),
      customLabelController: TextEditingController(text: details.customLabel),
      pageQualityController: TextEditingController(text: details.pageQuality),
      certificationNumberController:
          TextEditingController(text: details.certificationNumber),
      keyReasonController: TextEditingController(text: details.keyReason),
      keyCategoryController: TextEditingController(text: details.keyCategory),
      keySeverityController: TextEditingController(text: details.keySeverity),
      keyComic: details.keyComic,
      coverPriceCents: details.coverPriceCents,
      lastBagBoardDate: details.lastBagBoardDate,
    );
  }

  ComicOwnedEditDraft({
    required this.rawOrSlabbedController,
    required this.gradingCompanyController,
    required this.graderNotesController,
    required this.signedByController,
    required this.labelTypeController,
    required this.customLabelController,
    required this.pageQualityController,
    required this.certificationNumberController,
    required this.keyReasonController,
    required this.keyCategoryController,
    required this.keySeverityController,
    required this.keyComic,
    required this.coverPriceCents,
    required this.lastBagBoardDate,
  });

  final TextEditingController rawOrSlabbedController;
  final TextEditingController gradingCompanyController;
  final TextEditingController graderNotesController;
  final TextEditingController signedByController;
  final TextEditingController labelTypeController;
  final TextEditingController customLabelController;
  final TextEditingController pageQualityController;
  final TextEditingController certificationNumberController;
  final TextEditingController keyReasonController;
  final TextEditingController keyCategoryController;
  final TextEditingController keySeverityController;

  bool keyComic;
  int? coverPriceCents;
  DateTime? lastBagBoardDate;

  String? get rawOrSlabbed => _emptyToNull(rawOrSlabbedController.text);
  set rawOrSlabbed(String? value) => rawOrSlabbedController.text = value ?? '';

  String? get gradingCompany => _emptyToNull(gradingCompanyController.text);
  set gradingCompany(String? value) =>
      gradingCompanyController.text = value ?? '';

  String? get graderNotes => _emptyToNull(graderNotesController.text);
  set graderNotes(String? value) => graderNotesController.text = value ?? '';

  String? get signedBy => _emptyToNull(signedByController.text);
  set signedBy(String? value) => signedByController.text = value ?? '';

  String? get labelType => _emptyToNull(labelTypeController.text);
  set labelType(String? value) => labelTypeController.text = value ?? '';

  String? get customLabel => _emptyToNull(customLabelController.text);
  set customLabel(String? value) => customLabelController.text = value ?? '';

  String? get pageQuality => _emptyToNull(pageQualityController.text);
  set pageQuality(String? value) => pageQualityController.text = value ?? '';

  String? get certificationNumber =>
      _emptyToNull(certificationNumberController.text);
  set certificationNumber(String? value) =>
      certificationNumberController.text = value ?? '';

  String? get keyReason => _emptyToNull(keyReasonController.text);
  set keyReason(String? value) => keyReasonController.text = value ?? '';

  String? get keyCategory => _emptyToNull(keyCategoryController.text);
  set keyCategory(String? value) => keyCategoryController.text = value ?? '';

  String? get keySeverity => _emptyToNull(keySeverityController.text);
  set keySeverity(String? value) => keySeverityController.text = value ?? '';

  ComicOwnedDetails toDetails() => ComicOwnedDetails(
        rawOrSlabbed: rawOrSlabbed,
        gradingCompany: gradingCompany,
        graderNotes: graderNotes,
        signedBy: signedBy,
        labelType: labelType,
        customLabel: customLabel,
        pageQuality: pageQuality,
        certificationNumber: certificationNumber,
        keyComic: keyComic,
        keyReason: keyReason,
        keyCategory: keyCategory,
        keySeverity: keySeverity,
        coverPriceCents: coverPriceCents,
        lastBagBoardDate: lastBagBoardDate,
      );

  ComicOwnedDetailsDraft toDetailsDraft() => ComicOwnedDetailsDraft(
        rawOrSlabbed: rawOrSlabbed,
        gradingCompany: gradingCompany,
        graderNotes: graderNotes,
        signedBy: signedBy,
        labelType: labelType,
        customLabel: customLabel,
        pageQuality: pageQuality,
        certificationNumber: certificationNumber,
        keyComic: keyComic,
        keyReason: keyReason,
        keyCategory: keyCategory,
        keySeverity: keySeverity,
        coverPriceCents: coverPriceCents,
        lastBagBoardDate: lastBagBoardDate,
      );

  void dispose() {
    rawOrSlabbedController.dispose();
    gradingCompanyController.dispose();
    graderNotesController.dispose();
    signedByController.dispose();
    labelTypeController.dispose();
    customLabelController.dispose();
    pageQualityController.dispose();
    certificationNumberController.dispose();
    keyReasonController.dispose();
    keyCategoryController.dispose();
    keySeverityController.dispose();
  }
}

String? _emptyToNull(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}
