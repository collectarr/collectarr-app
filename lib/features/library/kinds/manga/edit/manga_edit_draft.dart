import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/edit/draft/kind_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter/material.dart';

class MangaEditDraft extends KindEditDraft {
  MangaEditDraft({
    required this.rawOrSlabbedController,
    required this.gradingCompanyController,
    required this.graderNotesController,
    required this.signedByController,
    required this.labelTypeController,
    required this.pageQualityController,
    required this.certificationNumberController,
    required this.coverPriceController,
    required this.keyReasonController,
    required this.keyCategoryController,
    this.keyComic = false,
    this.lastBagBoardDate,
  });

  final TextEditingController rawOrSlabbedController;
  final TextEditingController gradingCompanyController;
  final TextEditingController graderNotesController;
  final TextEditingController signedByController;
  final TextEditingController labelTypeController;
  final TextEditingController pageQualityController;
  final TextEditingController certificationNumberController;
  final TextEditingController coverPriceController;
  final TextEditingController keyReasonController;
  final TextEditingController keyCategoryController;
  bool keyComic;
  DateTime? lastBagBoardDate;

  @override
  OwnedDetailsDraft toDetailsDraft() {
    final cents = double.tryParse(coverPriceController.text.trim());
    return MangaOwnedDetailsDraft(
      rawOrSlabbed: rawOrSlabbedController.text.trim().isEmpty
          ? null
          : rawOrSlabbedController.text.trim(),
      gradingCompany: gradingCompanyController.text.trim().isEmpty
          ? null
          : gradingCompanyController.text.trim(),
      graderNotes: graderNotesController.text.trim().isEmpty
          ? null
          : graderNotesController.text.trim(),
      signedBy: signedByController.text.trim().isEmpty
          ? null
          : signedByController.text.trim(),
      labelType: labelTypeController.text.trim().isEmpty
          ? null
          : labelTypeController.text.trim(),
      pageQuality: pageQualityController.text.trim().isEmpty
          ? null
          : pageQualityController.text.trim(),
      certificationNumber: certificationNumberController.text.trim().isEmpty
          ? null
          : certificationNumberController.text.trim(),
      coverPriceCents: cents != null ? (cents * 100).round() : null,
      keyReason: keyReasonController.text.trim().isEmpty
          ? null
          : keyReasonController.text.trim(),
      keyCategory: keyCategoryController.text.trim().isEmpty
          ? null
          : keyCategoryController.text.trim(),
      keyComic: keyComic,
      lastBagBoardDate: lastBagBoardDate,
    );
  }
}

KindEditDraft createMangaEditDraft({
  required LibraryMetadataItem item,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
  required TextControllerGroup textControllers,
}) {
  final manga = ownedItem?.mangaDetails;
  return MangaEditDraft(
    rawOrSlabbedController:
        textControllers.create(text: manga?.rawOrSlabbed ?? ''),
    gradingCompanyController:
        textControllers.create(text: manga?.gradingCompany ?? ''),
    graderNotesController:
        textControllers.create(text: manga?.graderNotes ?? ''),
    signedByController: textControllers.create(text: manga?.signedBy ?? ''),
    labelTypeController: textControllers.create(text: manga?.labelType ?? ''),
    pageQualityController:
        textControllers.create(text: manga?.pageQuality ?? ''),
    certificationNumberController:
        textControllers.create(text: manga?.certificationNumber ?? ''),
    coverPriceController: textControllers.create(
      text: manga?.coverPriceCents == null
          ? ''
          : (manga!.coverPriceCents! / 100).toStringAsFixed(2),
    ),
    keyReasonController: textControllers.create(text: manga?.keyReason ?? ''),
    keyCategoryController:
        textControllers.create(text: manga?.keyCategory ?? ''),
    keyComic: manga?.keyComic ?? false,
    lastBagBoardDate: manga?.lastBagBoardDate,
  );
}
