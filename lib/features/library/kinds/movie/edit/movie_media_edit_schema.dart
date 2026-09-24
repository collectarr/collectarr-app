import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_media.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_catalog_form_values.dart';

final EditSchema<MovieMedia, MovieCatalogFormValues> movieMediaEditSchema =
    EditSchema(
  title: (_) => 'Edit movie media',
  validate: (_, values) {
    if (values.title.trim().isEmpty) return 'Movie title is required';
    final runtime = values.runtimeMinutes;
    if (runtime != null && runtime < 0) {
      return 'Runtime cannot be negative';
    }
    return null;
  },
  tabs: [
    EditTabSpec<MovieCatalogFormValues>(
      id: 'media',
      label: 'Media',
      sections: [
        EditSectionSpec<MovieCatalogFormValues>(
          id: 'identity',
          label: 'Identity',
          fields: movieWorkIdentityFields(values: (values) => values),
        ),
        EditSectionSpec<MovieCatalogFormValues>(
          id: 'classification',
          label: 'Classification',
          fields: movieWorkClassificationFields(values: (values) => values),
        ),
      ],
    ),
  ],
);
