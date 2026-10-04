import 'package:collectarr_app/features/library/edit/draft/library_edit_form_fields.dart';
import 'package:collectarr_app/features/library/kinds/game/catalog/game_catalog_fields.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_library_entry_projection.dart';
import 'package:collectarr_app/features/collection/commands/library_entry_commands.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_edit_kind_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';

import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_valuation.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_entry_dispatch.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_library_entry_update_payload.dart';
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
    with
        LibraryCatalogItemEditSessionLinkDefaults,
        LibraryEntryEditSessionDefaults
    implements LibraryCatalogItemEditSession, LibraryEntryEditSession {
  GameEditDraft({
    this.libraryEntry,
    required this.gameCompleteness,
    required this.gameHasBox,
    required this.gameHasManual,
    required this.gamePriceChartingId,
    this.gameValuations,
    required this.gameCoreRegion,
    required this.gameValueIsLocked,
    required this.gameEdit,
  });

  final GameLibraryEntry? libraryEntry;

  String? gameCompleteness;
  bool? gameHasBox;
  bool? gameHasManual;
  String? gamePriceChartingId;
  final GameValuationSet? gameValuations;
  String? gameCoreRegion;
  bool gameValueIsLocked;

  final GameEditController gameEdit;

  @override
  JsonEncodable toDetailsDraft() => GameEntryDetailsDraft(
        completeness: gameCompleteness,
        hasBox: gameHasBox,
        hasManual: gameHasManual,
        priceChartingId: gamePriceChartingId,
        valuations: gameValuations,
        coreRegion: gameCoreRegion,
        valueIsLocked: gameValueIsLocked,
      );

  @override
  void initializePersonalState(PersonalStateDraft personal) {
    final item = libraryEntry;
    if (item == null) return;
    personal.ownerLabelController.text = item.personal.ownerLabel ?? '';
    personal.conditionController.text = item.personal.condition ?? '';
    personal.gradeController.text = item.personal.grade ?? '';
    personal.purchaseDateController.text = item.personal.purchaseDate == null
        ? ''
        : formatDate(item.personal.purchaseDate!);
    personal.priceController.text = item.personal.pricePaidCents == null
        ? ''
        : (item.personal.pricePaidCents! / 100).toStringAsFixed(2);
    personal.currencyController.text = item.personal.currency ?? '';
    personal.indexNumberController.text =
        item.personal.indexNumber?.toString() ?? '';
    personal.notesController.text = item.personal.personalNotes ?? '';
    personal.tagsController.text = item.personal.tags ?? '';
    personal.sellPriceController.text = item.personal.sellPriceCents == null
        ? ''
        : (item.personal.sellPriceCents! / 100).toStringAsFixed(2);
    personal.soldToController.text = item.personal.soldTo ?? '';
    personal.purchaseStoreController.text = item.personal.purchaseStore ?? '';
    personal.marketValueController.text = item.personal.marketValueCents == null
        ? ''
        : (item.personal.marketValueCents! / 100).toStringAsFixed(2);
    personal.selectedLocationId = item.personal.locationId;
    personal.soldAt = item.personal.soldAt;
    personal.collectionStatus = item.personal.collectionStatus;
  }

  @override
  GameLibraryEntryUpdatePayload buildEntryUpdatePayload({
    required LibraryEntryRef libraryEntryRef,
    required PersonalStateDraft personal,
  }) {
    return GameLibraryEntryUpdatePayload(
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
      details: Patch.set(toDetailsDraft() as GameEntryDetailsDraft),
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
      kindItem: CatalogSearchCandidate.fromItem(
          selection.kindItem.kindCapability.mapTransport((transport) {
        final metadata = GameCatalogMetadata.fromJson(transport.kindData);
        final edited = metadata.copyWith(
          title: fields.controller(GameCanonicalEditField.title).text.trim(),
          displayTitle: emptyToNull(
              fields.controller(GameCanonicalEditField.displayTitle).text),
          originalTitle: emptyToNull(
              fields.controller(GameCanonicalEditField.originalTitle).text),
          localizedTitle: emptyToNull(
              fields.controller(GameCanonicalEditField.localizedTitle).text),
          searchAliases: aliases.isEmpty ? null : aliases,
          synopsis: emptyToNull(
              fields.controller(GameCanonicalEditField.synopsis).text),
          coverImageUrl: emptyToNull(
              fields.controller(GameCanonicalEditField.coverImage).text),
          thumbnailImageUrl: emptyToNull(
              fields.controller(GameCanonicalEditField.thumbnailImage).text),
          sortKey: emptyToNull(
            fields.controller(GameCanonicalEditField.sortTitle).text,
          ),
        );
        final updated = GameCatalogMetadata.fromJson(applyJsonFieldPatch(
          edited,
          {
            'display_title': emptyToNull(
              fields.controller(GameCanonicalEditField.displayTitle).text,
            ),
            'original_title': emptyToNull(
              fields.controller(GameCanonicalEditField.originalTitle).text,
            ),
            'localized_title': emptyToNull(
              fields.controller(GameCanonicalEditField.localizedTitle).text,
            ),
            'search_aliases': aliases,
            'synopsis': emptyToNull(
              fields.controller(GameCanonicalEditField.synopsis).text,
            ),
            'cover_image_url': emptyToNull(
              fields.controller(GameCanonicalEditField.coverImage).text,
            ),
            'thumbnail_image_url': emptyToNull(
              fields.controller(GameCanonicalEditField.thumbnailImage).text,
            ),
            'sort_key': emptyToNull(
              fields.controller(GameCanonicalEditField.sortTitle).text,
            ),
          },
        ));
        return transport.replacingKindData(updated);
      })),
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
  LibraryEntryDispatch? libraryEntryDispatch,
  TrackingSummary? trackingSummary,
  required TextControllerGroup textControllers,
}) {
  final entry = GameLibraryEntryProjection.fromDispatch(libraryEntryDispatch);
  final game = entry?.personal.details;
  final meta = item.kindCapability.mapTransport(
    (transport) => GameCatalogMetadata.fromJson(transport.kindData),
  );
  final developerNames = meta.creators
      .where(
          (credit) => credit.role?.toLowerCase().contains('developer') ?? false)
      .map((credit) => credit.name.trim())
      .where((n) => n.isNotEmpty)
      .join(', ');
  final platforms = meta.platforms;
  final gameEdit = GameEditController(
    initialPlatforms: platforms.join(', '),
    initialDevelopers: developerNames,
    initialSeriesTitle: meta.seriesTitle ?? '',
    initialPublisher: meta.publisher ?? '',
    initialReleaseDate:
        meta.releaseDate != null ? formatDate(meta.releaseDate!) : '',
    initialReleaseYear: meta.releaseDate?.year.toString() ?? '',
    initialFranchise: meta.franchise ?? '',
    initialGenres: meta.genres.join(', '),
    initialAgeRating: meta.ageRating ?? '',
    initialLanguage: meta.languages.join(', '),
    initialCountry: meta.country,
    initialEditionTitle: meta.editionTitle ?? meta.titleExtension ?? '',
    initialVariant: meta.variantName ?? '',
    initialBarcode: meta.barcode ?? '',
    initialPhysicalFormat:
        meta.physicalFormatLabel ?? meta.physicalFormat ?? '',
    initialPhysicalFormatId: meta.physicalFormat,
  );

  final draft = GameEditDraft(
    libraryEntry: entry,
    gameCompleteness: game?.completeness,
    gameHasBox: game?.hasBox,
    gameHasManual: game?.hasManual,
    gamePriceChartingId: game?.priceChartingId,
    gameValuations: game?.valuations,
    gameCoreRegion: game?.coreRegion,
    gameValueIsLocked: game?.valueIsLocked ?? false,
    gameEdit: gameEdit,
  );
  return LibraryEditSessionBundle(
    catalogItemSession: draft,
    entrySession: draft,
    disposeSession: draft.dispose,
  );
}
