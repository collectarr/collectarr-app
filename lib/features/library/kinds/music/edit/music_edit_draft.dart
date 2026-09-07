import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/config/owned_details_draft.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_edit_kind_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_metadata.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/edit/draft/personal_state_draft.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:flutter/material.dart';

class MusicExternalLinkEdit {
  MusicExternalLinkEdit({
    String url = '',
    String description = '',
  })  : urlController = TextEditingController(text: url),
        descriptionController = TextEditingController(text: description);

  final TextEditingController urlController;
  final TextEditingController descriptionController;

  void dispose() {
    urlController.dispose();
    descriptionController.dispose();
  }
}

class MusicEditDraft extends LibraryEditKindDraft {
  MusicEditDraft({
    required this.storageDeviceController,
    required this.storageSlotController,
    this.signedBy,
    this.lastCleaned,
    List<MusicExternalLinkEdit>? externalLinks,
  }) : externalLinks = externalLinks ?? <MusicExternalLinkEdit>[];

  final TextEditingController storageDeviceController;
  final TextEditingController storageSlotController;
  String? signedBy;
  DateTime? lastCleaned;
  final List<MusicExternalLinkEdit> externalLinks;

  void addExternalLink() {
    externalLinks.add(MusicExternalLinkEdit());
  }

  void removeExternalLinkAt(int index) {
    if (index >= 0 && index < externalLinks.length) {
      final removed = externalLinks.removeAt(index);
      removed.dispose();
    }
  }

  void moveExternalLink(int fromIndex, int toIndex) {
    if (toIndex >= 0 && toIndex < externalLinks.length) {
      final entry = externalLinks.removeAt(fromIndex);
      externalLinks.insert(toIndex, entry);
    }
  }

  @override
  OwnedDetailsDraft toDetailsDraft() => MusicOwnedDetailsDraft(
        storageDevice: emptyToNull(storageDeviceController.text),
        storageSlot: emptyToNull(storageSlotController.text),
        signedBy: signedBy,
        lastCleanedDate: lastCleaned,
      );

  @override
  MusicOwnedItemUpdatePayload buildOwnedUpdatePayload({
    required String ownedItemId,
    required PersonalStateDraft personal,
  }) {
    return MusicOwnedItemUpdatePayload(
      anchor: Patch.set(PersonalItemAnchor.fromRaw(
        anchorType: personal.selectedOwnedAnchorType.apiValue,
        editionId: personal.selectedEditionId,
        variantId: personal.selectedVariantId,
        bundleReleaseId: personal.selectedBundleReleaseId,
      )),
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
      details: Patch.set(toDetailsDraft() as MusicOwnedDetailsDraft),
    );
  }

  @override
  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) {
    var result = selection;
    if (result.personal != null) {
      result = result.copyWith(
        personal: result.personal!.copyWith(
          signedBy: signedBy,
          storageDevice: emptyToNull(storageDeviceController.text),
          storageSlot: emptyToNull(storageSlotController.text),
        ),
      );
    }
    return result;
  }
}

LibraryEditKindDraft createMusicEditDraft({
  required CatalogItem item,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
  required TextControllerGroup textControllers,
}) {
  final music = ownedItem?.details as MusicOwnedDetails?;
  final meta = item.kindMetadata is MusicCatalogMetadata
      ? item.kindMetadata as MusicCatalogMetadata
      : null;
  final externalLinks = [
    for (final link in (meta?.links ?? const <TrailerLink>[])
        .where((l) => l.isExternalLink))
      MusicExternalLinkEdit(
        url: link.url,
        description: link.description ?? link.title ?? '',
      ),
  ];

  return MusicEditDraft(
    storageDeviceController:
        textControllers.create(text: music?.storageDevice ?? ''),
    storageSlotController:
        textControllers.create(text: music?.storageSlot ?? ''),
    signedBy: music?.signedBy,
    lastCleaned: music?.lastCleanedDate,
    externalLinks: externalLinks,
  );
}
