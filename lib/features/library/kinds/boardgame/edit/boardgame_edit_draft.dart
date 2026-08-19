import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/edit/draft/kind_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter/material.dart';

class BoardGameEditDraft extends KindEditDraft {
  BoardGameEditDraft({
    required this.editionLanguageController,
    required this.editionRegionController,
    required this.componentConditionController,
    required this.componentCompletenessController,
    required this.missingPiecesNotesController,
    required this.storageNotesController,
    this.isSleeved = false,
    this.hasCustomInsert = false,
    this.hasPaintedMiniatures = false,
  });

  final TextEditingController editionLanguageController;
  final TextEditingController editionRegionController;
  final TextEditingController componentConditionController;
  final TextEditingController componentCompletenessController;
  final TextEditingController missingPiecesNotesController;
  final TextEditingController storageNotesController;
  final bool isSleeved;
  final bool hasCustomInsert;
  final bool hasPaintedMiniatures;

  @override
  OwnedDetailsDraft toDetailsDraft() => BoardgameOwnedDetailsDraft(
        editionLanguage: editionLanguageController.text.trim().isEmpty
            ? null
            : editionLanguageController.text.trim(),
        editionRegion: editionRegionController.text.trim().isEmpty
            ? null
            : editionRegionController.text.trim(),
        componentCondition: componentConditionController.text.trim().isEmpty
            ? null
            : componentConditionController.text.trim(),
        componentCompleteness:
            componentCompletenessController.text.trim().isEmpty
                ? null
                : componentCompletenessController.text.trim(),
        missingPiecesNotes: missingPiecesNotesController.text.trim().isEmpty
            ? null
            : missingPiecesNotesController.text.trim(),
        storageNotes: storageNotesController.text.trim().isEmpty
            ? null
            : storageNotesController.text.trim(),
        isSleeved: isSleeved,
        hasCustomInsert: hasCustomInsert,
        hasPaintedMiniatures: hasPaintedMiniatures,
      );
}

KindEditDraft createBoardGameEditDraft({
  required LibraryMetadataItem item,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
  required TextControllerGroup textControllers,
}) {
  final details = ownedItem?.boardgameDetails;
  return BoardGameEditDraft(
    editionLanguageController:
        textControllers.create(text: details?.editionLanguage ?? ''),
    editionRegionController:
        textControllers.create(text: details?.editionRegion ?? ''),
    componentConditionController:
        textControllers.create(text: details?.componentCondition ?? ''),
    componentCompletenessController:
        textControllers.create(text: details?.componentCompleteness ?? ''),
    missingPiecesNotesController:
        textControllers.create(text: details?.missingPiecesNotes ?? ''),
    storageNotesController:
        textControllers.create(text: details?.storageNotes ?? ''),
    isSleeved: details?.isSleeved ?? false,
    hasCustomInsert: details?.hasCustomInsert ?? false,
    hasPaintedMiniatures: details?.hasPaintedMiniatures ?? false,
  );
}
