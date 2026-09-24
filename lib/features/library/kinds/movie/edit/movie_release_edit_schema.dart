import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_release.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_catalog_form_values.dart';

final EditSchema<MovieRelease, MovieCatalogFormValues> movieReleaseEditSchema =
    EditSchema(
  title: (release) => 'Edit ${release.title}',
  validate: (_, values) {
    if (values.releaseTitle.trim().isEmpty) {
      return 'Release title is required';
    }
    if (values.releaseYear != null && values.releaseYear! < 1) {
      return 'Release year must be greater than zero';
    }
    return null;
  },
  tabs: [
    EditTabSpec<MovieCatalogFormValues>(
      id: 'release',
      label: 'Release',
      sections: [
        EditSectionSpec<MovieCatalogFormValues>(
          id: 'identity',
          label: 'Identity',
          fields: movieReleaseIdentityFields(
            values: (values) => values,
          ),
        ),
        EditSectionSpec<MovieCatalogFormValues>(
          id: 'publishing',
          label: 'Publishing',
          fields: movieReleasePublishingFields(
            values: (values) => values,
          ),
        ),
      ],
    ),
  ],
);
