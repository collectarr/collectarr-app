import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_media.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/forms/boardgame_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/forms/boardgame_catalog_form_values.dart';
import 'package:flutter/material.dart';

final EditSchema<BoardGameMedia, BoardGameCatalogFormValues>
    boardGameMediaEditSchema = EditSchema(
  title: (_) => 'Edit board game media',
  validate: (_, values) =>
      values.title.trim().isEmpty ? 'Board game title is required' : null,
  tabs: [
    EditTabSpec<BoardGameCatalogFormValues>(
      id: 'identity',
      label: 'Identity',
      icon: Icons.title,
      sections: [
        EditSectionSpec<BoardGameCatalogFormValues>(
          id: 'titles',
          label: 'Titles',
          fields: boardGameWorkFields(
            values: (draft) => draft,
            include: {
              'title',
              'original_title',
              'sort_title',
              'subtitle',
              'description',
            },
          ),
        ),
      ],
    ),
    EditTabSpec<BoardGameCatalogFormValues>(
      id: 'classification',
      label: 'Classification',
      icon: Icons.category_outlined,
      sections: [
        EditSectionSpec<BoardGameCatalogFormValues>(
          id: 'details',
          label: 'Board game details',
          fields: boardGameWorkFields(
            values: (draft) => draft,
            include: {
              'publisher',
              'platforms',
              'identifiers',
              'contributors',
              'designers',
              'artists',
              'characters',
              'mechanics',
              'categories',
              'families',
              'themes',
              'expansions',
              'expansion_for',
              'rankings',
              'search_aliases',
              'original_language',
              'work_release_date',
              'year_published',
              'min_players',
              'max_players',
              'recommended_players',
              'best_players',
              'min_playtime_minutes',
              'max_playtime_minutes',
              'minimum_age',
              'complexity_weight',
              'bgg_rating',
              'bgg_rating_count',
              'bgg_rank',
              'series_title',
              'languages',
            },
          ),
        ),
      ],
    ),
  ],
);
