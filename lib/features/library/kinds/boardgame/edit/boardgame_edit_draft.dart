import 'package:collectarr_app/features/library/edit/draft/library_edit_form_fields.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_fields.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_library_entry_projection.dart';
import 'package:collectarr_app/features/collection/commands/library_entry_commands.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_edit_kind_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_entry_dispatch.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/entries/boardgame_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/entries/boardgame_library_entry_update_payload.dart';
import 'package:collectarr_app/features/library/edit/draft/personal_state_draft.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter/material.dart';

enum BoardGameCanonicalEditField {
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

class BoardGameEditDraft
    with
        LibraryCatalogItemEditSessionLinkDefaults,
        LibraryEntryEditSessionDefaults
    implements LibraryCatalogItemEditSession, LibraryEntryEditSession {
  BoardGameEditDraft({
    this.libraryEntry,
    this.editionLanguage,
    this.editionRegion,
    this.componentCondition,
    this.componentCompleteness,
    this.missingPiecesNotes,
    this.isSleeved = false,
    this.hasCustomInsert = false,
    this.hasPaintedMiniatures = false,
    this.storageNotes,
    required this.editionTitleController,
    required this.originalTitleController,
    required this.subtitleController,
    required this.platformsController,
    required this.identifiersController,
    required this.contributorsController,
    required this.originalLanguageController,
    required this.releaseYearController,
    required this.minPlayersController,
    required this.maxPlayersController,
    required this.recommendedPlayersController,
    required this.bestPlayersController,
    required this.minPlaytimeController,
    required this.maxPlaytimeController,
    required this.playingTimeController,
    required this.minimumAgeController,
    required this.complexityWeightController,
    required this.designersController,
    required this.artistsController,
    required this.publisherController,
    required this.mechanicsController,
    required this.categoriesController,
    required this.familiesController,
    required this.themesController,
    required this.expansionsController,
    required this.expansionForController,
    required this.rankingsController,
    required this.languagesController,
    required this.bggRatingController,
    required this.bggRatingCountController,
    required this.bggRankController,
    required this.seriesTitleController,
    required this.itemNumberController,
    required this.physicalFormatController,
    required this.barcodeController,
    required this.catalogNumberController,
    required this.variantController,
    required this.countryController,
    required this.languageController,
    required this.ageRatingController,
    required this.audienceRatingController,
    required this.releaseStatusController,
    required this.releaseDateController,
  });

  final BoardGameLibraryEntry? libraryEntry;

  String? editionLanguage;
  String? editionRegion;
  String? componentCondition;
  String? componentCompleteness;
  String? missingPiecesNotes;
  bool isSleeved;
  bool hasCustomInsert;
  bool hasPaintedMiniatures;
  String? storageNotes;
  final TextEditingController editionTitleController;
  final TextEditingController originalTitleController;
  final TextEditingController subtitleController;
  final TextEditingController platformsController;
  final TextEditingController identifiersController;
  final TextEditingController contributorsController;
  final TextEditingController originalLanguageController;
  final TextEditingController minPlayersController;
  final TextEditingController maxPlayersController;
  final TextEditingController recommendedPlayersController;
  final TextEditingController bestPlayersController;
  final TextEditingController minPlaytimeController;
  final TextEditingController maxPlaytimeController;
  final TextEditingController playingTimeController;
  final TextEditingController minimumAgeController;
  final TextEditingController complexityWeightController;
  final TextEditingController designersController;
  final TextEditingController artistsController;
  final TextEditingController publisherController;
  final TextEditingController mechanicsController;
  final TextEditingController categoriesController;
  final TextEditingController familiesController;
  final TextEditingController themesController;
  final TextEditingController expansionsController;
  final TextEditingController expansionForController;
  final TextEditingController rankingsController;
  final TextEditingController languagesController;
  final TextEditingController bggRatingController;
  final TextEditingController bggRatingCountController;
  final TextEditingController bggRankController;
  final TextEditingController seriesTitleController;
  final TextEditingController itemNumberController;
  final TextEditingController physicalFormatController;
  final TextEditingController barcodeController;
  final TextEditingController catalogNumberController;
  final TextEditingController variantController;
  final TextEditingController countryController;
  final TextEditingController languageController;
  final TextEditingController ageRatingController;
  final TextEditingController audienceRatingController;
  final TextEditingController releaseStatusController;
  final TextEditingController releaseDateController;
  final TextEditingController releaseYearController;

  @override
  JsonEncodable toDetailsDraft() => BoardgameEntryDetailsDraft(
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
  BoardgameLibraryEntryUpdatePayload buildEntryUpdatePayload({
    required LibraryEntryRef libraryEntryRef,
    required PersonalStateDraft personal,
  }) {
    return BoardgameLibraryEntryUpdatePayload(
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
      details: Patch.set(toDetailsDraft() as BoardgameEntryDetailsDraft),
    );
  }

  void dispose() {
    editionTitleController.dispose();
    originalTitleController.dispose();
    subtitleController.dispose();
    platformsController.dispose();
    identifiersController.dispose();
    contributorsController.dispose();
    originalLanguageController.dispose();
    releaseYearController.dispose();
    minPlayersController.dispose();
    maxPlayersController.dispose();
    recommendedPlayersController.dispose();
    bestPlayersController.dispose();
    minPlaytimeController.dispose();
    maxPlaytimeController.dispose();
    playingTimeController.dispose();
    minimumAgeController.dispose();
    complexityWeightController.dispose();
    designersController.dispose();
    artistsController.dispose();
    publisherController.dispose();
    mechanicsController.dispose();
    categoriesController.dispose();
    familiesController.dispose();
    themesController.dispose();
    expansionsController.dispose();
    expansionForController.dispose();
    rankingsController.dispose();
    languagesController.dispose();
    bggRatingController.dispose();
    bggRatingCountController.dispose();
    bggRankController.dispose();
    seriesTitleController.dispose();
    itemNumberController.dispose();
    physicalFormatController.dispose();
    barcodeController.dispose();
    catalogNumberController.dispose();
    variantController.dispose();
    countryController.dispose();
    languageController.dispose();
    ageRatingController.dispose();
    audienceRatingController.dispose();
    releaseStatusController.dispose();
    releaseDateController.dispose();
  }

  @override
  LibraryEditSelection applyCanonicalEdits(
    LibraryEditSelection selection,
    LibraryEditFormFields fields,
  ) {
    final aliases = fields
        .controller(BoardGameCanonicalEditField.searchAliases)
        .text
        .split(RegExp(r'[,\r\n]+'))
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList();
    return selection.copyWith(
      kindItem: CatalogSearchCandidate.fromItem(
          selection.kindItem.kindCapability.mapTransport((transport) {
        final metadata = BoardGameMetadata.fromJson(transport.kindData);
        final updated = BoardGameMetadata.fromJson(applyJsonFieldPatch(
          metadata,
          {
            'title': fields
                .controller(BoardGameCanonicalEditField.title)
                .text
                .trim(),
            'display_title': emptyToNull(fields
                .controller(BoardGameCanonicalEditField.displayTitle)
                .text),
            'sort_key': emptyToNull(
              fields.controller(BoardGameCanonicalEditField.sortTitle).text,
            ),
            'original_title': emptyToNull(fields
                .controller(BoardGameCanonicalEditField.originalTitle)
                .text),
            'localized_title': emptyToNull(fields
                .controller(BoardGameCanonicalEditField.localizedTitle)
                .text),
            'search_aliases': aliases,
            'synopsis': emptyToNull(
              fields.controller(BoardGameCanonicalEditField.synopsis).text,
            ),
            'cover_image_url': emptyToNull(
              fields.controller(BoardGameCanonicalEditField.coverImage).text,
            ),
            'thumbnail_image_url': emptyToNull(fields
                .controller(BoardGameCanonicalEditField.thumbnailImage)
                .text),
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
    final metadata = item.boardGameCatalogFields;
    final catalogFields = <(String, String, TextEditingController)>[
      ('edition_title', 'Edition title', editionTitleController),
      ('original_title', 'Original Title', originalTitleController),
      ('subtitle', 'Subtitle', subtitleController),
      ('platforms', 'Platforms', platformsController),
      ('identifiers', 'Identifiers', identifiersController),
      ('contributors', 'Contributors', contributorsController),
      ('original_language', 'Original language', originalLanguageController),
      ('year_published', 'Year published', releaseYearController),
      ('publisher', 'Publisher', publisherController),
      ('designers', 'Designers', designersController),
      ('artists', 'Artists', artistsController),
      ('min_players', 'Minimum players', minPlayersController),
      ('max_players', 'Maximum players', maxPlayersController),
      (
        'recommended_players',
        'Recommended players',
        recommendedPlayersController
      ),
      ('best_players', 'Best player count', bestPlayersController),
      (
        'min_playtime_minutes',
        'Minimum play time (minutes)',
        minPlaytimeController
      ),
      (
        'max_playtime_minutes',
        'Maximum play time (minutes)',
        maxPlaytimeController
      ),
      ('playing_time_minutes', 'Playing time (minutes)', playingTimeController),
      ('min_age', 'Minimum age', minimumAgeController),
      ('complexity_weight', 'Complexity weight', complexityWeightController),
      ('mechanics', 'Mechanics', mechanicsController),
      ('categories', 'Categories', categoriesController),
      ('families', 'Families', familiesController),
      ('themes', 'Themes', themesController),
      ('expansions', 'Expansions', expansionsController),
      ('expansion_for', 'Expansion for', expansionForController),
      ('rankings', 'Rankings', rankingsController),
      ('languages', 'Languages', languagesController),
      ('bgg_rating', 'BoardGameGeek rating', bggRatingController),
      ('bgg_rating_count', 'Rating count', bggRatingCountController),
      ('bgg_rank', 'BoardGameGeek rank', bggRankController),
      ('series_title', 'Series', seriesTitleController),
      ('item_number', 'Item number', itemNumberController),
      ('physical_format', 'Format', physicalFormatController),
      ('barcode', 'Barcode', barcodeController),
      ('catalog_number', 'Catalog number', catalogNumberController),
      ('variant', 'Variant', variantController),
      ('country', 'Country / region', countryController),
      ('language', 'Language', languageController),
      ('release_date', 'Release Date', releaseDateController),
      ('age_rating', 'Age rating', ageRatingController),
      ('audience_rating', 'Audience rating', audienceRatingController),
      ('release_status', 'Release status', releaseStatusController),
    ];
    fields.create(BoardGameCanonicalEditField.title,
        initialValue: metadata.title);
    fields.create(BoardGameCanonicalEditField.displayTitle,
        initialValue: metadata.displayTitle ?? '');
    fields.create(BoardGameCanonicalEditField.sortTitle,
        initialValue: metadata.sortKey ?? '');
    fields.create(BoardGameCanonicalEditField.originalTitle,
        initialValue: metadata.originalTitle ?? '');
    fields.create(BoardGameCanonicalEditField.localizedTitle,
        initialValue: metadata.localizedTitle ?? '');
    fields.create(BoardGameCanonicalEditField.searchAliases,
        initialValue: metadata.searchAliases.join(', '));
    fields.create(BoardGameCanonicalEditField.synopsis,
        initialValue: metadata.synopsis ?? '');
    fields.create(BoardGameCanonicalEditField.coverImage,
        initialValue: metadata.coverImageUrl ?? '');
    fields.create(BoardGameCanonicalEditField.thumbnailImage,
        initialValue: metadata.thumbnailImageUrl ?? '');
    return LibraryEditFormSchema(
      fields: [
        LibraryEditFormFieldSpec(
          id: BoardGameCanonicalEditField.title,
          section: LibraryEditFormSection.details,
          controller: fields.controller(BoardGameCanonicalEditField.title),
          label: 'Title',
          required: true,
        ),
        LibraryEditFormFieldSpec(
          id: BoardGameCanonicalEditField.sortTitle,
          section: LibraryEditFormSection.details,
          controller: fields.controller(BoardGameCanonicalEditField.sortTitle),
          label: 'Sort Title',
        ),
        LibraryEditFormFieldSpec(
          id: BoardGameCanonicalEditField.originalTitle,
          section: LibraryEditFormSection.details,
          controller:
              fields.controller(BoardGameCanonicalEditField.originalTitle),
          label: 'Original Title',
          visible: false,
        ),
        LibraryEditFormFieldSpec(
          id: BoardGameCanonicalEditField.localizedTitle,
          section: LibraryEditFormSection.details,
          controller:
              fields.controller(BoardGameCanonicalEditField.localizedTitle),
          label: 'Localized title',
        ),
        LibraryEditFormFieldSpec(
          id: BoardGameCanonicalEditField.displayTitle,
          section: LibraryEditFormSection.details,
          controller:
              fields.controller(BoardGameCanonicalEditField.displayTitle),
          label: 'Display Title',
        ),
        LibraryEditFormFieldSpec(
          id: BoardGameCanonicalEditField.searchAliases,
          section: LibraryEditFormSection.details,
          controller:
              fields.controller(BoardGameCanonicalEditField.searchAliases),
          label: 'Search Aliases',
          visible: false,
        ),
        LibraryEditFormFieldSpec(
          id: BoardGameCanonicalEditField.thumbnailImage,
          section: LibraryEditFormSection.details,
          controller:
              fields.controller(BoardGameCanonicalEditField.thumbnailImage),
          label: 'Thumbnail image URL',
          visible: false,
        ),
        LibraryEditFormFieldSpec(
          id: BoardGameCanonicalEditField.coverImage,
          section: LibraryEditFormSection.artwork,
          controller: fields.controller(BoardGameCanonicalEditField.coverImage),
          label: 'Cover Image URL',
        ),
        LibraryEditFormFieldSpec(
          id: BoardGameCanonicalEditField.synopsis,
          section: LibraryEditFormSection.description,
          controller: fields.controller(BoardGameCanonicalEditField.synopsis),
          label: 'Synopsis',
          maxLines: 8,
        ),
        for (final field in catalogFields)
          LibraryEditFormFieldSpec(
            id: 'boardgame.${field.$1}',
            section: LibraryEditFormSection.details,
            controller: field.$3,
            label: field.$2,
          ),
      ],
      sectionTitles: const {
        LibraryEditFormSection.details: 'Catalog Item',
        LibraryEditFormSection.artwork: 'Cover Image',
        LibraryEditFormSection.description: 'Synopsis',
      },
    );
  }

  @override
  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) {
    final meta = _boardGameMetadataFor(selection.kindItem);
    if (meta != null) {
      final originalTitle = _nullableText(originalTitleController);
      final editionTitle = _nullableText(editionTitleController);
      final year = _intValue(releaseYearController);
      final minPlayers = _intValue(minPlayersController);
      final maxPlayers = _intValue(maxPlayersController);
      final recommendedPlayers = _nullableText(recommendedPlayersController);
      final bestPlayers = _nullableText(bestPlayersController);
      final minPlaytime = _intValue(minPlaytimeController);
      final maxPlaytime = _intValue(maxPlaytimeController);
      final minimumAge = _intValue(minimumAgeController);
      final complexityWeight = _doubleValue(complexityWeightController);
      final designers = _splitValues(designersController, fallback: const []);
      final artists = _splitValues(artistsController, fallback: const []);
      final publishers = _splitValues(
        publisherController,
        fallback: const [],
      );
      final mechanics = _splitValues(mechanicsController, fallback: const []);
      final categories = _splitValues(categoriesController, fallback: const []);
      final families = _splitValues(familiesController, fallback: const []);
      final themes = _splitValues(themesController, fallback: const []);
      final expansions = _splitValues(expansionsController, fallback: const []);
      final expansionFor = _nullableText(expansionForController);
      final languages = _splitValues(languagesController, fallback: const []);
      final bggRating = _doubleValue(bggRatingController);
      final bggRatingCount = _intValue(bggRatingCountController);
      final bggRank = _intValue(bggRankController);
      final seriesTitle = _nullableText(seriesTitleController);
      final itemNumber = _nullableText(itemNumberController);
      final physicalFormat = _nullableText(physicalFormatController);
      final barcode = _nullableText(barcodeController);
      final variant = _nullableText(variantController);
      final releaseDate =
          PartialDate.tryParse(releaseDateController.text.trim());
      final updatedMeta = BoardGameMetadata(
        title: meta.title,
        sortKey: meta.sortKey,
        originalTitle: originalTitle,
        localizedTitle: meta.localizedTitle,
        titleExtension: meta.titleExtension,
        subtitle: _nullableText(subtitleController),
        searchAliases: meta.searchAliases,
        synopsis: meta.synopsis,
        description: meta.description,
        plotSummary: meta.plotSummary,
        plotDescription: meta.plotDescription,
        ageRating: _nullableText(ageRatingController),
        audienceRating: _nullableText(audienceRatingController),
        barcode: barcode,
        catalogNumber: _nullableText(catalogNumberController),
        itemNumber: itemNumber,
        contributors: _editedCredits(contributorsController, meta.contributors),
        country: _nullableText(countryController),
        coverImageUrl: meta.coverImageUrl,
        thumbnailImageUrl: meta.thumbnailImageUrl,
        yearPublished: year,
        minPlayers: minPlayers,
        maxPlayers: maxPlayers,
        recommendedPlayers: recommendedPlayers,
        bestPlayers: bestPlayers,
        minPlaytimeMinutes: minPlaytime,
        maxPlaytimeMinutes: maxPlaytime,
        minimumAge: minimumAge,
        complexityWeight: complexityWeight,
        designers: designers,
        artists: artists,
        editionTitle: editionTitle,
        externalLinks: meta.externalLinks,
        publishers: publishers,
        mechanics: mechanics,
        categories: categories,
        families: families,
        themes: themes,
        expansions: expansions,
        expansionFor: expansionFor,
        genres: meta.genres,
        identifiers:
            _editedIdentifiers(identifiersController, meta.identifiers),
        language: _nullableText(languageController),
        languages: languages,
        originalLanguage: _nullableText(originalLanguageController),
        physicalFormat: physicalFormat,
        physicalFormatLabel: physicalFormat,
        platforms: _splitValues(platformsController, fallback: const []),
        playingTimeMinutes: _intValue(playingTimeController),
        publisher: publishers.firstOrNull,
        rankings: _splitValues(rankingsController, fallback: const []),
        releaseDate: releaseDate,
        releaseDateParts: releaseDate,
        releaseStatus: _nullableText(releaseStatusController),
        bggRating: bggRating,
        bggRatingCount: bggRatingCount,
        bggRank: bggRank,
        seriesTitle: seriesTitle,
        seriesTags: meta.seriesTags,
        variantName: variant,
        characters: meta.characters,
      );
      return selection.copyWith(
        kindItem: selection.kindItem.kindCapability.mapTransport(
          (transport) => CatalogSearchCandidate.fromItem(
            transport.replacingKindData(updatedMeta),
          ),
        ),
      );
    }
    return selection;
  }
}

BoardGameMetadata? _boardGameMetadataFor(CatalogSearchCandidate item) {
  if (item.reference.kind != CatalogMediaKind.boardgame) return null;
  return item.kindCapability.mapTransport(
    (transport) => BoardGameMetadata.fromJson(transport.kindData),
  );
}

String? _nullableText(TextEditingController controller) {
  final value = controller.text.trim();
  return value.isEmpty ? null : value;
}

int? _intValue(TextEditingController controller) =>
    int.tryParse(controller.text.trim());

double? _doubleValue(TextEditingController controller) =>
    double.tryParse(controller.text.trim());

List<String> _splitValues(
  TextEditingController controller, {
  required List<String> fallback,
}) {
  final values = controller.text
      .split(RegExp(r'[,\r\n]+'))
      .map((entry) => entry.trim())
      .where((entry) => entry.isNotEmpty)
      .toSet()
      .toList();
  return values.isEmpty ? fallback : values;
}

LibraryEditSessionBundle createBoardGameEditDraft({
  required CatalogSearchCandidate item,
  LibraryEntryDispatch? libraryEntryDispatch,
  TrackingSummary? trackingSummary,
  required TextControllerGroup textControllers,
}) {
  final entry =
      BoardGameLibraryEntryProjection.fromDispatch(libraryEntryDispatch);
  final bg = entry?.personal.details;
  final meta = _boardGameMetadataFor(item);
  final draft = BoardGameEditDraft(
    libraryEntry: entry,
    editionLanguage: bg?.editionLanguage,
    editionRegion: bg?.editionRegion,
    componentCondition: bg?.componentCondition,
    componentCompleteness: bg?.componentCompleteness,
    missingPiecesNotes: bg?.missingPiecesNotes,
    isSleeved: bg?.isSleeved ?? false,
    hasCustomInsert: bg?.hasCustomInsert ?? false,
    hasPaintedMiniatures: bg?.hasPaintedMiniatures ?? false,
    storageNotes: bg?.storageNotes,
    editionTitleController: textControllers.create(
      text: (item.boardGameCatalogFields.titleExtension ??
                  item.boardGameCatalogFields.metadata?.editionTitle)
              ?.trim() ??
          '',
    ),
    originalTitleController: textControllers.create(
      text: meta?.originalTitle ??
          item.boardGameCatalogFields.originalTitle ??
          '',
    ),
    subtitleController: textControllers.create(
      text: meta?.subtitle ?? '',
    ),
    platformsController: textControllers.create(
      text: meta?.platforms.join(', ') ?? '',
    ),
    identifiersController: textControllers.create(
      text: meta?.identifiers.map((value) => value.value).join(', ') ?? '',
    ),
    contributorsController: textControllers.create(
      text: meta?.contributors.map((value) => value.name).join(', ') ?? '',
    ),
    originalLanguageController: textControllers.create(
      text: meta?.originalLanguage ?? '',
    ),
    minPlayersController: textControllers.create(
      text: meta?.minPlayers?.toString() ?? '',
    ),
    maxPlayersController: textControllers.create(
      text: meta?.maxPlayers?.toString() ?? '',
    ),
    recommendedPlayersController: textControllers.create(
      text: meta?.recommendedPlayers ?? '',
    ),
    bestPlayersController: textControllers.create(
      text: meta?.bestPlayers ?? '',
    ),
    minPlaytimeController: textControllers.create(
      text: meta?.minPlaytimeMinutes?.toString() ?? '',
    ),
    maxPlaytimeController: textControllers.create(
      text: meta?.maxPlaytimeMinutes?.toString() ?? '',
    ),
    playingTimeController: textControllers.create(
      text: meta?.playingTimeMinutes?.toString() ?? '',
    ),
    minimumAgeController: textControllers.create(
      text: meta?.minimumAge?.toString() ?? '',
    ),
    complexityWeightController: textControllers.create(
      text: meta?.complexityWeight?.toString() ?? '',
    ),
    designersController: textControllers.create(
      text: meta?.designers.join(', ') ?? '',
    ),
    artistsController: textControllers.create(
      text: meta?.artists.join(', ') ?? '',
    ),
    publisherController: textControllers.create(
      text: meta?.publishers.join(', ') ?? meta?.publisher ?? '',
    ),
    mechanicsController: textControllers.create(
      text: meta?.mechanics.join(', ') ?? '',
    ),
    categoriesController: textControllers.create(
      text: meta?.categories.join(', ') ?? '',
    ),
    familiesController: textControllers.create(
      text: meta?.families.join(', ') ?? '',
    ),
    themesController: textControllers.create(
      text: meta?.themes.join(', ') ?? '',
    ),
    expansionsController: textControllers.create(
      text: meta?.expansions.join(', ') ?? '',
    ),
    expansionForController: textControllers.create(
      text: meta?.expansionFor ?? '',
    ),
    rankingsController: textControllers.create(
      text: meta?.rankings.join(', ') ?? '',
    ),
    languagesController: textControllers.create(
      text: meta?.languages.join(', ') ?? '',
    ),
    bggRatingController: textControllers.create(
      text: meta?.bggRating?.toString() ?? '',
    ),
    bggRatingCountController: textControllers.create(
      text: meta?.bggRatingCount?.toString() ?? '',
    ),
    bggRankController: textControllers.create(
      text: meta?.bggRank?.toString() ?? '',
    ),
    seriesTitleController: textControllers.create(
      text: meta?.seriesTitle ?? '',
    ),
    itemNumberController: textControllers.create(
      text: meta?.itemNumber ?? '',
    ),
    physicalFormatController: textControllers.create(
      text: meta?.physicalFormatLabel ?? meta?.physicalFormat ?? '',
    ),
    barcodeController: textControllers.create(
      text: meta?.barcode ?? '',
    ),
    catalogNumberController: textControllers.create(
      text: meta?.catalogNumber ?? '',
    ),
    variantController: textControllers.create(
      text: meta?.variantName ?? '',
    ),
    countryController: textControllers.create(
      text: meta?.country ?? '',
    ),
    languageController: textControllers.create(
      text: meta?.language ?? '',
    ),
    ageRatingController: textControllers.create(
      text: meta?.ageRating ?? '',
    ),
    audienceRatingController: textControllers.create(
      text: meta?.audienceRating ?? '',
    ),
    releaseStatusController: textControllers.create(
      text: meta?.releaseStatus ?? '',
    ),
    releaseDateController: textControllers.create(
      text: meta?.releaseDate?.isoString ??
          meta?.releaseDateParts?.isoString ??
          (item.boardGameCatalogFields.releaseDate == null
              ? ''
              : formatDate(item.boardGameCatalogFields.releaseDate!)),
    ),
    releaseYearController: textControllers.create(
      text: meta?.yearPublished?.toString() ??
          item.boardGameCatalogFields.releaseYear?.toString() ??
          '',
    ),
  );
  return LibraryEditSessionBundle(
    catalogItemSession: draft,
    entrySession: draft,
    disposeSession: draft.dispose,
  );
}

List<BoardGameIdentifier> _editedIdentifiers(
  TextEditingController controller,
  List<BoardGameIdentifier> existing,
) {
  final values = _splitValues(controller, fallback: const []);
  if (values.join(', ') == existing.map((value) => value.value).join(', ')) {
    return existing;
  }
  return [
    for (final value in values)
      BoardGameIdentifier(identifierType: 'other', value: value),
  ];
}

List<BoardGamePersonCredit> _editedCredits(
  TextEditingController controller,
  List<BoardGamePersonCredit> existing,
) {
  final values = _splitValues(controller, fallback: const []);
  if (values.join(', ') == existing.map((value) => value.name).join(', ')) {
    return existing;
  }
  return [for (final value in values) BoardGamePersonCredit(name: value)];
}
