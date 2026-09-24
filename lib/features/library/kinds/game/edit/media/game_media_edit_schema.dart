import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_media.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_form_values.dart';
import 'package:flutter/material.dart';

final EditSchema<GameMedia, GameCatalogFormValues> gameMediaEditSchema =
    EditSchema(
  title: (_) => 'Edit game media',
  validate: (_, values) =>
      values.title.trim().isEmpty ? 'Game title is required' : null,
  tabs: [
    EditTabSpec<GameCatalogFormValues>(
      id: 'identity',
      label: 'Identity',
      icon: Icons.title,
      sections: [
        EditSectionSpec<GameCatalogFormValues>(
          id: 'titles',
          label: 'Titles',
          fields: gameWorkFields(
            values: (draft) => draft,
            include: {'title', 'sort_title', 'subtitle', 'description'},
          ),
        ),
      ],
    ),
    EditTabSpec<GameCatalogFormValues>(
      id: 'classification',
      label: 'Classification',
      icon: Icons.category_outlined,
      sections: [
        EditSectionSpec<GameCatalogFormValues>(
          id: 'details',
          label: 'Game details',
          fields: gameWorkFields(
            values: (draft) => draft,
            include: {
              'publisher',
              'platforms',
              'identifiers',
              'company_roles',
              'developers',
              'age_ratings',
              'genres',
              'original_language',
              'work_release_date',
              'search_aliases',
              'franchise',
              'series',
              'languages',
              'country',
            },
          ),
        ),
      ],
    ),
  ],
);
