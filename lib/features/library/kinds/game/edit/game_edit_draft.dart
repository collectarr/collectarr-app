import 'package:collectarr_app/features/library/edit/draft/library_edit_form_fields.dart';
import 'package:collectarr_app/features/library/kinds/game/catalog/game_catalog_fields.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_owned_item_projection.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_edit_kind_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';

import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_owned_item_dispatch.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/edit/draft/personal_state_draft.dart';
import 'game_edit_controller.dart';

enum GameCanonicalEditField {
  title,
  displayTitle,
  sortTitle,
  originalTitle,
  localizedTitle,
  searchAliases,
  synopsis,
  coverImage,
  thumbnailImage
}

class GameEditDraft
    with LibraryWorkEditSessionLinkDefaults, LibraryCopyEditSessionDefaults
    implements LibraryReleaseEditSession, LibraryCopyEditSession {
  GameEditDraft({
    this.ownedItem,
    required this.gameCompleteness,
    required this.gameHasBox,
    required this.gameHasManual,
    required this.gamePriceChartingId,
    required this.gameCoreRegion,
    required this.gameValueIsLocked,
    required this.gameEdit,
  });

  final GameOwnedItem? ownedItem;

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
  GameOwnedItemUpdatePayload buildOwnedUpdatePayload({
    required OwnedItemRef ownedRef,
    required PersonalStateDraft personal,
  }) {
    final targetRef = personal.selectedOwnedTargetRef;
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
  LibraryEditSelection applyCanonicalEdits(
    LibraryEditSelection selection,
    LibraryEditFormFields fields,
  ) {
    final aliases = fields
        .controller(GameCanonicalEditField.searchAliases)
        .text
        .split(RegExp(r'[,\r\n]+'))
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList();
    return selection.copyWith(
      kindItem: CatalogSearchCandidate.fromItem(selection
          .kindItem.kindCapability
          .mapTransport((transport) => transport.copyWith(
                title:
                    fields.controller(GameCanonicalEditField.title).text.trim(),
                displayTitle: emptyToNull(fields
                    .controller(GameCanonicalEditField.displayTitle)
                    .text),
                sortKey: emptyToNull(
                    fields.controller(GameCanonicalEditField.sortTitle).text),
                originalTitle: emptyToNull(fields
                    .controller(GameCanonicalEditField.originalTitle)
                    .text),
                localizedTitle: emptyToNull(fields
                    .controller(GameCanonicalEditField.localizedTitle)
                    .text),
                searchAliases: aliases.isEmpty ? null : aliases,
                synopsis: emptyToNull(
                    fields.controller(GameCanonicalEditField.synopsis).text),
                coverImageUrl: emptyToNull(
                    fields.controller(GameCanonicalEditField.coverImage).text),
                thumbnailImageUrl: emptyToNull(fields
                    .controller(GameCanonicalEditField.thumbnailImage)
                    .text),
              ))),
    );
  }

  @override
  LibraryEditFormSchema buildCanonicalFormSchema(
    LibraryEditFormFields fields,
    CatalogSearchCandidate item,
  ) {
    final metadata = item.gameCatalogFields;
    fields.create(GameCanonicalEditField.title, initialValue: metadata.title);
    fields.create(GameCanonicalEditField.displayTitle,
        initialValue: metadata.displayTitle ?? '');
    fields.create(GameCanonicalEditField.sortTitle,
        initialValue: metadata.sortKey ?? '');
    fields.create(GameCanonicalEditField.originalTitle,
        initialValue: metadata.originalTitle ?? '');
    fields.create(GameCanonicalEditField.localizedTitle,
        initialValue: metadata.localizedTitle ?? '');
    fields.create(GameCanonicalEditField.searchAliases,
        initialValue: metadata.searchAliases.join(', '));
    fields.create(GameCanonicalEditField.synopsis,
        initialValue: metadata.synopsis ?? '');
    fields.create(GameCanonicalEditField.coverImage,
        initialValue: metadata.coverImageUrl ?? '');
    fields.create(GameCanonicalEditField.thumbnailImage,
        initialValue: metadata.thumbnailImageUrl ?? '');
    return LibraryEditFormSchema(
      fields: [
        LibraryEditFormFieldSpec(
          id: GameCanonicalEditField.title,
          section: LibraryEditFormSection.details,
          controller: fields.controller(GameCanonicalEditField.title),
          label: 'Title',
          required: true,
        ),
        LibraryEditFormFieldSpec(
          id: GameCanonicalEditField.sortTitle,
          section: LibraryEditFormSection.details,
          controller: fields.controller(GameCanonicalEditField.sortTitle),
          label: 'Sort title',
        ),
        LibraryEditFormFieldSpec(
          id: GameCanonicalEditField.originalTitle,
          section: LibraryEditFormSection.details,
          controller: fields.controller(GameCanonicalEditField.originalTitle),
          label: 'Original title',
        ),
        LibraryEditFormFieldSpec(
          id: GameCanonicalEditField.localizedTitle,
          section: LibraryEditFormSection.details,
          controller: fields.controller(GameCanonicalEditField.localizedTitle),
          label: 'Localized title',
        ),
        LibraryEditFormFieldSpec(
          id: GameCanonicalEditField.displayTitle,
          section: LibraryEditFormSection.details,
          controller: fields.controller(GameCanonicalEditField.displayTitle),
          label: 'Display title',
        ),
        LibraryEditFormFieldSpec(
          id: GameCanonicalEditField.searchAliases,
          section: LibraryEditFormSection.details,
          controller: fields.controller(GameCanonicalEditField.searchAliases),
          label: 'Search aliases',
          visible: false,
        ),
        LibraryEditFormFieldSpec(
          id: GameCanonicalEditField.thumbnailImage,
          section: LibraryEditFormSection.details,
          controller: fields.controller(GameCanonicalEditField.thumbnailImage),
          label: 'Thumbnail image URL',
          visible: false,
        ),
        LibraryEditFormFieldSpec(
          id: GameCanonicalEditField.coverImage,
          section: LibraryEditFormSection.artwork,
          controller: fields.controller(GameCanonicalEditField.coverImage),
          label: 'Cover Image URL',
        ),
        LibraryEditFormFieldSpec(
          id: GameCanonicalEditField.synopsis,
          section: LibraryEditFormSection.description,
          controller: fields.controller(GameCanonicalEditField.synopsis),
          label: 'Synopsis',
          maxLines: 8,
        ),
      ],
      sectionTitles: const {
        LibraryEditFormSection.details: 'Details',
        LibraryEditFormSection.artwork: 'Cover Image',
        LibraryEditFormSection.description: 'Synopsis',
      },
    );
  }

  @override
  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) {
    return gameEdit.applySelectionEdits(selection);
  }

  void dispose() {
    gameEdit.dispose();
  }
}

LibraryEditSessionBundle createGameEditDraft({
  required CatalogSearchCandidate item,
  LibraryOwnedItemDispatch? ownedItemDispatch,
  TrackingSummary? trackingSummary,
  required TextControllerGroup textControllers,
}) {
  final owned = GameOwnedItemProjection.fromDispatch(ownedItemDispatch);
  final game = owned?.details;
  final meta = item.kindCapability
          .mapTransport((transport) => transport)
          .kindMetadata is GameCatalogMetadata
      ? item.kindCapability.mapTransport((transport) => transport).kindMetadata
          as GameCatalogMetadata
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

  final draft = GameEditDraft(
    ownedItem: owned,
    gameCompleteness: game?.completeness,
    gameHasBox: game?.hasBox,
    gameHasManual: game?.hasManual,
    gamePriceChartingId: game?.priceChartingId,
    gameCoreRegion: game?.coreRegion,
    gameValueIsLocked: game?.valueIsLocked ?? false,
    gameEdit: gameEdit,
  );
  return LibraryEditSessionBundle(
    workSession: draft,
    releaseSession: draft,
    copySession: draft,
    disposeSession: draft.dispose,
  );
}
