import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/edit/draft/kind_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter/material.dart';

class MangaEditDraft extends KindEditDraft {
  MangaEditDraft({
    required this.signedByController,
    required this.gradingCompanyController,
    required this.graderNotesController,
    required this.dustJacketConditionController,
    required this.boxSetOuterConditionController,
    required this.printingController,
    required this.localizedEditionController,
    this.obiStripPresent = false,
    this.slipcoverPresent = false,
    this.dustJacketPresent = false,
    this.insertsPresent = false,
  });

  final TextEditingController signedByController;
  final TextEditingController gradingCompanyController;
  final TextEditingController graderNotesController;
  final TextEditingController dustJacketConditionController;
  final TextEditingController boxSetOuterConditionController;
  final TextEditingController printingController;
  final TextEditingController localizedEditionController;

  bool obiStripPresent;
  bool slipcoverPresent;
  bool dustJacketPresent;
  bool insertsPresent;

  @override
  OwnedDetailsDraft toDetailsDraft() {
    return MangaOwnedDetailsDraft(
      signedBy: signedByController.text.trim().isEmpty
          ? null
          : signedByController.text.trim(),
      gradingCompany: gradingCompanyController.text.trim().isEmpty
          ? null
          : gradingCompanyController.text.trim(),
      graderNotes: graderNotesController.text.trim().isEmpty
          ? null
          : graderNotesController.text.trim(),
      dustJacketCondition: dustJacketConditionController.text.trim().isEmpty
          ? null
          : dustJacketConditionController.text.trim(),
      boxSetOuterCondition: boxSetOuterConditionController.text.trim().isEmpty
          ? null
          : boxSetOuterConditionController.text.trim(),
      printing: printingController.text.trim().isEmpty
          ? null
          : printingController.text.trim(),
      localizedEdition: localizedEditionController.text.trim().isEmpty
          ? null
          : localizedEditionController.text.trim(),
      obiStripPresent: obiStripPresent,
      slipcoverPresent: slipcoverPresent,
      dustJacketPresent: dustJacketPresent,
      insertsPresent: insertsPresent,
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
    signedByController: textControllers.create(text: manga?.signedBy ?? ''),
    gradingCompanyController:
        textControllers.create(text: manga?.gradingCompany ?? ''),
    graderNotesController:
        textControllers.create(text: manga?.graderNotes ?? ''),
    dustJacketConditionController:
        textControllers.create(text: manga?.dustJacketCondition ?? ''),
    boxSetOuterConditionController:
        textControllers.create(text: manga?.boxSetOuterCondition ?? ''),
    printingController: textControllers.create(text: manga?.printing ?? ''),
    localizedEditionController:
        textControllers.create(text: manga?.localizedEdition ?? ''),
    obiStripPresent: manga?.obiStripPresent ?? false,
    slipcoverPresent: manga?.slipcoverPresent ?? false,
    dustJacketPresent: manga?.dustJacketPresent ?? false,
    insertsPresent: manga?.insertsPresent ?? false,
  );
}
