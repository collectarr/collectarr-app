import 'package:collectarr_app/core/models/tracking_lifecycle.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_edit_kind_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/catalog/transport/library_add_catalog_transport.dart';
import 'package:flutter/material.dart';

import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/edit/draft/personal_state_draft.dart';
import 'package:collectarr_app/features/library/config/catalog_reference_helpers.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

class MangaEditDraft extends LibraryEditKindDraft {
  MangaEditDraft({
    this.ownedItem,
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

  final MangaOwnedItem? ownedItem;

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
  JsonEncodable toDetailsDraft() => MangaOwnedDetailsDraft(
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
  MangaOwnedItemUpdatePayload buildOwnedUpdatePayload({
    required String ownedItemId,
    required PersonalStateDraft personal,
  }) {
    final targetRef = catalogRefForOwnedSelection(
      CatalogMediaKind.manga,
      anchorType: personal.selectedOwnedAnchorType,
      editionId: personal.selectedEditionId,
      variantId: personal.selectedVariantId,
      bundleReleaseId: personal.selectedBundleReleaseId,
    );
    return MangaOwnedItemUpdatePayload(
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
      details: Patch.set(toDetailsDraft() as MangaOwnedDetailsDraft),
    );
  }

  @override
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
  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) {
    final meta = selection.item.toTransportItem().kindMetadata is MangaMetadata
        ? (selection.item.toTransportItem().kindMetadata as MangaMetadata)
        : null;
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

    final updatedMetadata = meta?.copyWith(
          pageCount: count ?? meta.pageCount,
          volumeNumber: volumeNumber ?? meta.volumeNumber,
          itemNumber: volumeNumber?.toString() ?? meta.itemNumber,
          editionTitle: editionTitle ?? meta.editionTitle,
          variant: variant ?? meta.variant,
          imprint: impr ?? meta.imprint,
          publisher: pub ?? meta.publisher,
          originalPublisher: originalPublisher ?? meta.originalPublisher,
          localizedPublisher: localizedPublisher ?? meta.localizedPublisher,
          barcode: barcode ?? meta.barcode,
          isbn: barcode ?? meta.isbn,
          physicalFormatLabel: format ?? meta.physicalFormatLabel,
          physicalFormat: format ?? meta.physicalFormat,
          editionFormat: format == null
              ? meta.editionFormat
              : MangaEditionFormat.fromString(format),
          language: language ?? meta.language,
          country: country ?? meta.country,
          genres: _splitValues(genresController.text, fallback: meta.genres),
          themes: _splitValues(themesController.text, fallback: meta.themes),
          authors: _splitValues(authorsController.text, fallback: meta.authors),
          artists: _splitValues(artistsController.text, fallback: meta.artists),
          demographic: demographic == null
              ? meta.demographic
              : MangaDemographic.fromString(demographic),
          publicationStatus: status == null
              ? meta.publicationStatus
              : MangaPublicationStatus.fromString(status),
          serializationPlatform: serialization ?? meta.serializationPlatform,
          localizedReleaseDate: parseDate(releaseDateController.text) ??
              meta.localizedReleaseDate,
        ) ??
        selection.item.toTransportItem().kindMetadata;

    final updatedItem = selection.item.copyWith(
      kindMetadata: updatedMetadata,
    );
    return selection.copyWith(item: updatedItem);
  }
}

LibraryEditKindDraft createMangaEditDraft({
  required LibraryAddCatalogTransport item,
  Object? typedOwnedItem,
  TrackingLifecycle? trackingLifecycle,
  required TextControllerGroup textControllers,
}) {
  final owned = MangaOwnedItemProjection.tryFromTyped(typedOwnedItem);
  final manga = owned?.details;
  final rawMetadata = item.toTransportItem().kindMetadata;
  final MangaMetadata? metadata =
      rawMetadata is MangaMetadata ? rawMetadata : null;
  return MangaEditDraft(
    ownedItem: owned,
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
      text: metadata?.pageCount?.toString() ?? '',
    ),
    imprintController: textControllers.create(
      text: metadata?.imprint ?? '',
    ),
    publisherController: textControllers.create(
      text: metadata?.publisher ??
          metadata?.localizedPublisher ??
          metadata?.originalPublisher ??
          '',
    ),
    barcodeController: textControllers.create(
      text: metadata?.barcode ?? metadata?.isbn ?? '',
    ),
    volumeNumberController: textControllers.create(
      text: metadata?.itemNumber ?? metadata?.volumeNumber?.toString() ?? '',
    ),
    editionTitleController: textControllers.create(
      text: metadata?.editionTitle ?? '',
    ),
    variantController: textControllers.create(
      text: metadata?.variant ?? '',
    ),
    physicalFormatController: textControllers.create(
      text: metadata?.physicalFormatLabel ??
          metadata?.physicalFormat ??
          metadata?.editionFormat.label ??
          '',
    ),
    languageController: textControllers.create(text: metadata?.language ?? ''),
    countryController: textControllers.create(text: metadata?.country ?? ''),
    genresController: textControllers.create(
      text: metadata?.genres.join(', ') ?? '',
    ),
    themesController: textControllers.create(
      text: metadata?.themes.join(', ') ?? '',
    ),
    authorsController: textControllers.create(
      text: metadata?.authors.join(', ') ?? '',
    ),
    artistsController: textControllers.create(
      text: metadata?.artists.join(', ') ?? '',
    ),
    demographicController: textControllers.create(
      text: metadata?.demographic.label ?? '',
    ),
    statusController: textControllers.create(
      text: metadata?.publicationStatus.label ?? '',
    ),
    serializationController: textControllers.create(
      text: metadata?.serializationPlatform ?? '',
    ),
    originalPublisherController: textControllers.create(
      text: metadata?.originalPublisher ?? '',
    ),
    localizedPublisherController: textControllers.create(
      text: metadata?.localizedPublisher ?? '',
    ),
    releaseDateController: textControllers.create(
      text: metadata?.localizedReleaseDate != null
          ? formatDate(metadata!.localizedReleaseDate!)
          : (metadata?.originalPublicationDate != null
              ? formatDate(metadata!.originalPublicationDate!)
              : ''),
    ),
    releaseYearController: textControllers.create(
      text: metadata?.localizedReleaseDate?.year.toString() ??
          metadata?.originalPublicationDate?.year.toString() ??
          '',
    ),
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
