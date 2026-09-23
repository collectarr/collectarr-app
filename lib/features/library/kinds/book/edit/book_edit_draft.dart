import 'package:collectarr_app/features/library/edit/draft/library_edit_form_fields.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_edit_kind_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_owned_item_dispatch.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/edit/draft/personal_state_draft.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:flutter/material.dart';

class BookEditDraft
    with LibraryWorkEditSessionLinkDefaults, LibraryCopyEditSessionDefaults
    implements LibraryReleaseEditSession, LibraryCopyEditSession {
  BookEditDraft({
    this.ownedItem,
    this.signedBy,
    this.dustJacketPresent = false,
    this.dustJacketCondition,
    required this.pageCountController,
    required this.imprintController,
    required this.releaseDateController,
    required this.releaseYearController,
    required this.publisherController,
    required this.barcodeController,
    required this.editionTitleController,
    required this.variantController,
    required this.formatController,
    required this.languageController,
    required this.countryController,
    required this.authorsController,
    required this.genresController,
    required this.subjectsController,
    required this.translatorsController,
  });

  final BookOwnedItem? ownedItem;

  String? signedBy;
  bool dustJacketPresent;
  String? dustJacketCondition;
  final TextEditingController pageCountController;
  final TextEditingController imprintController;
  final TextEditingController releaseDateController;
  final TextEditingController releaseYearController;
  final TextEditingController publisherController;
  final TextEditingController barcodeController;
  final TextEditingController editionTitleController;
  final TextEditingController variantController;
  final TextEditingController formatController;
  final TextEditingController languageController;
  final TextEditingController countryController;
  final TextEditingController authorsController;
  final TextEditingController genresController;
  final TextEditingController subjectsController;
  final TextEditingController translatorsController;

  @override
  JsonEncodable toDetailsDraft() => BookOwnedDetailsDraft(
        signedBy: signedBy,
        dustJacketPresent: dustJacketPresent,
        dustJacketCondition: dustJacketCondition,
      );

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
  BookOwnedItemUpdatePayload buildOwnedUpdatePayload({
    required OwnedItemRef ownedRef,
    required PersonalStateDraft personal,
  }) {
    final targetRef = personal.selectedOwnedTargetRef;
    return BookOwnedItemUpdatePayload(
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
      details: Patch.set(toDetailsDraft() as BookOwnedDetailsDraft),
    );
  }

  void dispose() {
    pageCountController.dispose();
    imprintController.dispose();
    releaseDateController.dispose();
    releaseYearController.dispose();
    publisherController.dispose();
    barcodeController.dispose();
    editionTitleController.dispose();
    variantController.dispose();
    formatController.dispose();
    languageController.dispose();
    countryController.dispose();
    authorsController.dispose();
    genresController.dispose();
    subjectsController.dispose();
    translatorsController.dispose();
  }

  List<TrailerLinkDto> _externalLinks = const [];

  @override
  void setExternalLinks(List<TrailerLinkDto> links) {
    _externalLinks = links;
  }

  @override
  LibraryEditSelection applyCanonicalEdits(
    LibraryEditSelection selection,
    LibraryEditFormFields fields,
  ) {
    final aliases = fields.searchAliasesController.text
        .split(RegExp(r'[,\r\n]+'))
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList();
    return selection.copyWith(
      kindItem: selection.kindItem.copyWith(
        title: fields.titleController.text.trim(),
        displayTitle: emptyToNull(fields.displayTitleController.text),
        sortKey: emptyToNull(fields.sortKeyController.text),
        originalTitle: emptyToNull(fields.originalTitleController.text),
        localizedTitle: emptyToNull(fields.localizedTitleController.text),
        searchAliases: aliases.isEmpty ? null : aliases,
        synopsis: emptyToNull(fields.synopsisController.text),
        coverImageUrl: emptyToNull(fields.coverController.text),
        thumbnailImageUrl: emptyToNull(fields.thumbnailController.text),
      ),
    );
  }

  @override
  void initializeCanonicalFields(
    LibraryEditFormFields fields,
    CatalogSearchCandidate item,
  ) {
    final metadata = item.editMetadata;
    fields.titleController.text = metadata.title;
    fields.displayTitleController.text = metadata.displayTitle ?? '';
    fields.sortKeyController.text = metadata.sortKey ?? '';
    fields.originalTitleController.text = metadata.originalTitle ?? '';
    fields.localizedTitleController.text = metadata.localizedTitle ?? '';
    fields.searchAliasesController.text = metadata.searchAliases.join(', ');
    fields.synopsisController.text = metadata.synopsis ?? '';
    fields.coverController.text = metadata.coverImageUrl ?? '';
    fields.thumbnailController.text = metadata.thumbnailImageUrl ?? '';
  }

  @override
  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) {
    final rawMetadata =
        selection.kindItem.mapTransport((transport) => transport).kindMetadata;
    final meta = rawMetadata is BookCatalogMetadata
        ? rawMetadata
        : BookCatalogMetadata.fromJson(
            selection.kindItem.mapTransport((transport) => transport).payload);
    final count = int.tryParse(pageCountController.text);
    final impr = emptyToNull(imprintController.text);
    final pub = emptyToNull(publisherController.text);
    final barcode = emptyToNull(barcodeController.text);
    final editionTitle = emptyToNull(editionTitleController.text);
    final variant = emptyToNull(variantController.text);
    final format = emptyToNull(formatController.text);
    final language = emptyToNull(languageController.text);
    final country = emptyToNull(countryController.text);

    final updatedPublishing = meta.publishing != null
        ? meta.publishing!.copyWith(
            pageCount: count ?? meta.publishing!.pageCount,
            imprint: impr ?? meta.publishing!.imprint,
            originalPublisher: pub ?? meta.publishing!.originalPublisher,
          )
        : ((count != null || impr != null || pub != null)
            ? CatalogPublishingDetailsDto(
                imprint: impr,
                pageCount: count,
                originalPublisher: pub,
              )
            : null);

    final updatedMetadata = meta.copyWith(
      publisher: pub ?? meta.publisher,
      barcode: barcode ?? meta.barcode,
      editionTitle: editionTitle ?? meta.editionTitle,
      variant: variant ?? meta.variant,
      physicalFormat: format ?? meta.physicalFormat,
      physicalFormatLabel: format ?? meta.physicalFormatLabel,
      language: language ?? meta.language,
      country: country ?? meta.country,
      authors: _splitValues(authorsController.text, fallback: meta.authors),
      genres: _splitValues(genresController.text, fallback: meta.genres),
      subjects: _splitValues(subjectsController.text, fallback: meta.subjects),
      translators: _splitValues(
        translatorsController.text,
        fallback: meta.translators,
      ),
      originalPublicationDate:
          parseDate(releaseDateController.text) ?? meta.originalPublicationDate,
      publishing: updatedPublishing != null && updatedPublishing.hasData
          ? updatedPublishing
          : null,
      links: _externalLinks.isNotEmpty ? _externalLinks : meta.links,
    );

    final updatedItem = selection.kindItem.mapTransport(
      (transport) => CatalogSearchCandidate.fromItem(
        transport.withKindMetadata(updatedMetadata),
      ),
    );
    return selection.copyWith(kindItem: updatedItem);
  }
}

