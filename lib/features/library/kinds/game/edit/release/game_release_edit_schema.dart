import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_release.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_form_values.dart';
import 'package:flutter/material.dart';

final EditSchema<GameRelease, GameCatalogFormValues> gameReleaseEditSchema =
    EditSchema(
  title: (release) => 'Edit ${release.title}',
  validate: (_, values) =>
      values.releaseTitle.trim().isEmpty ? 'Release title is required' : null,
  tabs: [
    EditTabSpec<GameCatalogFormValues>(
      id: 'release',
      label: 'Release',
      icon: Icons.album_outlined,
      sections: [
        EditSectionSpec<GameCatalogFormValues>(
          id: 'identity',
          label: 'Identity',
          fields: gameReleaseFields(
            values: (draft) => draft,
            include: {
              'release_title',
              'platform',
              'region',
              'format',
              'release_date',
            },
          ),
        ),
        EditSectionSpec<GameCatalogFormValues>(
          id: 'publishing',
          label: 'Publishing',
          fields: gameReleaseFields(
            values: (draft) => draft,
            include: {
              'publisher',
              'catalog_number',
              'barcode',
              'release_status',
              'language',
              'cover_image_url',
              'release_year',
              'variant',
              'back_cover_image_url',
            },
          ),
        ),
      ],
    ),
  ],
);
