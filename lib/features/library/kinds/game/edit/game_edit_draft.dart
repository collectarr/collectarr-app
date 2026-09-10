import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_edit_kind_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/catalog/transport/library_add_catalog_item.dart';

import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/edit/draft/personal_state_draft.dart';
import 'package:collectarr_app/features/library/config/catalog_reference_helpers.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
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
  JsonEncodable toDetailsDraft() => GameOwnedDetailsDraft(
        completeness: gameCompleteness,
        hasBox: gameHasBox,
        hasManual: gameHasManual,
        priceChartingId: gamePriceChartingId,
        coreRegion: gameCoreRegion,
        valueIsLocked: gameValueIsLocked,
      );

  @override
  GameOwnedItemUpdatePayload buildOwnedUpdatePayload({
    required String ownedItemId,
    required PersonalStateDraft personal,
  }) {
    final targetRef = catalogRefForOwnedSelection(
      CatalogMediaKind.game,
      anchorType: personal.selectedOwnedAnchorType,
      editionId: personal.selectedEditionId,
      variantId: personal.selectedVariantId,
      bundleReleaseId: personal.selectedBundleReleaseId,
    );
    return GameOwnedItemUpdatePayload(
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
      details: Patch.set(toDetailsDraft() as GameOwnedDetailsDraft),
    );
  }

  @override
  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) {
    return gameEdit.applySelectionEdits(selection);
  }

  @override
  void dispose() {
    gameEdit.dispose();
  }
}

LibraryEditKindDraft createGameEditDraft({
  required LibraryAddCatalogItem item,
  Object? typedOwnedItem,
  TrackingEntry? trackingEntry,
  required TextControllerGroup textControllers,
}) {
  final game = GameOwnedItemProjection.tryFromTyped(typedOwnedItem)?.details;
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
