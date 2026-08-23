import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/edit/draft/kind_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter/material.dart';

class MusicEditDraft extends KindEditDraft {
  MusicEditDraft({
    required this.storageDeviceController,
    required this.storageSlotController,
    this.signedBy,
    this.lastCleaned,
  });

  final TextEditingController storageDeviceController;
  final TextEditingController storageSlotController;
  String? signedBy;
  DateTime? lastCleaned;

  @override
  OwnedDetailsDraft toDetailsDraft() => MusicOwnedDetailsDraft(
        storageDevice: emptyToNull(storageDeviceController.text),
        storageSlot: emptyToNull(storageSlotController.text),
        signedBy: signedBy,
        lastCleanedDate: lastCleaned,
      );

  @override
  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) {
    if (selection.personal != null) {
      return selection.copyWith(
        personal: selection.personal!.copyWith(
          signedBy: signedBy,
          storageDevice: emptyToNull(storageDeviceController.text),
          storageSlot: emptyToNull(storageSlotController.text),
        ),
      );
    }
    return selection;
  }
}

KindEditDraft createMusicEditDraft({
  required LibraryMetadataItem item,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
  required TextControllerGroup textControllers,
}) {
  final music = ownedItem?.musicDetails;
  return MusicEditDraft(
    storageDeviceController:
        textControllers.create(text: music?.storageDevice ?? ''),
    storageSlotController:
        textControllers.create(text: music?.storageSlot ?? ''),
    signedBy: music?.signedBy,
    lastCleaned: music?.lastCleanedDate,
  );
}
