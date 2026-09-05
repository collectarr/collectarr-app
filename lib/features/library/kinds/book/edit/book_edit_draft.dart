import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/edit/draft/kind_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:flutter/material.dart';

class BookEditDraft extends KindEditDraft {
  BookEditDraft({
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
  OwnedDetailsDraft toDetailsDraft() => BookOwnedDetailsDraft(
        signedBy: signedBy,
        dustJacketPresent: dustJacketPresent,
        dustJacketCondition: dustJacketCondition,
      );

  @override
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

  List<TrailerLink> _externalLinks = const [];

  @override
  void setExternalLinks(List<TrailerLinkDto> links) {
    _externalLinks = links;
  }

  @override
  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) {
    final meta = selection.item.kindMetadata is BookCatalogMetadata
        ? (selection.item.kindMetadata as BookCatalogMetadata)
        : null;
    final count = int.tryParse(pageCountController.text);
    final impr = emptyToNull(imprintController.text);
    final pub = emptyToNull(publisherController.text);
    final barcode = emptyToNull(barcodeController.text);
    final editionTitle = emptyToNull(editionTitleController.text);
    final variant = emptyToNull(variantController.text);
    final format = emptyToNull(formatController.text);
    final language = emptyToNull(languageController.text);
    final country = emptyToNull(countryController.text);

    final updatedPublishing = meta?.publishing != null
        ? meta!.publishing!.copyWith(
            pageCount: count ?? meta.publishing?.pageCount,
            imprint: impr ?? meta.publishing?.imprint,
            originalPublisher: pub ?? meta.publishing?.originalPublisher,
          )
        : ((count != null || impr != null || pub != null)
            ? CatalogPublishingDetailsDto(
                imprint: impr,
                pageCount: count,
                originalPublisher: pub,
              )
            : null);

    final updatedMetadata = meta?.copyWith(
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
          subjects:
              _splitValues(subjectsController.text, fallback: meta.subjects),
          translators: _splitValues(
            translatorsController.text,
            fallback: meta.translators,
          ),
          originalPublicationDate: parseDate(releaseDateController.text) ??
              meta.originalPublicationDate,
          publishing: updatedPublishing != null && updatedPublishing.hasData
              ? updatedPublishing
              : null,
          links: _externalLinks.isNotEmpty ? _externalLinks : meta.links,
        ) ??
        selection.item.kindMetadata;

    final updatedItem = selection.item.copyWith(
      kindMetadata: updatedMetadata,
    );
    var result = selection.copyWith(item: updatedItem);
    if (result.personal != null) {
      result = result.copyWith(
        personal: result.personal!.copyWith(
          signedBy: signedBy,
          dustJacketPresent: dustJacketPresent,
          dustJacketCondition: dustJacketCondition,
        ),
      );
    }
    return result;
  }
}

KindEditDraft createBookEditDraft({
  required CatalogItem item,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
  required TextControllerGroup textControllers,
}) {
  final ownedDetails = ownedItem?.details;
  final book = ownedDetails is BookOwnedDetails ? ownedDetails : null;
  final rawMetadata = item.kindMetadata;
  final BookCatalogMetadata? metadata =
      rawMetadata is BookCatalogMetadata ? rawMetadata : null;
  return BookEditDraft(
    signedBy: book?.signedBy,
    dustJacketPresent: book?.dustJacketPresent ?? false,
    dustJacketCondition: book?.dustJacketCondition,
    pageCountController: textControllers.create(
      text: metadata?.publishing?.pageCount?.toString() ?? '',
    ),
    imprintController: textControllers.create(
      text: metadata?.publishing?.imprint ?? '',
    ),
    publisherController: textControllers.create(
      text:
          metadata?.publisher ?? metadata?.publishing?.originalPublisher ?? '',
    ),
    barcodeController: textControllers.create(
      text: metadata?.barcode ?? '',
    ),
    releaseDateController: textControllers.create(
      text: metadata?.originalPublicationDate != null
          ? formatDate(metadata!.originalPublicationDate!)
          : '',
    ),
    releaseYearController: textControllers.create(
      text: metadata?.originalPublicationDate?.year.toString() ?? '',
    ),
    editionTitleController: textControllers.create(
      text: metadata?.editionTitle ?? '',
    ),
    variantController: textControllers.create(
      text: metadata?.variant ?? '',
    ),
    formatController: textControllers.create(
      text: metadata?.physicalFormatLabel ?? metadata?.physicalFormat ?? '',
    ),
    languageController: textControllers.create(
      text: metadata?.language ?? '',
    ),
    countryController: textControllers.create(
      text: metadata?.country ?? '',
    ),
    authorsController: textControllers.create(
      text: metadata?.authors.join(', ') ?? '',
    ),
    genresController: textControllers.create(
      text: metadata?.genres.join(', ') ?? '',
    ),
    subjectsController: textControllers.create(
      text: metadata?.subjects.join(', ') ?? '',
    ),
    translatorsController: textControllers.create(
      text: metadata?.translators.join(', ') ?? '',
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
