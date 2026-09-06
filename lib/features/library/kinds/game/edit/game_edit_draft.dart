import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_edit_kind_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details.dart';
import 'game_edit_controller.dart';

class GameEditDraft extends LibraryEditKindDraft {
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

LibraryEditKindDraft createGameEditDraft({
  required CatalogItem item,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
  required TextControllerGroup textControllers,
}) {
  final game = ownedItem?.details as GameOwnedDetails?;
  final meta = item.kindMetadata is GameCatalogMetadata
      ? item.kindMetadata as GameCatalogMetadata
      : null;
  final developerNames = (meta?.creators ?? const <Map<String, dynamic>>[])
      .where((c) =>
          c['role']?.toString().toLowerCase().contains('developer') ?? false)
      .map((c) => c['name']?.toString().trim() ?? '')
      .where((n) => n.isNotEmpty)
      .join(', ');
  final platforms = meta?.platforms ?? const <String>[];
  final gameEdit = GameEditController(
    initialPlatforms: platforms.join(', '),
    initialDevelopers: developerNames,
    initialSeriesTitle: meta?.series ?? '',
    initialPublisher: meta?.publishers.join(', ') ?? '',
    initialReleaseDate:
        meta?.releaseDate != null ? formatDate(meta!.releaseDate!) : '',
    initialReleaseYear: meta?.releaseDate?.year.toString() ?? '',
    initialFranchise: meta?.franchise ?? '',
    initialGenres: meta?.genres.join(', ') ?? '',
    initialAgeRating: meta?.ageRating ?? '',
    initialLanguage: meta?.languages.join(', ') ?? '',
    initialCountry: meta?.country ?? '',
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
