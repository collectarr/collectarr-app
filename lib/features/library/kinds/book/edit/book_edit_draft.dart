import 'package:collectarr_app/features/library/edit/draft/library_edit_form_fields.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_library_entry_projection.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/collection/commands/library_entry_commands.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_edit_kind_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/book_catalog_form_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/book_catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/book_catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/book_catalog_external_link_draft.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_entry_dispatch.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/book/entries/book_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/entries/book_library_entry_update_payload.dart';
import 'package:collectarr_app/features/library/edit/draft/library_entry_personal_bindings.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

class BookEditDraft
    with
        LibraryCatalogItemEditSessionLinkDefaults,
        LibraryEntryEditSessionDefaults
    implements
        LibraryCatalogItemEditSession,
        LibraryEntryEditSession,
        BookCatalogFormDraft {
  BookEditDraft({
    this.libraryEntry,
    this.signedBy,
    this.dustJacketPresent = false,
    this.dustJacketCondition,
    required this.values,
    required this.catalogTitle,
    required this.externalLinks,
  });

  final BookLibraryEntry? libraryEntry;

  @override
  final BookCatalogFormValues values;

  @override
  String catalogTitle;

  String? signedBy;
  bool dustJacketPresent;
  String? dustJacketCondition;
  final List<BookCatalogExternalLinkDraft> externalLinks;
  bool _externalLinksEdited = false;

  void markExternalLinksEdited() => _externalLinksEdited = true;

  void dispose() {
    for (final link in externalLinks) {
      link.dispose();
    }
  }

  @override
  JsonEncodable toDetailsDraft() => BookEntryDetailsDraft(
        signedBy: signedBy,
        dustJacketPresent: dustJacketPresent,
        dustJacketCondition: dustJacketCondition,
      );

  @override
  void initializePersonalState(LibraryEntryPersonalBindings personal) {
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
  BookLibraryEntryUpdatePayload buildEntryUpdatePayload({
    required LibraryEntryRef libraryEntryRef,
    required LibraryEntryPersonalBindings personal,
  }) {
    return BookLibraryEntryUpdatePayload(
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
      details: Patch.set(toDetailsDraft() as BookEntryDetailsDraft),
    );
  }

  @override
  void setExternalLinks(List<TrailerLinkDto> links) {
    for (final link in externalLinks) {
      link.dispose();
    }
    externalLinks
      ..clear()
      ..addAll([
        for (final link in links)
          BookCatalogExternalLinkDraft(
            original: BookExternalLink(
              url: link.url,
              description: link.description,
              kind: link.kind,
              title: link.title,
            ),
          ),
      ]);
    _externalLinksEdited = true;
  }

  @override
  LibraryEditSelection applyCanonicalEdits(
    LibraryEditSelection selection,
    LibraryEditFormFields fields,
  ) =>
      selection;

  @override
  LibraryEditFormSchema buildCanonicalFormSchema(
    LibraryEditFormFields fields,
    CatalogSearchCandidate item,
  ) =>
      LibraryEditFormSchema.empty;

  @override
  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) {
    final meta = selection.kindItem.kindCapability.mapTransport(
      (transport) => BookCatalogMetadata.fromJson(transport.kindData),
    );
    final updatedMetadata = applyBookCatalogFormValues(
      current: meta,
      values: values,
      title: catalogTitle,
    ).copyWith(
      externalLinks: _externalLinksEdited
          ? [
              for (final (index, link) in externalLinks
                  .where(
                      (link) => link.row.urlController.text.trim().isNotEmpty)
                  .indexed)
                link.toModel(index + 1),
            ]
          : meta.externalLinks,
    );
    final updatedCandidate = selection.kindItem.kindCapability.mapTransport(
      (transport) => CatalogSearchCandidate.fromItem(
        transport.replacingKindData(updatedMetadata),
        basedOn: selection.kindItem,
      ),
    );
    return selection.copyWith(kindItem: updatedCandidate);
  }
}

LibraryEditSessionBundle createBookEditDraft({
  required CatalogSearchCandidate item,
  LibraryEntryDispatch? libraryEntryDispatch,
  TrackingSummary? trackingSummary,
  required TextControllerGroup textControllers,
}) {
  final entry = BookLibraryEntryProjection.fromDispatch(libraryEntryDispatch);
  final book = entry?.personal.details;
  final metadata = item.kindCapability.mapTransport(
    (transport) => BookCatalogMetadata.fromJson(transport.kindData),
  );
  final draft = BookEditDraft(
    libraryEntry: entry,
    signedBy: book?.signedBy,
    dustJacketPresent: book?.dustJacketPresent ?? false,
    dustJacketCondition: book?.dustJacketCondition,
    values: bookCatalogFormValuesFromMetadata(metadata),
    catalogTitle: metadata.title,
    externalLinks: [
      for (final link in metadata.externalLinks)
        BookCatalogExternalLinkDraft(original: link),
    ],
  );
  return LibraryEditSessionBundle(
    catalogItemSession: draft,
    entrySession: draft,
    disposeSession: draft.dispose,
  );
}
