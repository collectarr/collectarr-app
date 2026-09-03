import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/edit/draft/kind_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter/material.dart';

class BoardGameEditDraft extends KindEditDraft {
  BoardGameEditDraft({
    this.editionLanguage,
    this.editionRegion,
    this.componentCondition,
    this.componentCompleteness,
    this.missingPiecesNotes,
    this.isSleeved = false,
    this.hasCustomInsert = false,
    this.hasPaintedMiniatures = false,
    this.storageNotes,
    required this.releaseDateController,
    required this.releaseYearController,
  });

  String? editionLanguage;
  String? editionRegion;
  String? componentCondition;
  String? componentCompleteness;
  String? missingPiecesNotes;
  bool isSleeved;
  bool hasCustomInsert;
  bool hasPaintedMiniatures;
  String? storageNotes;
  final TextEditingController releaseDateController;
  final TextEditingController releaseYearController;

  @override
  OwnedDetailsDraft toDetailsDraft() => BoardgameOwnedDetailsDraft(
        editionLanguage: editionLanguage,
        editionRegion: editionRegion,
        componentCondition: componentCondition,
        componentCompleteness: componentCompleteness,
        missingPiecesNotes: missingPiecesNotes,
        isSleeved: isSleeved,
        hasCustomInsert: hasCustomInsert,
        hasPaintedMiniatures: hasPaintedMiniatures,
        storageNotes: storageNotes,
      );

  @override
  void dispose() {
    releaseDateController.dispose();
    releaseYearController.dispose();
  }

  @override
  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) {
    final meta = selection.item.kindMetadata is BoardGameMetadata
        ? (selection.item.kindMetadata as BoardGameMetadata)
        : null;
    final year = int.tryParse(releaseYearController.text);
    if (meta != null && year != null) {
      final updatedMeta = meta.copyWith(yearPublished: year);
      return selection.copyWith(
        item: selection.item.copyWith(kindMetadata: updatedMeta),
      );
    }
    return selection;
  }
}

KindEditDraft createBoardGameEditDraft({
  required LibraryMetadataItem item,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
  required TextControllerGroup textControllers,
}) {
  final bg = ownedItem?.details as BoardgameOwnedDetails?;
  final meta = item.kindMetadata is BoardGameMetadata
      ? item.kindMetadata as BoardGameMetadata
      : null;
  return BoardGameEditDraft(
    editionLanguage: bg?.editionLanguage,
    editionRegion: bg?.editionRegion,
    componentCondition: bg?.componentCondition,
    componentCompleteness: bg?.componentCompleteness,
    missingPiecesNotes: bg?.missingPiecesNotes,
    isSleeved: bg?.isSleeved ?? false,
    hasCustomInsert: bg?.hasCustomInsert ?? false,
    hasPaintedMiniatures: bg?.hasPaintedMiniatures ?? false,
    storageNotes: bg?.storageNotes,
    releaseDateController: textControllers.create(),
    releaseYearController: textControllers.create(
      text: meta?.yearPublished?.toString() ?? '',
    ),
  );
}
