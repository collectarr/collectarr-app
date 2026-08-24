import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/edit/draft/kind_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter/material.dart';

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
  }

  @override
  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) {
    final existing =
        selection.item.publishing ?? const CatalogPublishingDetails();
    final updatedPublishing = CatalogPublishingDetails(
      pageCount: int.tryParse(pageCountController.text) ?? existing.pageCount,
      coverPriceCents: existing.coverPriceCents,
      currency: existing.currency,
      imprint: emptyToNull(imprintController.text) ?? existing.imprint,
      subtitle: existing.subtitle,
      seriesGroup: existing.seriesGroup,
      publicationPlace: existing.publicationPlace,
      originalCountry: existing.originalCountry,
      originalLanguage: existing.originalLanguage,
      originalPublicationDate: existing.originalPublicationDate,
      originalPublicationPlace: existing.originalPublicationPlace,
      originalPublisher: existing.originalPublisher,
      paperType: existing.paperType,
      printedBy: existing.printedBy,
      subjects: existing.subjects,
      dustJacketCondition: dustJacketCondition ?? existing.dustJacketCondition,
      dustJacket: dustJacketPresent ? true : existing.dustJacket,
      audiobookAbridged: existing.audiobookAbridged,
      firstEdition: existing.firstEdition,
      dewey: existing.dewey,
    );
    var result = selection.copyWith(
      item: selection.item.copyWith(
        publishing: updatedPublishing.hasData
            ? updatedPublishing
            : selection.item.publishing,
      ),
    );
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
      text: item.publishing?.pageCount?.toString() ?? '',
    ),
    imprintController: textControllers.create(
      text: item.publishing?.imprint ?? '',
    ),
  );
}
