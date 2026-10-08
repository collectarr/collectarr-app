import 'package:collectarr_app/features/library/config/library_kind_field_metadata.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_id.dart';

/// Canonical Board Game field facts shared by forms, workspace, and filters.
abstract final class BoardGameFieldIdentities {
  static const publisherId = 'boardgame.publisher';
  static const publisherLabel = 'Publisher';
  static const seriesId = 'boardgame.series';
  static const seriesLabel = 'Series';
  static const releaseDateId = 'boardgame.release_date';
  static const releaseDateLabel = 'Release Date';
  static const barcodeId = 'boardgame.barcode';
  static const barcodeLabel = 'Barcode';
  static const minPlayersId = 'boardgame.min_players';
  static const minPlayersLabel = 'Minimum players';
  static const maxPlayersId = 'boardgame.max_players';
  static const maxPlayersLabel = 'Maximum players';
  static const recommendedPlayersId = 'boardgame.recommended_players';
  static const recommendedPlayersLabel = 'Recommended players';
  static const bestPlayersId = 'boardgame.best_players';
  static const bestPlayersLabel = 'Best player count';
  static const minPlaytimeMinutesId = 'boardgame.min_playtime_minutes';
  static const minPlaytimeMinutesLabel = 'Minimum play time (minutes)';
  static const maxPlaytimeMinutesId = 'boardgame.max_playtime_minutes';
  static const maxPlaytimeMinutesLabel = 'Maximum play time (minutes)';
  static const complexityWeightId = 'boardgame.complexity_weight';
  static const complexityWeightLabel = 'Complexity weight';
  static const bggRatingId = 'boardgame.bgg_rating';
  static const bggRatingLabel = 'BoardGameGeek rating';
  static const bggRankId = 'boardgame.bgg_rank';
  static const bggRankLabel = 'BoardGameGeek rank';
  static const expansionForId = 'boardgame.expansion_for';
  static const expansionForLabel = 'Expansion for';

  static const publisherVocabulary =
      VocabularyId<String>('boardgame.publisher');

  static const publisher = LibraryKindFieldMetadata(
    id: publisherId,
    label: publisherLabel,
    valueType: LibraryFieldValueType.text,
    catalogPath: 'publisher',
    origin: LibraryFieldValueOrigin.derived,
    searchable: true,
    filterable: true,
    sortable: true,
    groupable: true,
    editable: true,
    vocabulary: publisherVocabulary,
  );
  static const series = LibraryKindFieldMetadata(
    id: seriesId,
    label: seriesLabel,
    valueType: LibraryFieldValueType.text,
    catalogPath: 'series_title',
    filterable: true,
    editable: true,
  );
  static const releaseDate = LibraryKindFieldMetadata(
    id: releaseDateId,
    label: releaseDateLabel,
    valueType: LibraryFieldValueType.partialDate,
    catalogPath: 'release_date',
    origin: LibraryFieldValueOrigin.derived,
    sortable: true,
    editable: true,
  );
  static const barcode = LibraryKindFieldMetadata(
    id: barcodeId,
    label: barcodeLabel,
    valueType: LibraryFieldValueType.text,
    catalogPath: 'barcode',
    searchable: true,
    editable: true,
  );
  static const minPlayers = LibraryKindFieldMetadata(
    id: minPlayersId,
    label: minPlayersLabel,
    valueType: LibraryFieldValueType.number,
    catalogPath: 'min_players',
    editable: true,
  );
  static const maxPlayers = LibraryKindFieldMetadata(
    id: maxPlayersId,
    label: maxPlayersLabel,
    valueType: LibraryFieldValueType.number,
    catalogPath: 'max_players',
    editable: true,
  );
  static const recommendedPlayers = LibraryKindFieldMetadata(
    id: recommendedPlayersId,
    label: recommendedPlayersLabel,
    valueType: LibraryFieldValueType.text,
    catalogPath: 'recommended_players',
    editable: true,
  );
  static const bestPlayers = LibraryKindFieldMetadata(
    id: bestPlayersId,
    label: bestPlayersLabel,
    valueType: LibraryFieldValueType.text,
    catalogPath: 'best_players',
    groupable: true,
    editable: true,
  );
  static const minPlaytimeMinutes = LibraryKindFieldMetadata(
    id: minPlaytimeMinutesId,
    label: minPlaytimeMinutesLabel,
    valueType: LibraryFieldValueType.number,
    catalogPath: 'min_playtime_minutes',
    editable: true,
  );
  static const maxPlaytimeMinutes = LibraryKindFieldMetadata(
    id: maxPlaytimeMinutesId,
    label: maxPlaytimeMinutesLabel,
    valueType: LibraryFieldValueType.number,
    catalogPath: 'max_playtime_minutes',
    editable: true,
  );
  static const complexityWeight = LibraryKindFieldMetadata(
    id: complexityWeightId,
    label: complexityWeightLabel,
    valueType: LibraryFieldValueType.number,
    catalogPath: 'complexity_weight',
    sortable: true,
    editable: true,
  );
  static const bggRating = LibraryKindFieldMetadata(
    id: bggRatingId,
    label: bggRatingLabel,
    valueType: LibraryFieldValueType.number,
    catalogPath: 'bgg_rating',
    sortable: true,
    editable: true,
  );
  static const bggRank = LibraryKindFieldMetadata(
    id: bggRankId,
    label: bggRankLabel,
    valueType: LibraryFieldValueType.number,
    catalogPath: 'bgg_rank',
    sortable: true,
    editable: true,
  );
  static const expansionFor = LibraryKindFieldMetadata(
    id: expansionForId,
    label: expansionForLabel,
    valueType: LibraryFieldValueType.text,
    catalogPath: 'expansion_for',
    editable: true,
  );
}
