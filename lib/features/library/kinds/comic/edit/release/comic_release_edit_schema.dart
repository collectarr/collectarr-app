import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_release.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/comic_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/comic_catalog_form_values.dart';
import 'package:flutter/material.dart';

final EditSchema<ComicRelease, ComicReleaseFormValues> comicReleaseEditSchema =
    EditSchema(
  title: (release) => 'Edit release: ${release.title}',
  validate: (_, values) {
    if (values.id.trim().isEmpty) return 'Release identifier is required';
    if (values.title.trim().isEmpty) return 'Release title is required';
    return null;
  },
  tabs: [
    EditTabSpec<ComicReleaseFormValues>(
      id: 'release',
      label: 'Release',
      icon: Icons.album,
      sections: [
        EditSectionSpec<ComicReleaseFormValues>(
          id: 'release_identity',
          label: 'Identity',
          fields: [
            LibraryReadOnlyFieldSpec<ComicReleaseFormValues, String>(
              id: 'release_id',
              label: 'Release ID',
              value: (values) => values.id,
              display: (value) => value ?? '',
            ),
            ...comicReleaseFields(values: (values) => values),
          ],
        ),
        EditSectionSpec<ComicReleaseFormValues>(
          id: 'release_variants',
          label: 'Variants',
          fields: [
            LibraryCustomFieldSpec<ComicReleaseFormValues>(
              id: 'variants',
              label: 'Release variants',
              builder: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ],
    ),
  ],
);
