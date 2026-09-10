import 'package:collectarr_app/core/models/tracking_lifecycle.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_edit_kind_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_metadata.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/edit/draft/personal_state_draft.dart';
import 'package:collectarr_app/features/library/config/catalog_reference_helpers.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/library_add_catalog_item.dart';
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
    this.ownedItem,
    required this.storageDeviceController,
    required this.storageSlotController,
    this.signedBy,
    this.lastCleaned,
    List<MusicExternalLinkEdit>? externalLinks,
  }) : externalLinks = externalLinks ?? <MusicExternalLinkEdit>[];

  final MusicOwnedItem? ownedItem;

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
  JsonEncodable toDetailsDraft() => MusicOwnedDetailsDraft(
        storageDevice: emptyToNull(storageDeviceController.text),
        storageSlot: emptyToNull(storageSlotController.text),
        signedBy: signedBy,
        lastCleanedDate: lastCleaned,
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
  MusicOwnedItemUpdatePayload buildOwnedUpdatePayload({
    required String ownedItemId,
    required PersonalStateDraft personal,
  }) {
    final targetRef = catalogRefForOwnedSelection(
      CatalogMediaKind.music,
      anchorType: personal.selectedOwnedAnchorType,
      editionId: personal.selectedEditionId,
      variantId: personal.selectedVariantId,
      bundleReleaseId: personal.selectedBundleReleaseId,
    );
    return MusicOwnedItemUpdatePayload(
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
      details: Patch.set(toDetailsDraft() as MusicOwnedDetailsDraft),
    );
  }

  @override
  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) {
    return selection;
  }
}

LibraryEditKindDraft createMusicEditDraft({
  required LibraryAddCatalogItem item,
  Object? typedOwnedItem,
  TrackingLifecycle? trackingLifecycle,
  required TextControllerGroup textControllers,
}) {
  final owned = MusicOwnedItemProjection.tryFromTyped(typedOwnedItem);
  final music = owned?.details;
  final meta = item.kindMetadata is MusicCatalogMetadata
      ? item.kindMetadata as MusicCatalogMetadata
      : null;
  final externalLinks = [
    for (final link in (meta?.links ?? const <TrailerLinkDto>[])
        .where((l) => l.isExternalLink))
      MusicExternalLinkEdit(
        url: link.url,
        description: link.description ?? link.title ?? '',
      ),
  ];

  return MusicEditDraft(
    ownedItem: owned,
    storageDeviceController:
        textControllers.create(text: music?.storageDevice ?? ''),
    storageSlotController:
        textControllers.create(text: music?.storageSlot ?? ''),
    signedBy: music?.signedBy,
    lastCleaned: music?.lastCleanedDate,
    externalLinks: externalLinks,
  );
}
