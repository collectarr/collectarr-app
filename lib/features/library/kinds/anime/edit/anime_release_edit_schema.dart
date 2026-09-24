import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_release.dart';
import 'package:collectarr_app/features/library/kinds/anime/forms/anime_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/anime/forms/anime_catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/anime/vocabulary/anime_vocabularies.dart';

final EditSchema<AnimeRelease, AnimeReleaseFormValues> animeReleaseEditSchema =
    EditSchema(
  title: (release) => 'Edit ${release.title}',
  validate: (_, values) {
    if (values.title.trim().isEmpty) return 'Release title is required';
    if (values.mediaCount != null && values.mediaCount! < 0) {
      return 'Media count cannot be negative';
    }
    return null;
  },
  tabs: [
    EditTabSpec<AnimeReleaseFormValues>(
      id: 'release',
      label: 'Release',
      sections: [
        EditSectionSpec<AnimeReleaseFormValues>(
          id: 'identity',
          label: 'Identity',
          fields: animeReleaseIdentityFields<AnimeReleaseFormValues>(
            values: (values) => values,
            formatOptions: AnimeVocabularies.physicalFormat.builtIns,
            regionOptions: AnimeVocabularies.region.builtIns,
          ),
        ),
        EditSectionSpec<AnimeReleaseFormValues>(
          id: 'publishing',
          label: 'Publishing',
          fields: animeReleasePublishingFields<AnimeReleaseFormValues>(
            values: (values) => values,
          ),
        ),
      ],
    ),
  ],
);
