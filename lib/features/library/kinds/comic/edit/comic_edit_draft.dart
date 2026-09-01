import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/edit/draft/kind_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/_shared/serial/authority/series_registry_repository.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter/material.dart';

import 'comic_edit_controller.dart';

class ComicEditDraft extends KindEditDraft {
  ComicEditDraft({
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
    required this.keyComic,
    required this.lastBagBoardDate,
    required this.comicEdit,
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

  final ComicEditController comicEdit;
  Future<List<SeriesRegistryEntry>>? seriesEntriesFuture;

  @override
  OwnedDetailsDraft toDetailsDraft() => ComicOwnedDetailsDraft(
        rawOrSlabbed: emptyToNull(rawOrSlabbedController.text),
        gradingCompany: emptyToNull(gradingCompanyController.text),
        graderNotes: emptyToNull(graderNotesController.text),
        signedBy: emptyToNull(signedByController.text),
        labelType: emptyToNull(labelTypeController.text),
        pageQuality: emptyToNull(pageQualityController.text),
        certificationNumber: emptyToNull(certificationNumberController.text),
        keyComic: keyComic,
        keyReason: emptyToNull(keyReasonController.text),
        keyCategory: emptyToNull(keyCategoryController.text),
        coverPriceCents: parseMoneyCents(coverPriceController.text),
        lastBagBoardDate: lastBagBoardDate,
      );

  @override
  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) {
    var result = comicEdit.applySelectionEdits(selection);
    if (result.personal != null) {
      result = result.copyWith(
        personal: result.personal!.copyWith(
          rawOrSlabbed: emptyToNull(rawOrSlabbedController.text),
          gradingCompany: emptyToNull(gradingCompanyController.text),
          graderNotes: emptyToNull(graderNotesController.text),
          signedBy: emptyToNull(signedByController.text),
          labelType: emptyToNull(labelTypeController.text),
          pageQuality: emptyToNull(pageQualityController.text),
          certificationNumber: emptyToNull(certificationNumberController.text),
          keyComic: keyComic,
          keyReason: emptyToNull(keyReasonController.text),
          keyCategory: emptyToNull(keyCategoryController.text),
          coverPriceCents: parseMoneyCents(coverPriceController.text),
          lastBagBoardDate: lastBagBoardDate,
        ),
      );
    }
    return result;
  }

  @override
  void dispose() {
    comicEdit.dispose();
  }
}

KindEditDraft createComicEditDraft({
  required LibraryMetadataItem item,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
  required TextControllerGroup textControllers,
}) {
  final comic = ownedItem?.comicDetails;
  final comicEdit = ComicEditController(
    item: item.kindMetadata as ComicCatalogMetadata,
    itemImages: const [],
  );
  comicEdit.initialize();

  return ComicEditDraft(
    rawOrSlabbedController:
        textControllers.create(text: comic?.rawOrSlabbed ?? ''),
    gradingCompanyController:
        textControllers.create(text: comic?.gradingCompany ?? ''),
    graderNotesController:
        textControllers.create(text: comic?.graderNotes ?? ''),
    signedByController: textControllers.create(text: comic?.signedBy ?? ''),
    labelTypeController: textControllers.create(text: comic?.labelType ?? ''),
    pageQualityController:
        textControllers.create(text: comic?.pageQuality ?? ''),
    certificationNumberController:
        textControllers.create(text: comic?.certificationNumber ?? ''),
    coverPriceController: textControllers.create(
      text: comic?.coverPriceCents == null
          ? ''
          : (comic!.coverPriceCents! / 100).toStringAsFixed(2),
    ),
    keyReasonController: textControllers.create(text: comic?.keyReason ?? ''),
    keyCategoryController:
        textControllers.create(text: comic?.keyCategory ?? ''),
    keyComic: comic?.keyComic ?? false,
    lastBagBoardDate: comic?.lastBagBoardDate,
    comicEdit: comicEdit,
  );
}
