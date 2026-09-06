import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_edit_kind_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/legacy/comic_owned_item_legacy_adapter.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/owned/comic_owned_edit_draft.dart';
import 'package:collectarr_app/features/catalog/serial/serial_authority_repository.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:flutter/material.dart';

import 'comic_edit_controller.dart';

class ComicEditDraft extends LibraryEditKindDraft {
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
    required this.ownedEdit,
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

  final ComicOwnedEditDraft ownedEdit;
  final ComicEditController comicEdit;
  Future<List<SerialAuthorityEntry>>? seriesEntriesFuture;

  @override
  OwnedDetailsDraft toDetailsDraft() => ownedEdit.toDetailsDraft();

  @override
  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) {
    var result = comicEdit.applySelectionEdits(selection);
    if (result.personal != null) {
      result = result.copyWith(
        personal: result.personal!.copyWith(
          rawOrSlabbed: ownedEdit.rawOrSlabbed,
          gradingCompany: ownedEdit.gradingCompany,
          graderNotes: ownedEdit.graderNotes,
          signedBy: ownedEdit.signedBy,
          labelType: ownedEdit.labelType,
          customLabel: ownedEdit.customLabel,
          pageQuality: ownedEdit.pageQuality,
          certificationNumber: ownedEdit.certificationNumber,
          keyComic: ownedEdit.keyComic,
          keyReason: ownedEdit.keyReason,
          keyCategory: ownedEdit.keyCategory,
          keySeverity: ownedEdit.keySeverity,
          coverPriceCents: ownedEdit.coverPriceCents,
          lastBagBoardDate: ownedEdit.lastBagBoardDate,
        ),
      );
    }
    return result;
  }

  @override
  void dispose() {
    ownedEdit.dispose();
    comicEdit.dispose();
  }
}

LibraryEditKindDraft createComicEditDraft({
  required CatalogItem item,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
  required TextControllerGroup textControllers,
}) {
  final comic = ComicOwnedItemLegacyAdapter.tryFromLegacy(ownedItem)?.details;
  final ownedEdit = ComicOwnedEditDraft.fromDetails(
    comic ?? const ComicOwnedDetails(),
  );
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
    ownedEdit: ownedEdit,
    comicEdit: comicEdit,
  );
}
