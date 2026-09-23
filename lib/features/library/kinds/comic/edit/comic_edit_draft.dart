import 'package:collectarr_app/features/library/edit/draft/library_edit_form_fields.dart';
import 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_fields.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_owned_item_projection.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_edit_kind_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_owned_item_dispatch.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/owned/comic_owned_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/edit/draft/personal_state_draft.dart';
import 'package:collectarr_app/features/catalog/serial/serial_authority_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter/material.dart';

import 'comic_edit_controller.dart';

enum ComicCanonicalEditField {
  title,
  displayTitle,
  sortTitle,
  originalTitle,
  localizedTitle,
  searchAliases,
  synopsis,
  coverImage,
  thumbnailImage
}

class ComicEditDraft
    with LibraryWorkEditSessionLinkDefaults, LibraryCopyEditSessionDefaults
    implements LibraryReleaseEditSession, LibraryCopyEditSession {
  ComicEditDraft({
    this.ownedItem,
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

  final ComicOwnedItem? ownedItem;

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
  JsonEncodable toDetailsDraft() => ownedEdit.toDetailsDraft();

  @override
  void initializePersonalState(PersonalStateDraft personal) {
    final item = ownedItem;
    if (item == null) return;
    personal.ownerLabelController.text = item.ownerLabel ?? '';
    personal.conditionController.text = item.condition ?? '';
    personal.gradeController.text = item.grade ?? '';
    personal.purchaseDateController.text =
        item.purchaseDate == null ? '' : formatDate(item.purchaseDate!);
    personal.priceController.text = item.pricePaidCents == null
        ? ''
        : (item.pricePaidCents! / 100).toStringAsFixed(2);
    personal.currencyController.text = item.currency ?? '';
    personal.quantityController.text = item.quantity.toString();
    personal.indexNumberController.text = item.indexNumber?.toString() ?? '';
    personal.notesController.text = item.personalNotes ?? '';
    personal.tagsController.text = item.tags ?? '';
    personal.sellPriceController.text = item.sellPriceCents == null
        ? ''
        : (item.sellPriceCents! / 100).toStringAsFixed(2);
    personal.soldToController.text = item.soldTo ?? '';
    personal.purchaseStoreController.text = item.purchaseStore ?? '';
    personal.marketValueController.text = item.marketValueCents == null
        ? ''
        : (item.marketValueCents! / 100).toStringAsFixed(2);
    personal.selectedLocationId = item.locationId;
    personal.soldAt = item.soldAt;
    personal.collectionStatus = item.collectionStatus;
  }

  @override
  ComicOwnedItemUpdatePayload buildOwnedUpdatePayload({
    required OwnedItemRef ownedRef,
    required PersonalStateDraft personal,
  }) {
    final targetRef = personal.selectedOwnedTargetRef;
    return ComicOwnedItemUpdatePayload(
      targetRef: targetRef == null ? const Patch.clear() : Patch.set(targetRef),
      quantity: Patch.set(parseInt(personal.quantityController.text) ?? 1),
      isDigital: const Patch.unchanged(),
      marketValueCents: const Patch.unchanged(),
      indexNumber: const Patch.unchanged(),
      condition: personal.conditionController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(personal.conditionController.text.trim()),
      grade: personal.gradeController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(personal.gradeController.text.trim()),
      purchaseDate: personal.purchaseDateController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(parseDate(personal.purchaseDateController.text)),
      pricePaidCents: personal.priceController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(parseMoneyCents(personal.priceController.text)),
      currency: personal.currencyController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(personal.currencyController.text.trim()),
      personalNotes: personal.notesController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(personal.notesController.text.trim()),
      locationId: personal.selectedLocationId != null
          ? Patch.set(personal.selectedLocationId)
          : const Patch.clear(),
      purchaseStore: personal.purchaseStoreController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(personal.purchaseStoreController.text.trim()),
      collectionStatus: personal.collectionStatus != null
          ? Patch.set(personal.collectionStatus)
          : const Patch.clear(),
      tags: personal.tagsController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(personal.tagsController.text.trim()),
      soldAt: personal.soldAt != null
          ? Patch.set(personal.soldAt)
          : const Patch.clear(),
      sellPriceCents: personal.sellPriceController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(parseMoneyCents(personal.sellPriceController.text)),
      soldTo: personal.soldToController.text.trim().isEmpty
          ? const Patch.clear()
          : Patch.set(personal.soldToController.text.trim()),
      details: Patch.set(toDetailsDraft() as ComicOwnedDetailsDraft),
    );
  }

  @override
  LibraryEditSelection applyCanonicalEdits(
    LibraryEditSelection selection,
    LibraryEditFormFields fields,
  ) {
    final aliases = fields
        .controller(ComicCanonicalEditField.searchAliases)
        .text
        .split(RegExp(r'[,\r\n]+'))
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList();
    return selection.copyWith(
      kindItem: CatalogSearchCandidate.fromItem(selection
          .kindItem.kindCapability
          .mapTransport((transport) => transport.copyWith(
                title: fields
                    .controller(ComicCanonicalEditField.title)
                    .text
                    .trim(),
                displayTitle: emptyToNull(fields
                    .controller(ComicCanonicalEditField.displayTitle)
                    .text),
                sortKey: emptyToNull(
                    fields.controller(ComicCanonicalEditField.sortTitle).text),
                originalTitle: emptyToNull(fields
                    .controller(ComicCanonicalEditField.originalTitle)
                    .text),
                localizedTitle: emptyToNull(fields
                    .controller(ComicCanonicalEditField.localizedTitle)
                    .text),
                searchAliases: aliases.isEmpty ? null : aliases,
                synopsis: emptyToNull(
                    fields.controller(ComicCanonicalEditField.synopsis).text),
                coverImageUrl: emptyToNull(
                    fields.controller(ComicCanonicalEditField.coverImage).text),
                thumbnailImageUrl: emptyToNull(fields
                    .controller(ComicCanonicalEditField.thumbnailImage)
                    .text),
              ))),
    );
  }

  @override
  LibraryEditFormSchema buildCanonicalFormSchema(
    LibraryEditFormFields fields,
    CatalogSearchCandidate item,
  ) {
    final metadata = item.comicCatalogFields;
    fields.create(ComicCanonicalEditField.title, initialValue: metadata.title);
    fields.create(ComicCanonicalEditField.displayTitle,
        initialValue: metadata.displayTitle ?? '');
    fields.create(ComicCanonicalEditField.sortTitle,
        initialValue: metadata.sortKey ?? '');
    fields.create(ComicCanonicalEditField.originalTitle,
        initialValue: metadata.originalTitle ?? '');
    fields.create(ComicCanonicalEditField.localizedTitle,
        initialValue: metadata.localizedTitle ?? '');
    fields.create(ComicCanonicalEditField.searchAliases,
        initialValue: metadata.searchAliases.join(', '));
    fields.create(ComicCanonicalEditField.synopsis,
        initialValue: metadata.synopsis ?? '');
    fields.create(ComicCanonicalEditField.coverImage,
        initialValue: metadata.coverImageUrl ?? '');
    fields.create(ComicCanonicalEditField.thumbnailImage,
        initialValue: metadata.thumbnailImageUrl ?? '');
    return LibraryEditFormSchema(
      fields: [
        LibraryEditFormFieldSpec(
          id: ComicCanonicalEditField.title,
          section: LibraryEditFormSection.details,
          controller: fields.controller(ComicCanonicalEditField.title),
          label: 'Title',
          required: true,
        ),
        LibraryEditFormFieldSpec(
          id: ComicCanonicalEditField.sortTitle,
          section: LibraryEditFormSection.details,
          controller: fields.controller(ComicCanonicalEditField.sortTitle),
          label: 'Sort title',
        ),
        LibraryEditFormFieldSpec(
          id: ComicCanonicalEditField.originalTitle,
          section: LibraryEditFormSection.details,
          controller: fields.controller(ComicCanonicalEditField.originalTitle),
          label: 'Original title',
        ),
        LibraryEditFormFieldSpec(
          id: ComicCanonicalEditField.localizedTitle,
          section: LibraryEditFormSection.details,
          controller: fields.controller(ComicCanonicalEditField.localizedTitle),
          label: 'Localized title',
        ),
        LibraryEditFormFieldSpec(
          id: ComicCanonicalEditField.displayTitle,
          section: LibraryEditFormSection.details,
          controller: fields.controller(ComicCanonicalEditField.displayTitle),
          label: 'Display title',
        ),
        LibraryEditFormFieldSpec(
          id: ComicCanonicalEditField.searchAliases,
          section: LibraryEditFormSection.details,
          controller: fields.controller(ComicCanonicalEditField.searchAliases),
          label: 'Search aliases',
          visible: false,
        ),
        LibraryEditFormFieldSpec(
          id: ComicCanonicalEditField.thumbnailImage,
          section: LibraryEditFormSection.details,
          controller: fields.controller(ComicCanonicalEditField.thumbnailImage),
          label: 'Thumbnail image URL',
          visible: false,
        ),
        LibraryEditFormFieldSpec(
          id: ComicCanonicalEditField.coverImage,
          section: LibraryEditFormSection.artwork,
          controller: fields.controller(ComicCanonicalEditField.coverImage),
          label: 'Cover Image URL',
        ),
        LibraryEditFormFieldSpec(
          id: ComicCanonicalEditField.synopsis,
          section: LibraryEditFormSection.description,
          controller: fields.controller(ComicCanonicalEditField.synopsis),
          label: 'Plot',
          maxLines: 8,
        ),
      ],
      sectionTitles: const {
        LibraryEditFormSection.details: 'Details',
        LibraryEditFormSection.artwork: 'Cover Image',
        LibraryEditFormSection.description: 'Plot',
      },
    );
  }

  @override
  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) {
    return comicEdit.applySelectionEdits(selection);
  }

  void dispose() {
    ownedEdit.dispose();
    comicEdit.dispose();
  }
}

LibraryEditSessionBundle createComicEditDraft({
  required CatalogSearchCandidate item,
  LibraryOwnedItemDispatch? ownedItemDispatch,
  TrackingSummary? trackingSummary,
  required TextControllerGroup textControllers,
}) {
  final owned = ComicOwnedItemProjection.fromDispatch(ownedItemDispatch);
  final comic = owned?.details;
  final ownedEdit = ComicOwnedEditDraft.fromDetails(
    comic ?? const ComicOwnedDetails(),
  );
  final comicEdit = ComicEditController(
    item: item.kindCapability
        .mapTransport((transport) => transport)
        .kindMetadata as ComicMedia,
    itemImages: const [],
  );
  comicEdit.initialize();

  final draft = ComicEditDraft(
    ownedItem: owned,
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
  return LibraryEditSessionBundle(
    workSession: draft,
    releaseSession: draft,
    copySession: draft,
    disposeSession: draft.dispose,
  );
}
