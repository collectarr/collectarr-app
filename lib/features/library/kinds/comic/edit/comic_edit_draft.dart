import 'package:collectarr_app/features/library/edit/draft/library_edit_form_fields.dart';
import 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_fields.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_library_entry_projection.dart';
import 'package:collectarr_app/features/collection/commands/library_entry_commands.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_edit_kind_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_entry_dispatch.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/entry/comic_entry_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_library_entry_update_payload.dart';
import 'package:collectarr_app/features/library/edit/draft/personal_state_draft.dart';
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
    with
        LibraryCatalogItemEditSessionLinkDefaults,
        LibraryEntryEditSessionDefaults
    implements LibraryCatalogItemEditSession, LibraryEntryEditSession {
  ComicEditDraft({
    this.libraryEntry,
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
    required this.entryEdit,
    required this.comicEdit,
  });

  final ComicLibraryEntry? libraryEntry;

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

  final ComicEntryEditDraft entryEdit;
  final ComicEditController comicEdit;

  @override
  JsonEncodable toDetailsDraft() => entryEdit.toDetailsDraft();

  @override
  void initializePersonalState(PersonalStateDraft personal) {
    final item = libraryEntry;
    if (item == null) return;
    personal.ownerLabelController.text = item.personal.ownerLabel ?? '';
    personal.conditionController.text = item.personal.condition ?? '';
    personal.gradeController.text = item.personal.grade ?? '';
    personal.purchaseDateController.text = item.personal.purchaseDate == null
        ? ''
        : formatDate(item.personal.purchaseDate!);
    personal.priceController.text = item.personal.pricePaidCents == null
        ? ''
        : (item.personal.pricePaidCents! / 100).toStringAsFixed(2);
    personal.currencyController.text = item.personal.currency ?? '';
    personal.indexNumberController.text =
        item.personal.indexNumber?.toString() ?? '';
    personal.notesController.text = item.personal.personalNotes ?? '';
    personal.tagsController.text = item.personal.tags ?? '';
    personal.sellPriceController.text = item.personal.sellPriceCents == null
        ? ''
        : (item.personal.sellPriceCents! / 100).toStringAsFixed(2);
    personal.soldToController.text = item.personal.soldTo ?? '';
    personal.purchaseStoreController.text = item.personal.purchaseStore ?? '';
    personal.marketValueController.text = item.personal.marketValueCents == null
        ? ''
        : (item.personal.marketValueCents! / 100).toStringAsFixed(2);
    personal.selectedLocationId = item.personal.locationId;
    personal.soldAt = item.personal.soldAt;
    personal.collectionStatus = item.personal.collectionStatus;
  }

  @override
  ComicLibraryEntryUpdatePayload buildEntryUpdatePayload({
    required LibraryEntryRef libraryEntryRef,
    required PersonalStateDraft personal,
  }) {
    return ComicLibraryEntryUpdatePayload(
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
      details: Patch.set(toDetailsDraft() as ComicEntryDetailsDraft),
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
      kindItem: CatalogSearchCandidate.fromItem(
          selection.kindItem.kindCapability.mapTransport((transport) {
        final metadata = ComicCatalogItem.fromJson(transport.kindData);
        final edited = metadata.copyWith(
          title: fields.controller(ComicCanonicalEditField.title).text.trim(),
          displayTitle: emptyToNull(
              fields.controller(ComicCanonicalEditField.displayTitle).text),
          originalTitle: emptyToNull(
              fields.controller(ComicCanonicalEditField.originalTitle).text),
          localizedTitle: emptyToNull(
              fields.controller(ComicCanonicalEditField.localizedTitle).text),
          searchAliases: aliases.isEmpty ? null : aliases,
          synopsis: emptyToNull(
              fields.controller(ComicCanonicalEditField.synopsis).text),
          coverImageUrl: emptyToNull(
              fields.controller(ComicCanonicalEditField.coverImage).text),
          thumbnailImageUrl: emptyToNull(
              fields.controller(ComicCanonicalEditField.thumbnailImage).text),
          sortTitle: emptyToNull(
            fields.controller(ComicCanonicalEditField.sortTitle).text,
          ),
        );
        final updated = ComicCatalogItem.fromJson(applyJsonFieldPatch(edited, {
          'display_title': emptyToNull(
            fields.controller(ComicCanonicalEditField.displayTitle).text,
          ),
          'original_title': emptyToNull(
            fields.controller(ComicCanonicalEditField.originalTitle).text,
          ),
          'localized_title': emptyToNull(
            fields.controller(ComicCanonicalEditField.localizedTitle).text,
          ),
          'search_aliases': aliases,
          'synopsis': emptyToNull(
            fields.controller(ComicCanonicalEditField.synopsis).text,
          ),
          'cover_image_url': emptyToNull(
            fields.controller(ComicCanonicalEditField.coverImage).text,
          ),
          'thumbnail_image_url': emptyToNull(
            fields.controller(ComicCanonicalEditField.thumbnailImage).text,
          ),
          'sort_key': emptyToNull(
            fields.controller(ComicCanonicalEditField.sortTitle).text,
          ),
        }));
        return transport.replacingKindData(updated);
      })),
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
          label: 'Sort Title',
        ),
        LibraryEditFormFieldSpec(
          id: ComicCanonicalEditField.originalTitle,
          section: LibraryEditFormSection.details,
          controller: fields.controller(ComicCanonicalEditField.originalTitle),
          label: 'Original Title',
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
          label: 'Display Title',
        ),
        LibraryEditFormFieldSpec(
          id: ComicCanonicalEditField.searchAliases,
          section: LibraryEditFormSection.details,
          controller: fields.controller(ComicCanonicalEditField.searchAliases),
          label: 'Search Aliases',
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
    entryEdit.dispose();
    comicEdit.dispose();
  }
}

LibraryEditSessionBundle createComicEditDraft({
  required CatalogSearchCandidate item,
  LibraryEntryDispatch? libraryEntryDispatch,
  TrackingSummary? trackingSummary,
  required TextControllerGroup textControllers,
}) {
  final entry = ComicLibraryEntryProjection.fromDispatch(libraryEntryDispatch);
  final comic = entry?.personal.details;
  final entryEdit = ComicEntryEditDraft.fromDetails(
    comic ?? const ComicEntryDetails(),
  );
  final comicEdit = ComicEditController(
    item: item.kindCapability.mapTransport(
        (transport) => ComicCatalogItem.fromJson(transport.kindData)),
    itemImages: const [],
  );
  comicEdit.initialize();

  final draft = ComicEditDraft(
    libraryEntry: entry,
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
    entryEdit: entryEdit,
    comicEdit: comicEdit,
  );
  return LibraryEditSessionBundle(
    catalogItemSession: draft,
    entrySession: draft,
    disposeSession: draft.dispose,
  );
}
