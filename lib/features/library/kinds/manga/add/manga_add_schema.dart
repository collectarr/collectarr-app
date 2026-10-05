import 'dart:async';

import 'package:collectarr_app/features/library/schema/library_form_schema.dart';
import 'package:collectarr_app/features/library/add/schema/library_add_catalog_title_field.dart';
import 'package:collectarr_app/features/library/kinds/manga/add/manga_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/forms/manga_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/manga/forms/manga_catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/manga/vocabulary/manga_vocabularies.dart';

final LibraryFormSchema<MangaAddManualDraft> mangaAddSchema =
    mangaAddSchemaFor();

LibraryFormSchema<MangaAddManualDraft> mangaAddSchemaFor({
  Set<String>? fieldIds,
  Map<String, String> sectionLabels = const {},
  Iterable<String>? publisherOptions,
  Iterable<String>? imprintOptions,
  Iterable<String>? formatOptions,
  FutureOr<void> Function()? onManagePublisher,
  FutureOr<void> Function()? onManageImprint,
  FutureOr<void> Function()? onManageFormat,
}) {
  MangaCatalogFormValues values(MangaAddManualDraft draft) => draft.values;

  return LibraryFormSchema<MangaAddManualDraft>(
    title: (_) => 'Manual manga volume',
    validate: (draft) {
      final pageCount = draft.values.pageCount;
      if (pageCount != null && pageCount < 0) {
        return 'Page count cannot be negative';
      }
      final year = draft.values.publicationYear;
      if (year != null && year < 1) {
        return 'Publication year must be greater than zero';
      }
      return null;
    },
    sections: filterLibraryFormSections(
      fieldIds: fieldIds,
      sectionLabels: sectionLabels,
      sections: [
        LibraryFormSectionSpec<MangaAddManualDraft>(
          id: 'volume',
          label: 'Volume',
          fields: [
            libraryAddCatalogTitleField<MangaAddManualDraft>(),
            LibraryTextFieldSpec<MangaAddManualDraft>(
              id: 'volume_number',
              label: 'Volume No.',
              value: (draft) => values(draft).volumeNumber,
              setValue: (draft, value) => values(draft).volumeNumber = value,
            ),
            LibraryTextFieldSpec<MangaAddManualDraft>(
              id: 'variant',
              label: 'Variant',
              value: (draft) => values(draft).variant,
              setValue: (draft, value) => values(draft).variant = value,
            ),
            ...mangaReleaseFields(
              values: values,
              formatOptions: formatOptions ?? MangaVocabularies.format.builtIns,
              publisherOptions:
                  publisherOptions ?? MangaVocabularies.publisher.builtIns,
              imprintOptions:
                  imprintOptions ?? MangaVocabularies.imprint.builtIns,
              onManageFormat: onManageFormat,
              onManagePublisher: onManagePublisher,
              onManageImprint: onManageImprint,
            ),
            LibraryNumberFieldSpec<MangaAddManualDraft>(
              id: 'publication_year',
              label: 'Publication year',
              value: (draft) => values(draft).publicationYear?.toDouble(),
              setValue: (draft, value) =>
                  values(draft).publicationYear = value?.toInt(),
              minimum: 1,
            ),
          ],
          fullWidthFieldIds: const {'catalog_title'},
        ),
        LibraryFormSectionSpec<MangaAddManualDraft>(
          id: 'publication',
          label: 'Series and metadata',
          fields: [
            LibraryTextFieldSpec<MangaAddManualDraft>(
              id: 'series_group',
              label: 'Series group',
              value: (draft) => values(draft).seriesGroup,
              setValue: (draft, value) => values(draft).seriesGroup = value,
            ),
            LibraryTextFieldSpec<MangaAddManualDraft>(
              id: 'authors',
              label: 'Authors',
              value: (draft) => values(draft).authors,
              setValue: (draft, value) => values(draft).authors = value,
            ),
            LibraryTextFieldSpec<MangaAddManualDraft>(
              id: 'artists',
              label: 'Artists',
              value: (draft) => values(draft).artists,
              setValue: (draft, value) => values(draft).artists = value,
            ),
            LibraryTextFieldSpec<MangaAddManualDraft>(
              id: 'characters',
              label: 'Characters',
              value: (draft) => values(draft).characters,
              setValue: (draft, value) => values(draft).characters = value,
            ),
            LibraryMultiVocabularyFieldSpec<MangaAddManualDraft, String>(
              id: 'genres',
              label: 'Genres',
              values: (draft) => values(draft).genres.toSet(),
              setValues: (draft, value) =>
                  values(draft).genres = value.toList(growable: false),
              options: const [],
              allowCustomValues: true,
            ),
            LibraryMultiVocabularyFieldSpec<MangaAddManualDraft, String>(
              id: 'themes',
              label: 'Themes',
              values: (draft) => values(draft).themes.toSet(),
              setValues: (draft, value) =>
                  values(draft).themes = value.toList(growable: false),
              options: const [],
              allowCustomValues: true,
            ),
            LibraryTextFieldSpec<MangaAddManualDraft>(
              id: 'age_rating',
              label: 'Age rating',
              value: (draft) => values(draft).ageRating,
              setValue: (draft, value) => values(draft).ageRating = value,
            ),
            LibraryTextFieldSpec<MangaAddManualDraft>(
              id: 'country',
              label: 'Country',
              value: (draft) => values(draft).country,
              setValue: (draft, value) => values(draft).country = value,
            ),
            LibraryTextFieldSpec<MangaAddManualDraft>(
              id: 'demographic',
              label: 'Demographic',
              value: (draft) => values(draft).demographic,
              setValue: (draft, value) => values(draft).demographic = value,
            ),
            LibraryTextFieldSpec<MangaAddManualDraft>(
              id: 'publication_status',
              label: 'Publication status',
              value: (draft) => values(draft).status,
              setValue: (draft, value) => values(draft).status = value,
            ),
            LibraryTextFieldSpec<MangaAddManualDraft>(
              id: 'serialization_platform',
              label: 'Serialization platform',
              value: (draft) => values(draft).serializationPlatform,
              setValue: (draft, value) =>
                  values(draft).serializationPlatform = value,
            ),
            LibraryTextFieldSpec<MangaAddManualDraft>(
              id: 'synopsis',
              label: 'Synopsis',
              value: (draft) => values(draft).description,
              setValue: (draft, value) => values(draft).description = value,
              maxLines: 4,
            ),
            LibraryTextFieldSpec<MangaAddManualDraft>(
              id: 'back_cover_image_url',
              label: 'Back cover image URL',
              value: (draft) => values(draft).backCoverImageUrl,
              setValue: (draft, value) =>
                  values(draft).backCoverImageUrl = value,
            ),
          ],
        ),
      ],
    ),
  );
}
