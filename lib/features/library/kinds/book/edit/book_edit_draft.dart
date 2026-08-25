import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_publishing_details_dto.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/edit/draft/kind_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
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

    final updatedPublishing = meta?.publishing != null
        ? meta!.publishing!.copyWith(
            pageCount: count ?? meta.publishing?.pageCount,
            imprint: impr ?? meta.publishing?.imprint,
          )
        : ((count != null || impr != null)
            ? CatalogPublishingDetailsDto(
                imprint: impr,
                pageCount: count,
              )
            : null);

    final updatedMetadata = meta?.copyWith(
      publishing: updatedPublishing != null && updatedPublishing.hasData ? updatedPublishing : null,
      links: _externalLinks.isNotEmpty ? _externalLinks : meta.links,
    ) ?? selection.item.kindMetadata;

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

KindEditDraft createBookEditDraft({
  required LibraryMetadataItem item,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
  required TextControllerGroup textControllers,
}) {
  final book = ownedItem?.bookDetails;
  final comic = ownedItem?.comicDetails;
  final rawMetadata = item.kindMetadata;
  final BookCatalogMetadata metadata;
  if (rawMetadata is BookCatalogMetadata) {
    metadata = rawMetadata;
  } else {
    metadata = BookCatalogMetadata.fromJson(rawMetadata.toSyncPayload());
  }
  return BookEditDraft(
    signedBy: book?.signedBy ?? comic?.signedBy,
    dustJacketPresent: book?.dustJacketPresent ?? false,
    dustJacketCondition: book?.dustJacketCondition,
    pageCountController: textControllers.create(
      text: metadata.publishing?.pageCount?.toString() ?? '',
    ),
    imprintController: textControllers.create(
      text: metadata.publishing?.imprint ?? '',
    ),
  );
}
