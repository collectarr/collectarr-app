import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/edit/draft/kind_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:flutter/material.dart';

import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';

class MangaEditDraft extends KindEditDraft {
  MangaEditDraft({
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
  OwnedDetailsDraft toDetailsDraft() => MangaOwnedDetailsDraft(
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
    final meta = selection.item.kindMetadata is MangaMetadata
        ? (selection.item.kindMetadata as MangaMetadata)
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
        selection.item.kindMetadata;

    final updatedItem = selection.item.copyWith(
      kindMetadata: updatedMetadata,
    );
    var result = selection.copyWith(item: updatedItem);
    if (result.personal != null) {
      result = result.copyWith(
        personal: result.personal!.copyWith(
          rawOrSlabbed: rawOrSlabbed,
          gradingCompany: gradingCompany,
          graderNotes: graderNotes,
          signedBy: signedBy,
          labelType: labelType,
          customLabel: customLabel,
          pageQuality: pageQuality,
          certificationNumber: certificationNumber,
        ),
      );
    }
    return result;
  }
}

KindEditDraft createMangaEditDraft({
  required CatalogItem item,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
  required TextControllerGroup textControllers,
}) {
  final manga = ownedItem?.details as MangaOwnedDetails?;
  final rawMetadata = item.kindMetadata;
  final MangaMetadata? metadata =
      rawMetadata is MangaMetadata ? rawMetadata : null;
  return MangaEditDraft(
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
