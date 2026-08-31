import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/edit/draft/kind_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

import 'game_edit_controller.dart';

class GameEditDraft extends KindEditDraft {
  GameEditDraft({
    required this.gameCompleteness,
    required this.gameHasBox,
    required this.gameHasManual,
    required this.gamePriceChartingId,
    required this.gameCoreRegion,
    required this.gameValueIsLocked,
    required this.gameEdit,
  });

  String? gameCompleteness;
  bool? gameHasBox;
  bool? gameHasManual;
  String? gamePriceChartingId;
  String? gameCoreRegion;
  bool gameValueIsLocked;

  final GameEditController gameEdit;

  @override
  OwnedDetailsDraft toDetailsDraft() => GameOwnedDetailsDraft(
        completeness: gameCompleteness,
        hasBox: gameHasBox,
        hasManual: gameHasManual,
        priceChartingId: gamePriceChartingId,
        coreRegion: gameCoreRegion,
        valueIsLocked: gameValueIsLocked,
      );

  @override
  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) {
    var result = gameEdit.applySelectionEdits(selection);
    if (result.personal != null) {
      result = result.copyWith(
        personal: result.personal!.copyWith(
          gameCompleteness: gameCompleteness,
          gameHasBox: gameHasBox,
          gameHasManual: gameHasManual,
          gamePriceChartingId: gamePriceChartingId,
          gameCoreRegion: gameCoreRegion,
          gameValueIsLocked: gameValueIsLocked,
        ),
      );
    }
    return result;
  }

  @override
  void dispose() {
    gameEdit.dispose();
  }
}

KindEditDraft createGameEditDraft({
  required LibraryMetadataItem item,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
  required TextControllerGroup textControllers,
}) {
  final game = ownedItem?.gameDetails;
  final payload = item.kindMetadata.toSyncPayload();
  final creators =
      (payload['creators'] as List?)?.cast<Map<String, dynamic>>() ??
          const <Map<String, dynamic>>[];
  final developerNames = creators
      .where((c) =>
          c['role']?.toString().toLowerCase().contains('developer') ?? false)
      .map((c) => c['name']?.toString().trim() ?? '')
      .where((n) => n.isNotEmpty)
      .join(', ');
  final platforms = (payload['platforms'] as List?)?.map((e) => e.toString()) ??
      const <String>[];
  final gameEdit = GameEditController(
    initialPlatforms: platforms.join(', '),
    initialDevelopers: developerNames,
    initialSeriesTitle: (payload['series_title'] ??
                (payload['series'] as Map?)?['series_title'])
            ?.toString() ??
        '',
    initialPublisher: (payload['publisher'] ??
                (payload['publishing'] as Map?)?['original_publisher'])
            ?.toString() ??
        '',
  );

  return GameEditDraft(
    gameCompleteness: game?.completeness,
    gameHasBox: game?.hasBox,
    gameHasManual: game?.hasManual,
    gamePriceChartingId: game?.priceChartingId,
    gameCoreRegion: game?.coreRegion,
    gameValueIsLocked: game?.valueIsLocked ?? false,
    gameEdit: gameEdit,
  );
}
