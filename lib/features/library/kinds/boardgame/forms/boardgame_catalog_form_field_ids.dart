import 'package:collectarr_app/features/library/kinds/boardgame/config/boardgame_field_identities.dart';

const boardGameMainFieldIds = {
  'catalog_title',
  'original_title',
  'localized_title',
  'sort_title',
  'subtitle',
  BoardGameFieldIdentities.publisherId,
  'platforms',
  BoardGameFieldIdentities.seriesId,
  'year_published',
  'categories',
  'designers',
  'artists',
  'contributors',
  'identifiers',
  'characters',
  'mechanics',
  'families',
  'themes',
  'expansions',
  BoardGameFieldIdentities.expansionForId,
  'rankings',
  'search_aliases',
  'original_language',
  'country',
  'language',
  'age_rating',
  'audience_rating',
  'release_status',
};

const boardGameEditionFieldIds = {
  'edition_title',
  'item_number',
  BoardGameFieldIdentities.barcodeId,
  'catalog_number',
  'variant',
  'format',
  BoardGameFieldIdentities.releaseDateId,
};

const boardGamePlayFieldIds = {
  BoardGameFieldIdentities.minPlayersId,
  BoardGameFieldIdentities.maxPlayersId,
  BoardGameFieldIdentities.recommendedPlayersId,
  BoardGameFieldIdentities.bestPlayersId,
  BoardGameFieldIdentities.minPlaytimeMinutesId,
  BoardGameFieldIdentities.maxPlaytimeMinutesId,
  'playing_time_minutes',
  'min_age',
  BoardGameFieldIdentities.complexityWeightId,
  BoardGameFieldIdentities.bggRatingId,
  'bgg_rating_count',
  BoardGameFieldIdentities.bggRankId,
};

const boardGameDescriptionFieldIds = {'description'};
const boardGameCoverFieldIds = {'cover_image_url'};
