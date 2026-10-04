import 'package:collectarr_app/features/library/edit/draft/library_edit_form_fields.dart';
import 'package:collectarr_app/features/library/kinds/manga/catalog/manga_catalog_fields.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_library_entry_projection.dart';
import 'package:collectarr_app/features/collection/commands/library_entry_commands.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_edit_kind_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter/material.dart';

import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_entry_dispatch.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/manga/entries/manga_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/entries/manga_library_entry_update_payload.dart';
import 'package:collectarr_app/features/library/edit/draft/personal_state_draft.dart';

enum MangaCanonicalEditField {
  title,
  sortTitle,
  originalTitle,
  localizedTitle,
  searchAliases,
  synopsis,
  coverImage,
  thumbnailImage
}

class MangaEditDraft
    with
        LibraryCatalogItemEditSessionLinkDefaults,
        LibraryEntryEditSessionDefaults
    implements LibraryCatalogItemEditSession, LibraryEntryEditSession {
  MangaEditDraft({
    this.libraryEntry,
    this.rawOrSlabbed,
    this.signedBy,
    this.gradingCompany,
    this.graderNotes,
    this.labelType,
    this.customLabel,
    this.pageQuality,
    this.certificationNumber,
    this.obiStripPresent = false,
    this.slipcoverPresent = false,
    this.dustJacketPresent = false,
    this.dustJacketCondition,
    this.boxSetOuterCondition,
    this.insertsPresent = false,
    this.printing,
    this.localizedEdition,
    required this.pageCountController,
    required this.imprintController,
    required this.releaseDateController,
    required this.releaseYearController,
    required this.publisherController,
    required this.barcodeController,
    required this.volumeNumberController,
    required this.editionTitleController,
    required this.variantController,
    required this.physicalFormatController,
    required this.languageController,
    required this.countryController,
    required this.genresController,
    required this.themesController,
    required this.authorsController,
    required this.artistsController,
    required this.demographicController,
    required this.statusController,
    required this.serializationController,
    required this.originalPublisherController,
    required this.localizedPublisherController,
  });

  final MangaLibraryEntry? libraryEntry;

  String? rawOrSlabbed;
  String? signedBy;
  String? gradingCompany;
  String? graderNotes;
  String? labelType;
  String? customLabel;
  String? pageQuality;
  String? certificationNumber;
  bool obiStripPresent;
  bool slipcoverPresent;
  bool dustJacketPresent;
  String? dustJacketCondition;
  String? boxSetOuterCondition;
  bool insertsPresent;
  String? printing;
  String? localizedEdition;
  final TextEditingController pageCountController;
  final TextEditingController imprintController;
  final TextEditingController releaseDateController;
  final TextEditingController releaseYearController;
  final TextEditingController publisherController;
  final TextEditingController barcodeController;
  final TextEditingController volumeNumberController;
  final TextEditingController editionTitleController;
  final TextEditingController variantController;
  final TextEditingController physicalFormatController;
  final TextEditingController languageController;
  final TextEditingController countryController;
  final TextEditingController genresController;
  final TextEditingController themesController;
  final TextEditingController authorsController;
  final TextEditingController artistsController;
  final TextEditingController demographicController;
  final TextEditingController statusController;
  final TextEditingController serializationController;
  final TextEditingController originalPublisherController;
  final TextEditingController localizedPublisherController;

  @override
  JsonEncodable toDetailsDraft() => MangaEntryDetailsDraft(
        rawOrSlabbed: rawOrSlabbed,
        signedBy: signedBy,
        gradingCompany: gradingCompany,
        graderNotes: graderNotes,
        labelType: labelType,
        customLabel: customLabel,
        pageQuality: pageQuality,
        certificationNumber: certificationNumber,
        obiStripPresent: obiStripPresent,
        slipcoverPresent: slipcoverPresent,
        dustJacketPresent: dustJacketPresent,
        dustJacketCondition: dustJacketCondition,
        boxSetOuterCondition: boxSetOuterCondition,
        insertsPresent: insertsPresent,
        printing: printing,
        localizedEdition: localizedEdition,
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
  MangaLibraryEntryUpdatePayload buildEntryUpdatePayload({
    required LibraryEntryRef libraryEntryRef,
    required PersonalStateDraft personal,
  }) {
    return MangaLibraryEntryUpdatePayload(
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
      details: Patch.set(toDetailsDraft() as MangaEntryDetailsDraft),
    );
  }

  void dispose() {
    pageCountController.dispose();
    imprintController.dispose();
    releaseDateController.dispose();
    releaseYearController.dispose();
    publisherController.dispose();
    barcodeController.dispose();
    volumeNumberController.dispose();
    editionTitleController.dispose();
    variantController.dispose();
    physicalFormatController.dispose();
    languageController.dispose();
    countryController.dispose();
    genresController.dispose();
    themesController.dispose();
    authorsController.dispose();
    artistsController.dispose();
    demographicController.dispose();
    statusController.dispose();
    serializationController.dispose();
    originalPublisherController.dispose();
    localizedPublisherController.dispose();
  }

  @override
  LibraryEditSelection applyCanonicalEdits(
    LibraryEditSelection selection,
    LibraryEditFormFields fields,
  ) {
    final aliases = fields
        .controller(MangaCanonicalEditField.searchAliases)
        .text
        .split(RegExp(r'[,\r\n]+'))
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList();
    final metadata = mangaEditMetadataFromCandidate(selection.kindItem);
    final updatedMetadata = metadata.copyWith(
      title: fields.controller(MangaCanonicalEditField.title).text.trim(),
      originalTitle: emptyToNull(
          fields.controller(MangaCanonicalEditField.originalTitle).text),
      localizedTitle: emptyToNull(
          fields.controller(MangaCanonicalEditField.localizedTitle).text),
      searchAliases: aliases,
      synopsis:
          emptyToNull(fields.controller(MangaCanonicalEditField.synopsis).text),
      coverImageUrl: emptyToNull(
          fields.controller(MangaCanonicalEditField.coverImage).text),
      thumbnailImageUrl: emptyToNull(
          fields.controller(MangaCanonicalEditField.thumbnailImage).text),
      sortKey: emptyToNull(
        fields.controller(MangaCanonicalEditField.sortTitle).text,
      ),
    );
    return selection.copyWith(
      kindItem:
          selection.kindItem.kindCapability.replacingKindData(updatedMetadata),
    );
  }

  @override
  LibraryEditFormSchema buildCanonicalFormSchema(
    LibraryEditFormFields fields,
    CatalogSearchCandidate item,
  ) {
    final metadata = item.mangaCatalogFields;
    fields.create(MangaCanonicalEditField.title, initialValue: metadata.title);
    fields.create(MangaCanonicalEditField.sortTitle,
        initialValue: metadata.sortKey ?? '');
    fields.create(MangaCanonicalEditField.originalTitle,
        initialValue: metadata.originalTitle ?? '');
    fields.create(MangaCanonicalEditField.localizedTitle,
        initialValue: metadata.localizedTitle ?? '');
    fields.create(MangaCanonicalEditField.searchAliases,
        initialValue: metadata.searchAliases.join(', '));
    fields.create(MangaCanonicalEditField.synopsis,
        initialValue: metadata.synopsis ?? '');
    fields.create(MangaCanonicalEditField.coverImage,
        initialValue: metadata.coverImageUrl ?? '');
    fields.create(MangaCanonicalEditField.thumbnailImage,
        initialValue: metadata.thumbnailImageUrl ?? '');
    return LibraryEditFormSchema(
      fields: [
        LibraryEditFormFieldSpec(
          id: MangaCanonicalEditField.title,
          section: LibraryEditFormSection.details,
          controller: fields.controller(MangaCanonicalEditField.title),
          label: 'Title',
          required: true,
        ),
        LibraryEditFormFieldSpec(
          id: MangaCanonicalEditField.sortTitle,
          section: LibraryEditFormSection.details,
          controller: fields.controller(MangaCanonicalEditField.sortTitle),
          label: 'Sort Title',
        ),
        LibraryEditFormFieldSpec(
          id: MangaCanonicalEditField.originalTitle,
          section: LibraryEditFormSection.details,
          controller: fields.controller(MangaCanonicalEditField.originalTitle),
          label: 'Original Title',
        ),
        LibraryEditFormFieldSpec(
          id: MangaCanonicalEditField.localizedTitle,
          section: LibraryEditFormSection.details,
          controller: fields.controller(MangaCanonicalEditField.localizedTitle),
          label: 'Localized title',
        ),
        LibraryEditFormFieldSpec(
          id: MangaCanonicalEditField.searchAliases,
          section: LibraryEditFormSection.details,
          controller: fields.controller(MangaCanonicalEditField.searchAliases),
          label: 'Search Aliases',
          visible: false,
        ),
        LibraryEditFormFieldSpec(
          id: MangaCanonicalEditField.thumbnailImage,
          section: LibraryEditFormSection.details,
          controller: fields.controller(MangaCanonicalEditField.thumbnailImage),
          label: 'Thumbnail image URL',
          visible: false,
        ),
        LibraryEditFormFieldSpec(
          id: MangaCanonicalEditField.coverImage,
          section: LibraryEditFormSection.artwork,
          controller: fields.controller(MangaCanonicalEditField.coverImage),
          label: 'Cover Image URL',
        ),
        LibraryEditFormFieldSpec(
          id: MangaCanonicalEditField.synopsis,
          section: LibraryEditFormSection.description,
          controller: fields.controller(MangaCanonicalEditField.synopsis),
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
    final meta = mangaEditMetadataFromCandidate(selection.kindItem);
    final count = int.tryParse(pageCountController.text);
    final volumeNumber = int.tryParse(volumeNumberController.text);
    final impr = emptyToNull(imprintController.text);
    final pub = emptyToNull(publisherController.text);
    final barcode = emptyToNull(barcodeController.text);
    final format = emptyToNull(physicalFormatController.text);
    final variant = emptyToNull(variantController.text);
    final editionTitle = emptyToNull(editionTitleController.text);
    final originalPublisher = emptyToNull(originalPublisherController.text);
    final localizedPublisher = emptyToNull(localizedPublisherController.text);
    final language = emptyToNull(languageController.text);
    final country = emptyToNull(countryController.text);
    final demographic = emptyToNull(demographicController.text);
    final status = emptyToNull(statusController.text);
    final serialization = emptyToNull(serializationController.text);

    final releaseDateText = releaseDateController.text.trim();
    final releaseYear = int.tryParse(releaseYearController.text.trim());
    final releaseDate = releaseDateText.isEmpty
        ? (releaseYear == null || releaseYear < 1
            ? null
            : PartialDate(year: releaseYear))
        : PartialDate.tryParse(releaseDateText);
    final updatedMetadata = MangaMetadata.fromJson(applyJsonFieldPatch(meta, {
      'page_count': count,
      'volume_number': volumeNumber?.toString(),
      'edition_title': editionTitle,
      'variant_name': variant,
      'imprint': impr,
      'publisher': pub,
      'original_publisher': originalPublisher,
      'localized_publisher': localizedPublisher,
      'barcode': barcode,
      'isbn': barcode,
      'physical_format_label': format,
      'physical_format': format,
      'edition_format': format == null
          ? meta.editionFormat.name
          : MangaEditionFormat.fromString(format).name,
      'language': language ?? meta.language,
      'country': country ?? meta.country,
      'genres': _splitValues(genresController.text),
      'themes': _splitValues(themesController.text),
      'authors': _splitValues(authorsController.text),
      'artists': _splitValues(artistsController.text),
      'demographic': demographic == null
          ? meta.demographic.name
          : MangaDemographic.fromString(demographic).name,
      'publication_status': status == null
          ? meta.publicationStatus.name
          : MangaPublicationStatus.fromString(status).name,
      'serialization_platform': serialization,
      'release_date': null,
      'release_date_parts': releaseDate?.toJson(),
    }));

    final updatedItem = selection.kindItem.kindCapability.mapTransport(
      (transport) => CatalogSearchCandidate.fromItem(
        transport.replacingKindData(
          mangaEditKindMetadataForCandidate(
            selection.kindItem,
            updatedMetadata,
          ),
        ),
      ),
    );
    return selection.copyWith(kindItem: updatedItem);
  }
}

LibraryEditSessionBundle createMangaEditDraft({
  required CatalogSearchCandidate item,
  LibraryEntryDispatch? libraryEntryDispatch,
  TrackingSummary? trackingSummary,
  required TextControllerGroup textControllers,
}) {
  final entry = MangaLibraryEntryProjection.fromDispatch(libraryEntryDispatch);
  final manga = entry?.personal.details;
  final metadata = mangaEditMetadataFromCandidate(item);
  final draft = MangaEditDraft(
    libraryEntry: entry,
    rawOrSlabbed: manga?.grading.rawOrSlabbed,
    signedBy: manga?.signedBy,
    gradingCompany: manga?.gradingCompany,
    graderNotes: manga?.graderNotes,
    labelType: manga?.grading.labelType,
    customLabel: manga?.grading.customLabel,
    pageQuality: manga?.grading.pageQuality,
    certificationNumber: manga?.grading.certificationNumber,
    obiStripPresent: manga?.obiStripPresent ?? false,
    slipcoverPresent: manga?.slipcoverPresent ?? false,
    dustJacketPresent: manga?.dustJacketPresent ?? false,
    dustJacketCondition: manga?.dustJacketCondition,
    boxSetOuterCondition: manga?.boxSetOuterCondition,
    insertsPresent: manga?.insertsPresent ?? false,
    printing: manga?.printing,
    localizedEdition: manga?.localizedEdition,
    pageCountController: textControllers.create(
      text: metadata.pageCount?.toString() ?? '',
    ),
    imprintController: textControllers.create(
      text: metadata.imprint ?? '',
    ),
    publisherController: textControllers.create(
      text: metadata.publisher ??
          metadata.localizedPublisher ??
          metadata.originalPublisher ??
          '',
    ),
    barcodeController: textControllers.create(
      text: metadata.barcode ?? metadata.isbn ?? '',
    ),
    volumeNumberController: textControllers.create(
      text: metadata.volumeNumber?.toString() ?? '',
    ),
    editionTitleController: textControllers.create(
      text: metadata.editionTitle ?? '',
    ),
    variantController: textControllers.create(
      text: metadata.variant ?? '',
    ),
    physicalFormatController: textControllers.create(
      text: metadata.physicalFormatLabel ??
          metadata.physicalFormat ??
          metadata.editionFormat.label,
    ),
    languageController: textControllers.create(text: metadata.language),
    countryController: textControllers.create(text: metadata.country),
    genresController: textControllers.create(
      text: metadata.genres.join(', '),
    ),
    themesController: textControllers.create(
      text: metadata.themes.join(', '),
    ),
    authorsController: textControllers.create(
      text: metadata.authors.join(', '),
    ),
    artistsController: textControllers.create(
      text: metadata.artists.join(', '),
    ),
    demographicController: textControllers.create(
      text: metadata.demographic.label,
    ),
    statusController: textControllers.create(
      text: metadata.publicationStatus.label,
    ),
    serializationController: textControllers.create(
      text: metadata.serializationPlatform ?? '',
    ),
    originalPublisherController: textControllers.create(
      text: metadata.originalPublisher ?? '',
    ),
    localizedPublisherController: textControllers.create(
      text: metadata.localizedPublisher ?? '',
    ),
    releaseDateController: textControllers.create(
      text: metadata.releaseDateParts?.isoString ??
          metadata.releaseDate?.isoString ??
          '',
    ),
    releaseYearController: textControllers.create(
      text: metadata.releaseDateParts?.year?.toString() ??
          metadata.releaseDate?.year?.toString() ??
          '',
    ),
  );
  return LibraryEditSessionBundle(
    catalogItemSession: draft,
    entrySession: draft,
    disposeSession: draft.dispose,
  );
}

/// Decodes the flat Manga Catalog Item payload for editing.
MangaMetadata mangaEditMetadataFromCandidate(CatalogSearchCandidate item) {
  final transport = item.kindCapability.mapTransport((transport) => transport);
  return MangaMetadata.fromJson(transport.payload);
}

MangaMetadata mangaEditKindMetadataForCandidate(
  CatalogSearchCandidate item,
  MangaMetadata metadata,
) {
  return metadata;
}

List<String> _splitValues(String value) => value
    .split(RegExp(r'[,\r\n]+'))
    .map((entry) => entry.trim())
    .where((entry) => entry.isNotEmpty)
    .toSet()
    .toList();
