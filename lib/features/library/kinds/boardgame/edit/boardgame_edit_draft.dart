import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/library/config/owned_details_draft.dart';
import 'package:collectarr_app/features/library/edit/contracts/library_edit_kind_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details_draft.dart';
import 'package:collectarr_app/features/library/models/library_kind_metadata_values.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:flutter/material.dart';

class BoardGameEditDraft extends LibraryEditKindDraft {
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
    required this.editionTitleController,
    required this.originalTitleController,
    required this.releaseYearController,
    required this.minPlayersController,
    required this.maxPlayersController,
    required this.recommendedPlayersController,
    required this.bestPlayersController,
    required this.minPlaytimeController,
    required this.maxPlaytimeController,
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
    required this.languagesController,
    required this.bggRatingController,
    required this.bggRatingCountController,
    required this.bggRankController,
    required this.seriesTitleController,
    required this.itemNumberController,
    required this.physicalFormatController,
    required this.barcodeController,
    required this.variantController,
    required this.releaseDateController,
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
  final TextEditingController editionTitleController;
  final TextEditingController originalTitleController;
  final TextEditingController minPlayersController;
  final TextEditingController maxPlayersController;
  final TextEditingController recommendedPlayersController;
  final TextEditingController bestPlayersController;
  final TextEditingController minPlaytimeController;
  final TextEditingController maxPlaytimeController;
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
  final TextEditingController languagesController;
  final TextEditingController bggRatingController;
  final TextEditingController bggRatingCountController;
  final TextEditingController bggRankController;
  final TextEditingController seriesTitleController;
  final TextEditingController itemNumberController;
  final TextEditingController physicalFormatController;
  final TextEditingController barcodeController;
  final TextEditingController variantController;
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
    editionTitleController.dispose();
    originalTitleController.dispose();
    releaseYearController.dispose();
    minPlayersController.dispose();
    maxPlayersController.dispose();
    recommendedPlayersController.dispose();
    bestPlayersController.dispose();
    minPlaytimeController.dispose();
    maxPlaytimeController.dispose();
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
    languagesController.dispose();
    bggRatingController.dispose();
    bggRatingCountController.dispose();
    bggRankController.dispose();
    seriesTitleController.dispose();
    itemNumberController.dispose();
    physicalFormatController.dispose();
    barcodeController.dispose();
    variantController.dispose();
    releaseDateController.dispose();
  }

  @override
  LibraryEditSelection applySelectionEdits(LibraryEditSelection selection) {
    final meta = selection.item.kindMetadata is BoardGameMetadata
        ? (selection.item.kindMetadata as BoardGameMetadata)
        : null;
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
      final designers =
          _splitValues(designersController, fallback: meta.designers);
      final artists = _splitValues(artistsController, fallback: meta.artists);
      final publishers = _splitValues(
        publisherController,
        fallback: meta.publishers.isNotEmpty
            ? meta.publishers
            : [if (meta.publisher != null) meta.publisher!],
      );
      final mechanics =
          _splitValues(mechanicsController, fallback: meta.mechanics);
      final categories =
          _splitValues(categoriesController, fallback: meta.categories);
      final families =
          _splitValues(familiesController, fallback: meta.families);
      final themes = _splitValues(themesController, fallback: meta.themes);
      final expansions =
          _splitValues(expansionsController, fallback: meta.expansions);
      final expansionFor = _nullableText(expansionForController);
      final languages =
          _splitValues(languagesController, fallback: meta.languages);
      final bggRating = _doubleValue(bggRatingController);
      final bggRatingCount = _intValue(bggRatingCountController);
      final bggRank = _intValue(bggRankController);
      final seriesTitle = _nullableText(seriesTitleController);
      final series = _updatedSeries(meta.series, seriesTitle);
      final itemNumber = _nullableText(itemNumberController);
      final physicalFormat = _nullableText(physicalFormatController);
      final barcode = _nullableText(barcodeController);
      final variant = _nullableText(variantController);
      final releaseDate = DateTime.tryParse(releaseDateController.text.trim());
      final rawPayload = _withoutEditedFields(meta.rawPayload);
      if (editionTitle != null) rawPayload['edition_title'] = editionTitle;
      if (releaseDate != null) {
        rawPayload['release_date'] = releaseDate.toIso8601String();
      }
      final updatedMeta = BoardGameMetadata(
        title: meta.title,
        originalTitle: originalTitle,
        synopsis: meta.synopsis,
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
        publishers: publishers,
        mechanics: mechanics,
        categories: categories,
        families: families,
        themes: themes,
        expansions: expansions,
        expansionFor: expansionFor,
        languages: languages,
        bggRating: bggRating,
        bggRatingCount: bggRatingCount,
        bggRank: bggRank,
        series: series,
        seriesTitle: seriesTitle,
        itemNumber: itemNumber,
        physicalFormat: physicalFormat,
        physicalFormatLabel: physicalFormat,
        publisher: publishers.firstOrNull,
        barcode: barcode,
        variant: variant,
        creators: meta.creators,
        links: meta.links,
        rawPayload: rawPayload,
      );
      return selection.copyWith(
        item: selection.item.copyWith(kindMetadata: updatedMeta),
      );
    }
    return selection;
  }
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

CatalogSeriesDetailsDto? _updatedSeries(
  CatalogSeriesDetailsDto? original,
  String? seriesTitle,
) {
  if (original == null && seriesTitle == null) return null;
  return CatalogSeriesDetailsDto(
    seriesId: original?.seriesId,
    seriesTitle: seriesTitle,
    volumeName: original?.volumeName,
    volumeNumber: original?.volumeNumber,
    volumeStartYear: original?.volumeStartYear,
    seasonNumber: original?.seasonNumber,
    episodeNumber: original?.episodeNumber,
    tags: original?.tags,
  );
}

Map<String, dynamic> _withoutEditedFields(Map<String, dynamic> rawPayload) {
  final cleaned = Map<String, dynamic>.from(rawPayload);
  for (final key in [
    'original_title',
    'year_published',
    'release_year',
    'min_players',
    'max_players',
    'recommended_players',
    'best_players',
    'min_playtime_minutes',
    'max_playtime_minutes',
    'minimum_age',
    'min_age',
    'complexity_weight',
    'weight',
    'designers',
    'artists',
    'publishers',
    'publisher',
    'mechanics',
    'categories',
    'families',
    'themes',
    'expansions',
    'expansion_for',
    'languages',
    'bgg_rating',
    'rating',
    'bgg_rating_count',
    'rating_count',
    'users_rated',
    'bgg_rank',
    'rank',
    'series',
    'series_title',
    'item_number',
    'issue_number',
    'physical_format',
    'physical_format_label',
    'edition_title',
    'release_date',
    'barcode',
    'variant',
  ]) {
    cleaned.remove(key);
  }
  return cleaned;
}

LibraryEditKindDraft createBoardGameEditDraft({
  required CatalogItem item,
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
    editionTitleController: textControllers.create(
      text: libraryKindTitleExtension(item) ?? '',
    ),
    originalTitleController: textControllers.create(
      text: meta?.originalTitle ?? item.originalTitle ?? '',
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
    variantController: textControllers.create(
      text: meta?.variant ?? '',
    ),
    releaseDateController: textControllers.create(
      text: item.releaseDate == null ? '' : formatDate(item.releaseDate!),
    ),
    releaseYearController: textControllers.create(
      text:
          meta?.yearPublished?.toString() ?? item.releaseYear?.toString() ?? '',
    ),
  );
}
