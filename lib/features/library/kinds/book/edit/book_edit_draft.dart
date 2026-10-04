import 'package:collectarr_app/features/library/edit/draft/library_edit_form_fields.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_fields.dart';
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
import 'package:collectarr_app/features/library/kinds/registry/library_entry_dispatch.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/book/entries/book_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/entries/book_library_entry_update_payload.dart';
import 'package:collectarr_app/features/library/edit/draft/personal_state_draft.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:flutter/material.dart';

enum BookCanonicalEditField {
  title,
  sortTitle,
  originalTitle,
  localizedTitle,
  searchAliases,
  subjects,
  synopsis,
  coverImage,
  backCoverImage,
  thumbnailImage
}

class BookEditDraft
    with
        LibraryCatalogItemEditSessionLinkDefaults,
        LibraryEntryEditSessionDefaults
    implements LibraryCatalogItemEditSession, LibraryEntryEditSession {
  BookEditDraft({
    this.libraryEntry,
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
    required this.authorCredits,
    required this.translatorCredits,
    required this.genresController,
  });

  final BookLibraryEntry? libraryEntry;

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
  List<BookCatalogCredit> authorCredits;
  List<BookCatalogCredit> translatorCredits;
  final TextEditingController genresController;

  @override
  JsonEncodable toDetailsDraft() => BookEntryDetailsDraft(
        signedBy: signedBy,
        dustJacketPresent: dustJacketPresent,
        dustJacketCondition: dustJacketCondition,
      );

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
  BookLibraryEntryUpdatePayload buildEntryUpdatePayload({
    required LibraryEntryRef libraryEntryRef,
    required PersonalStateDraft personal,
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
    genresController.dispose();
  }

  List<TrailerLinkDto> _externalLinks = const [];
  bool _externalLinksEdited = false;

  @override
  void setExternalLinks(List<TrailerLinkDto> links) {
    _externalLinks = links;
    _externalLinksEdited = true;
  }

  @override
  LibraryEditSelection applyCanonicalEdits(
    LibraryEditSelection selection,
    LibraryEditFormFields fields,
  ) {
    final current = selection.kindItem.kindCapability.mapTransport(
      (transport) => BookCatalogMetadata.fromJson(transport.kindData),
    );
    final aliases = fields
        .controller(BookCanonicalEditField.searchAliases)
        .text
        .split(RegExp(r'[,\r\n]+'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    final updated = current.copyWith(
      title: fields.controller(BookCanonicalEditField.title).text.trim(),
      sortTitle: emptyToNull(
        fields.controller(BookCanonicalEditField.sortTitle).text,
      ),
      originalTitle: emptyToNull(
        fields.controller(BookCanonicalEditField.originalTitle).text,
      ),
      localizedTitle: emptyToNull(
        fields.controller(BookCanonicalEditField.localizedTitle).text,
      ),
      searchAliases: aliases,
      subjects: _splitValues(
        fields.controller(BookCanonicalEditField.subjects).text,
      ),
      synopsis: emptyToNull(
        fields.controller(BookCanonicalEditField.synopsis).text,
      ),
      coverImageUrl: emptyToNull(
        fields.controller(BookCanonicalEditField.coverImage).text,
      ),
      backCoverImageUrl: emptyToNull(
        fields.controller(BookCanonicalEditField.backCoverImage).text,
      ),
    );
    final updatedCandidate = selection.kindItem.kindCapability.mapTransport(
      (transport) => CatalogSearchCandidate.fromItem(
        transport.replacingKindData(updated),
      ),
    );
    return selection.copyWith(kindItem: updatedCandidate);
  }

  @override
  LibraryEditFormSchema buildCanonicalFormSchema(
    LibraryEditFormFields fields,
    CatalogSearchCandidate item,
  ) {
    final metadata = item.bookCatalogFields;
    fields.create(BookCanonicalEditField.title, initialValue: metadata.title);
    fields.create(BookCanonicalEditField.sortTitle,
        initialValue: metadata.sortKey ?? '');
    fields.create(BookCanonicalEditField.originalTitle,
        initialValue: metadata.originalTitle ?? '');
    fields.create(BookCanonicalEditField.localizedTitle,
        initialValue: metadata.localizedTitle ?? '');
    fields.create(BookCanonicalEditField.searchAliases,
        initialValue: metadata.searchAliases.join(', '));
    fields.create(BookCanonicalEditField.subjects,
        initialValue: metadata.subjects.join(', '));
    fields.create(BookCanonicalEditField.synopsis,
        initialValue: metadata.synopsis ?? '');
    fields.create(BookCanonicalEditField.coverImage,
        initialValue: metadata.coverImageUrl ?? '');
    fields.create(BookCanonicalEditField.backCoverImage,
        initialValue: metadata.backCoverImageUrl ?? '');
    fields.create(BookCanonicalEditField.thumbnailImage,
        initialValue: metadata.thumbnailImageUrl ?? '');
    return LibraryEditFormSchema(
      fields: [
        LibraryEditFormFieldSpec(
          id: BookCanonicalEditField.title,
          section: LibraryEditFormSection.details,
          controller: fields.controller(BookCanonicalEditField.title),
          label: 'Title',
          required: true,
        ),
        LibraryEditFormFieldSpec(
          id: BookCanonicalEditField.sortTitle,
          section: LibraryEditFormSection.details,
          controller: fields.controller(BookCanonicalEditField.sortTitle),
          label: 'Sort Title',
        ),
        LibraryEditFormFieldSpec(
          id: BookCanonicalEditField.originalTitle,
          section: LibraryEditFormSection.details,
          controller: fields.controller(BookCanonicalEditField.originalTitle),
          label: 'Original Title',
        ),
        LibraryEditFormFieldSpec(
          id: BookCanonicalEditField.localizedTitle,
          section: LibraryEditFormSection.details,
          controller: fields.controller(BookCanonicalEditField.localizedTitle),
          label: 'Localized title',
        ),
        LibraryEditFormFieldSpec(
          id: BookCanonicalEditField.searchAliases,
          section: LibraryEditFormSection.details,
          controller: fields.controller(BookCanonicalEditField.searchAliases),
          label: 'Search Aliases',
          visible: false,
        ),
        LibraryEditFormFieldSpec(
          id: BookCanonicalEditField.subjects,
          section: LibraryEditFormSection.details,
          controller: fields.controller(BookCanonicalEditField.subjects),
          label: 'Subjects',
        ),
        LibraryEditFormFieldSpec(
          id: BookCanonicalEditField.thumbnailImage,
          section: LibraryEditFormSection.details,
          controller: fields.controller(BookCanonicalEditField.thumbnailImage),
          label: 'Thumbnail image URL',
          visible: false,
        ),
        LibraryEditFormFieldSpec(
          id: BookCanonicalEditField.coverImage,
          section: LibraryEditFormSection.artwork,
          controller: fields.controller(BookCanonicalEditField.coverImage),
          label: 'Cover Image URL',
        ),
        LibraryEditFormFieldSpec(
          id: BookCanonicalEditField.backCoverImage,
          section: LibraryEditFormSection.artwork,
          controller: fields.controller(BookCanonicalEditField.backCoverImage),
          label: 'Back Cover Image URL',
        ),
        LibraryEditFormFieldSpec(
          id: BookCanonicalEditField.synopsis,
          section: LibraryEditFormSection.description,
          controller: fields.controller(BookCanonicalEditField.synopsis),
          label: 'Synopsis',
          maxLines: 8,
        ),
      ],
      sectionTitles: const {
        LibraryEditFormSection.details: 'Details',
        LibraryEditFormSection.artwork: 'Cover Image',
        LibraryEditFormSection.description: 'Synopsis',
      },
    );
  }

  @override
  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) {
    final meta = selection.kindItem.kindCapability.mapTransport(
      (transport) => BookCatalogMetadata.fromJson(transport.kindData),
    );
    final count = int.tryParse(pageCountController.text);
    final releaseDate = parseDate(releaseDateController.text);
    final updatedMetadata = meta.copyWith(
      pageCount: count,
      imprint: emptyToNull(imprintController.text),
      publisher: emptyToNull(publisherController.text),
      barcode: emptyToNull(barcodeController.text),
      editionTitle: emptyToNull(editionTitleController.text),
      variant: emptyToNull(variantController.text),
      physicalFormat: emptyToNull(formatController.text),
      language: emptyToNull(languageController.text),
      country: emptyToNull(countryController.text),
      creators: [
        for (final credit in meta.creators)
          if (!_isRole(credit.role, 'author') &&
              !_isRole(credit.role, 'translator'))
            credit,
        ..._withRole(authorCredits, 'Author'),
      ],
      genres: _splitValues(genresController.text),
      contributors: [
        for (final credit in meta.contributors)
          if (!_isRole(credit.role, 'author') &&
              !_isRole(credit.role, 'translator'))
            credit,
        ..._withRole(translatorCredits, 'Translator'),
      ],
      releaseDate: releaseDate,
      externalLinks: _externalLinksEdited
          ? [
              for (final link in _externalLinks)
                BookExternalLink(
                  url: link.url,
                  description: link.description,
                  kind: link.kind,
                  title: link.title,
                ),
            ]
          : meta.externalLinks,
    );
    final updatedCandidate = selection.kindItem.kindCapability.mapTransport(
      (transport) => CatalogSearchCandidate.fromItem(
        transport.replacingKindData(updatedMetadata),
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
    pageCountController: textControllers.create(
      text: metadata.pageCount?.toString() ?? '',
    ),
    imprintController: textControllers.create(
      text: metadata.imprint ?? '',
    ),
    publisherController: textControllers.create(
      text: metadata.publisher ?? '',
    ),
    barcodeController: textControllers.create(
      text: metadata.barcode ?? '',
    ),
    releaseDateController: textControllers.create(
      text:
          metadata.releaseDate != null ? formatDate(metadata.releaseDate!) : '',
    ),
    releaseYearController: textControllers.create(
      text: metadata.releaseDate?.year.toString() ?? '',
    ),
    editionTitleController: textControllers.create(
      text: metadata.editionTitle ?? '',
    ),
    variantController: textControllers.create(
      text: metadata.variant ?? '',
    ),
    formatController: textControllers.create(
      text: metadata.physicalFormat ?? '',
    ),
    languageController: textControllers.create(
      text: metadata.language ?? '',
    ),
    countryController: textControllers.create(
      text: metadata.country ?? '',
    ),
    authorCredits: _bookAuthorCredits(metadata),
    translatorCredits: _bookTranslatorCredits(metadata),
    genresController: textControllers.create(
      text: metadata.genres.join(', '),
    ),
  );
  return LibraryEditSessionBundle(
    catalogItemSession: draft,
    entrySession: draft,
    disposeSession: draft.dispose,
  );
}

List<String> _splitValues(String value) => value
    .split(RegExp(r'[,\r\n]+'))
    .map((entry) => entry.trim())
    .where((entry) => entry.isNotEmpty)
    .toSet()
    .toList();

bool _isRole(String? role, String expected) =>
    role?.trim().toLowerCase() == expected.toLowerCase();

List<BookCatalogCredit> _withRole(
  List<BookCatalogCredit> credits,
  String role,
) =>
    [
      for (var index = 0; index < credits.length; index++)
        BookCatalogCredit(
          name: credits[index].name,
          id: credits[index].id,
          artistId: credits[index].artistId,
          personId: credits[index].personId,
          creditedName: credits[index].creditedName,
          imageUrl: credits[index].imageUrl,
          instrument: credits[index].instrument,
          joinPhrase: credits[index].joinPhrase,
          role: role,
          roleId: credits[index].roleId,
          sequence: index,
          sortName: credits[index].sortName,
        ),
    ];

List<BookCatalogCredit> _bookAuthorCredits(BookCatalogMetadata metadata) {
  final explicitAuthors = [...metadata.creators, ...metadata.contributors]
      .where((credit) => _isRole(credit.role, 'author'))
      .toList(growable: false);
  if (explicitAuthors.isNotEmpty) return List.of(explicitAuthors);
  if (metadata.creators
      .every((credit) => credit.role?.trim().isEmpty ?? true)) {
    return List.of(metadata.creators);
  }
  return const [];
}

List<BookCatalogCredit> _bookTranslatorCredits(BookCatalogMetadata metadata) =>
    [
      for (final credit in [...metadata.creators, ...metadata.contributors])
        if (_isRole(credit.role, 'translator')) credit,
    ];
