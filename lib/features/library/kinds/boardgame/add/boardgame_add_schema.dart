import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/add/boardgame_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/forms/boardgame_catalog_field_specs.dart';

final AddSchema<BoardgameAddManualDraft> boardGameAddSchema = AddSchema(
  title: (_) => 'Manual board game',
  validate: (draft) {
    final values = draft.values;
    if (values.yearPublished != null && values.yearPublished! < 1) {
      return 'Year published must be greater than zero';
    }
    if (values.releaseDate != null && values.releaseDate!.year < 1) {
      return 'Release date is invalid';
    }
    if (values.minPlayers != null &&
        values.maxPlayers != null &&
        values.minPlayers! > values.maxPlayers!) {
      return 'Minimum players cannot exceed maximum players';
    }
    return null;
  },
  sections: [
    AddSectionSpec<BoardgameAddManualDraft>(
      id: 'work',
      label: 'Board game details',
      fields: boardGameWorkFields(
        values: (draft) => draft.values,
        include: {
          'original_title',
          'designers',
          'artists',
          'characters',
          'mechanics',
          'categories',
          'families',
          'themes',
          'expansions',
          'expansion_for',
          'languages',
          'year_published',
          'min_players',
          'max_players',
          'recommended_players',
          'best_players',
          'min_playtime_minutes',
          'max_playtime_minutes',
          'minimum_age',
          'complexity_weight',
          'series_title',
          'description',
        },
      ),
    ),
    AddSectionSpec<BoardgameAddManualDraft>(
      id: 'edition',
      label: 'Edition',
      fields: boardGameEditionFields(
        values: (draft) => draft.values,
        include: {
          'title',
          'edition_title',
          'publisher',
          'barcode',
          'catalog_number',
          'item_number',
          'variant',
          'format',
          'country',
          'language',
          'release_date',
          'release_status',
          'audience_rating',
          'cover_image_url',
          'back_cover_image_url',
        },
      ),
    ),
  ],
);
