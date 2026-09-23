import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_release.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/release/comic_release_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/vocabulary/comic_vocabularies.dart';
import 'package:flutter/material.dart';

final EditSchema<ComicRelease, ComicReleaseEditDraft> comicReleaseEditSchema =
    EditSchema(
  title: (release) => 'Edit release: ${release.title}',
  validate: (_, draft) {
    if (draft.id.trim().isEmpty) return 'Release identifier is required';
    if (draft.title.trim().isEmpty) return 'Release title is required';
    return null;
  },
  tabs: [
    EditTabSpec(
      id: 'release',
      label: 'Release',
      icon: Icons.album,
      sections: [
        EditSectionSpec(
          id: 'release_identity',
          label: 'Identity',
          fields: [
            LibraryReadOnlyFieldSpec<ComicReleaseEditDraft, String>(
              id: 'release_id',
              label: 'Release ID',
              value: (draft) => draft.id,
              display: (value) => value ?? '',
            ),
            LibraryTextFieldSpec<ComicReleaseEditDraft>(
              id: 'release_title',
              label: 'Edition title',
              value: (draft) => draft.title,
              setValue: (draft, value) => draft.title = value,
              validator: (draft) => draft.title.trim().isEmpty
                  ? 'Release title is required'
                  : null,
            ),
          ],
        ),
        EditSectionSpec(
          id: 'release_publication',
          label: 'Publication',
          fields: [
            LibraryVocabularyFieldSpec<ComicReleaseEditDraft, String>(
              id: 'publisher',
              label: 'Publisher',
              value: (draft) => draft.publisher,
              setValue: (draft, value) => draft.publisher = value,
              options: _options(ComicVocabularies.publisher.builtIns),
            ),
            LibraryVocabularyFieldSpec<ComicReleaseEditDraft, String>(
              id: 'imprint',
              label: 'Imprint',
              value: (draft) => draft.imprint,
              setValue: (draft, value) => draft.imprint = value,
              options: _options(ComicVocabularies.imprint.builtIns),
            ),
            LibraryTextFieldSpec<ComicReleaseEditDraft>(
              id: 'isbn',
              label: 'ISBN',
              value: (draft) => draft.isbn ?? '',
              setValue: (draft, value) => draft.isbn = value,
            ),
            LibraryTextFieldSpec<ComicReleaseEditDraft>(
              id: 'upc',
              label: 'UPC',
              value: (draft) => draft.upc ?? '',
              setValue: (draft, value) => draft.upc = value,
            ),
            LibraryDateFieldSpec<ComicReleaseEditDraft>(
              id: 'release_date',
              label: 'Release date',
              value: (draft) => draft.releaseDate,
              setValue: (draft, value) => draft.releaseDate = value,
            ),
          ],
        ),
        EditSectionSpec(
          id: 'release_artwork',
          label: 'Artwork',
          fields: [
            LibraryImageFieldSpec<ComicReleaseEditDraft, String>(
              id: 'cover_image_url',
              label: 'Cover image',
              value: (draft) => draft.coverImageUrl,
              setValue: (draft, value) => draft.coverImageUrl = value,
            ),
          ],
        ),
        EditSectionSpec(
          id: 'release_variants',
          label: 'Variants',
          fields: [
            LibraryCustomFieldSpec<ComicReleaseEditDraft>(
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

List<LibraryFieldOption<String>> _options(Iterable<String> values) => [
      for (final value in values)
        LibraryFieldOption(value: value, label: value),
    ];
