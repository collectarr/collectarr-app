import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/edit/draft/kind_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter/material.dart';

import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';

class MangaEditDraft extends KindEditDraft {
  MangaEditDraft({
    this.signedBy,
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
  });

  String? signedBy;
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

  @override
  OwnedDetailsDraft toDetailsDraft() => MangaOwnedDetailsDraft(
        signedBy: signedBy,
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
  }

  @override
  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) {
    final meta = selection.item.kindMetadata is MangaMetadata
        ? (selection.item.kindMetadata as MangaMetadata)
        : null;
    final count = int.tryParse(pageCountController.text);
    final impr = emptyToNull(imprintController.text);
    final pub = emptyToNull(publisherController.text);
    final barcode = emptyToNull(barcodeController.text);

    final updatedMetadata = meta?.copyWith(
          pageCount: count ?? meta.pageCount,
          imprint: impr ?? meta.imprint,
          publisher: pub ?? meta.publisher,
          barcode: barcode ?? meta.barcode,
          localizedPublisher: pub ?? meta.localizedPublisher,
          isbn: barcode ?? meta.isbn,
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
          signedBy: signedBy,
        ),
      );
    }
    return result;
  }
}

KindEditDraft createMangaEditDraft({
  required LibraryMetadataItem item,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
  required TextControllerGroup textControllers,
}) {
  final manga = ownedItem?.mangaDetails;
  final rawMetadata = item.kindMetadata;
  final MangaMetadata? metadata =
      rawMetadata is MangaMetadata ? rawMetadata : null;
  return MangaEditDraft(
    signedBy: manga?.signedBy,
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
      text: metadata?.publisher ?? metadata?.localizedPublisher ?? metadata?.originalPublisher ?? '',
    ),
    barcodeController: textControllers.create(
      text: metadata?.barcode ?? metadata?.isbn ?? '',
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
