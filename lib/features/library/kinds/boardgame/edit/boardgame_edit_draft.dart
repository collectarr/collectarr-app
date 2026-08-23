import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/edit/draft/kind_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

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
  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) {
    return selection;
  }
}

KindEditDraft createBoardGameEditDraft({
  required LibraryMetadataItem item,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
  required TextControllerGroup textControllers,
}) {
  final bg = ownedItem?.boardgameDetails;
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
  );
}
