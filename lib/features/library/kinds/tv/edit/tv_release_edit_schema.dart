import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';
import 'package:collectarr_app/features/library/kinds/tv/forms/tv_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/tv/forms/tv_catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/tv/vocabulary/tv_vocabularies.dart';

final EditSchema<TvRelease, TvReleaseFormValues> tvReleaseEditSchema =
    EditSchema(
  title: (release) => 'Edit ${release.title}',
  validate: (_, values) {
    if (values.title.trim().isEmpty) return 'Release title is required';
    return null;
  },
  tabs: [
    EditTabSpec<TvReleaseFormValues>(
      id: 'release',
      label: 'Release',
      sections: [
        EditSectionSpec<TvReleaseFormValues>(
          id: 'identity',
          label: 'Identity',
          fields: tvReleaseIdentityFields<TvReleaseFormValues>(
            values: (values) => values,
            formatOptions: TvVocabularies.physicalFormat.builtIns,
            regionOptions: TvVocabularies.region.builtIns,
          ),
        ),
        EditSectionSpec<TvReleaseFormValues>(
          id: 'publishing',
          label: 'Publishing',
          fields: tvReleasePublishingFields<TvReleaseFormValues>(
            values: (values) => values,
          ),
        ),
      ],
    ),
  ],
);
