import 'package:collectarr_app/features/library/kinds/game/config/game_field_identities.dart';

const gameMainFieldIds = {
  'catalog_title',
  'display_title',
  'sort_title',
  'original_title',
  'localized_title',
  'subtitle',
  'platforms',
  'publisher',
  'identifiers',
  'company_roles',
  'search_aliases',
  'original_language',
  'developers',
  'genres',
  'age_ratings',
  'languages',
  'country',
  GameFieldIdentities.franchiseId,
  'series',
};

const gameEditionFieldIds = {
  'edition_title',
  'region',
  'format',
  GameFieldIdentities.releaseDateId,
  'catalog_number',
  GameFieldIdentities.barcodeId,
  'release_year',
  'variant',
  'release_status',
  'language',
};

const gameCoverFieldIds = {
  'cover_image_url',
  'thumbnail_image_url',
};

const gameDescriptionFieldIds = {'description'};
