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

class BookEditDraft extends KindEditDraft {
  BookEditDraft({
    this.signedBy,
    this.dustJacketPresent = false,
    this.dustJacketCondition,
    required this.pageCountController,
    required this.imprintController,
  });

  String? signedBy;
  bool dustJacketPresent;
  String? dustJacketCondition;
  final TextEditingController pageCountController;
  final TextEditingController imprintController;

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
      dustJacketCondition: existing.dustJacketCondition,
      dustJacket: existing.dustJacket,
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

KindEditDraft createBookEditDraft({
  required LibraryMetadataItem item,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
  required TextControllerGroup textControllers,
}) {
  final book = ownedItem?.bookDetails;
  final comic = ownedItem?.comicDetails;
  return BookEditDraft(
    signedBy: book?.signedBy ?? comic?.signedBy,
    dustJacketPresent: book?.dustJacketPresent ?? false,
    dustJacketCondition: book?.dustJacketCondition,
    pageCountController: textControllers.create(
      text: item.publishing?.pageCount?.toString() ?? '',
    ),
    imprintController: textControllers.create(
      text: item.publishing?.imprint ?? '',
    ),
  );
}
