import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_edition.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/forms/boardgame_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/forms/boardgame_catalog_form_values.dart';
import 'package:flutter/material.dart';

final EditSchema<BoardGameEdition, BoardGameCatalogFormValues>
    boardGameEditionEditSchema = EditSchema(
  title: (edition) => 'Edit ${edition.title}',
  validate: (_, values) {
    if (values.editionTitle.trim().isEmpty &&
        values.releaseTitle.trim().isEmpty) {
      return 'Edition title is required';
    }
    if (values.editionMinPlayers != null &&
        values.editionMaxPlayers != null &&
        values.editionMinPlayers! > values.editionMaxPlayers!) {
      return 'Minimum players cannot exceed maximum players';
    }
    return null;
  },
  tabs: [
    EditTabSpec<BoardGameCatalogFormValues>(
      id: 'identity',
      label: 'Release',
      icon: Icons.album_outlined,
      sections: [
        EditSectionSpec<BoardGameCatalogFormValues>(
          id: 'titles',
          label: 'Titles and identifiers',
          fields: boardGameEditionFields(
            values: (draft) => draft,
            include: {
              'title',
              'edition_title',
              'barcode',
              'catalog_number',
              'item_number',
              'variant',
              'format',
            },
          ),
        ),
      ],
    ),
    EditTabSpec<BoardGameCatalogFormValues>(
      id: 'publication',
      label: 'Publication',
      icon: Icons.public,
      sections: [
        EditSectionSpec<BoardGameCatalogFormValues>(
          id: 'publication_details',
          label: 'Publication details',
          fields: boardGameEditionFields(
            values: (draft) => draft,
            include: {
              'publisher',
              'country',
              'language',
              'release_date',
              'release_status',
            },
          ),
        ),
      ],
    ),
    EditTabSpec<BoardGameCatalogFormValues>(
      id: 'details',
      label: 'Details',
      icon: Icons.info_outline,
      sections: [
        EditSectionSpec<BoardGameCatalogFormValues>(
          id: 'ratings_and_media',
          label: 'Ratings and media',
          fields: boardGameEditionFields(
            values: (draft) => draft,
            include: {
              'age_rating',
              'audience_rating',
              'cover_image_url',
              'back_cover_image_url',
              'description',
            },
          ),
        ),
      ],
    ),
    EditTabSpec<BoardGameCatalogFormValues>(
      id: 'play_profile',
      label: 'Play profile',
      icon: Icons.groups_outlined,
      sections: [
        EditSectionSpec<BoardGameCatalogFormValues>(
          id: 'players',
          label: 'Players and time',
          fields: boardGameEditionFields(
            values: (draft) => draft,
            include: {
              'min_players',
              'max_players',
              'min_age',
              'playing_time_minutes',
            },
          ),
        ),
      ],
    ),
  ],
);
