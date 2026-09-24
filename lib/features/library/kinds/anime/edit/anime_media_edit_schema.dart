import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_media.dart';
import 'package:collectarr_app/features/library/kinds/anime/forms/anime_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/anime/forms/anime_catalog_form_values.dart';

final EditSchema<AnimeMedia, AnimeMediaFormValues> animeMediaEditSchema =
    EditSchema(
  title: (media) => 'Edit ${media.title}',
  validate: (_, values) {
    if (values.title.trim().isEmpty) return 'Anime title is required';
    if (values.seasonYear != null && values.seasonYear! < 0) {
      return 'Season year cannot be negative';
    }
    if (values.episodeCount != null && values.episodeCount! < 0) {
      return 'Episode count cannot be negative';
    }
    if (values.episodeRuntimeMinutes != null &&
        values.episodeRuntimeMinutes! < 0) {
      return 'Episode runtime cannot be negative';
    }
    if (values.startDate != null &&
        values.endDate != null &&
        values.endDate!.isBefore(values.startDate!)) {
      return 'End date cannot be before start date';
    }
    return null;
  },
  tabs: [
    EditTabSpec<AnimeMediaFormValues>(
      id: 'anime',
      label: 'Anime',
      sections: [
        EditSectionSpec<AnimeMediaFormValues>(
          id: 'identity',
          label: 'Identity',
          fields: animeMediaIdentityFields<AnimeMediaFormValues>(
            values: (values) => values,
          ),
        ),
        EditSectionSpec<AnimeMediaFormValues>(
          id: 'classification',
          label: 'Classification',
          fields: animeMediaClassificationFields<AnimeMediaFormValues>(
            values: (values) => values,
          ),
        ),
        EditSectionSpec<AnimeMediaFormValues>(
          id: 'production',
          label: 'Production',
          fields: animeMediaProductionFields<AnimeMediaFormValues>(
            values: (values) => values,
          ),
        ),
        EditSectionSpec<AnimeMediaFormValues>(
          id: 'schedule',
          label: 'Schedule',
          fields: animeMediaScheduleFields<AnimeMediaFormValues>(
            values: (values) => values,
          ),
        ),
      ],
    ),
  ],
);