LibraryEditSessionBundle createBookEditDraft({
  required CatalogSearchCandidate item,
  LibraryOwnedItemDispatch? ownedItemDispatch,
  TrackingSummary? trackingSummary,
  required TextControllerGroup textControllers,
}) {
  final owned = BookOwnedItemProjection.fromDispatch(ownedItemDispatch);
  final book = owned?.details;
  final rawMetadata = item.mapTransport((transport) => transport).kindMetadata;
  final BookCatalogMetadata metadata = rawMetadata is BookCatalogMetadata
      ? rawMetadata
      : BookCatalogMetadata.fromJson(
          item.mapTransport((transport) => transport).payload);
  final draft = BookEditDraft(
    ownedItem: owned,
    signedBy: book?.signedBy,
    dustJacketPresent: book?.dustJacketPresent ?? false,
    dustJacketCondition: book?.dustJacketCondition,
    pageCountController: textControllers.create(
      text: metadata.publishing?.pageCount?.toString() ?? '',
    ),
    imprintController: textControllers.create(
      text: metadata.publishing?.imprint ?? '',
    ),
    publisherController: textControllers.create(
      text: metadata.publisher ?? metadata.publishing?.originalPublisher ?? '',
    ),
    barcodeController: textControllers.create(
      text: metadata.barcode ?? '',
    ),
    releaseDateController: textControllers.create(
      text: metadata.originalPublicationDate != null
          ? formatDate(metadata.originalPublicationDate!)
          : '',
    ),
    releaseYearController: textControllers.create(
      text: metadata.originalPublicationDate?.year.toString() ?? '',
    ),
    editionTitleController: textControllers.create(
      text: metadata.editionTitle ?? '',
    ),
    variantController: textControllers.create(
      text: metadata.variant ?? '',
    ),
    formatController: textControllers.create(
      text: metadata.physicalFormatLabel ?? metadata.physicalFormat ?? '',
    ),
    languageController: textControllers.create(
      text: metadata.language ?? '',
    ),
    countryController: textControllers.create(
      text: metadata.country ?? '',
    ),
    authorsController: textControllers.create(
      text: metadata.authors.join(', '),
    ),
    genresController: textControllers.create(
      text: metadata.genres.join(', '),
    ),
    subjectsController: textControllers.create(
      text: metadata.subjects.join(', '),
    ),
    translatorsController: textControllers.create(
      text: metadata.translators.join(', '),
    ),
  );
  return LibraryEditSessionBundle(
    workSession: draft,
    releaseSession: draft,
    copySession: draft,
    disposeSession: draft.dispose,
  );
}

List<String> _splitValues(String value, {required List<String> fallback}) {
  final values = value
      .split(RegExp(r'[,\r\n]+'))
      .map((entry) => entry.trim())
      .where((entry) => entry.isNotEmpty)
      .toSet()
      .toList();
  return values.isEmpty ? fallback : values;
}
