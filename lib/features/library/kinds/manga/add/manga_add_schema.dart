import 'dart:async';

import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/kinds/manga/add/manga_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/forms/manga_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/manga/forms/manga_catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/manga/vocabulary/manga_vocabularies.dart';

final AddSchema<MangaAddManualDraft> mangaAddSchema = mangaAddSchemaFor();

AddSchema<MangaAddManualDraft> mangaAddSchemaFor({
  Iterable<String>? publisherOptions,
  Iterable<String>? imprintOptions,
  Iterable<String>? formatOptions,
  FutureOr<void> Function()? onManagePublisher,
  FutureOr<void> Function()? onManageImprint,
  FutureOr<void> Function()? onManageFormat,
}) {
  MangaCatalogFormValues values(MangaAddManualDraft draft) => draft.values;

  return AddSchema<MangaAddManualDraft>(
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
    sections: [
      AddSectionSpec<MangaAddManualDraft>(
        id: 'volume',
        label: 'Volume',
        fields: [
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
      ),
      AddSectionSpec<MangaAddManualDraft>(
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
            label: 'Authors / Artists',
            value: (draft) => values(draft).authors,
            setValue: (draft, value) => values(draft).authors = value,
          ),
          LibraryTextFieldSpec<MangaAddManualDraft>(
            id: 'characters',
            label: 'Characters',
            value: (draft) => values(draft).characters,
            setValue: (draft, value) => values(draft).characters = value,
          ),
          LibraryTextFieldSpec<MangaAddManualDraft>(
            id: 'genres',
            label: 'Genres',
            value: (draft) => values(draft).genres.join(', '),
            setValue: (draft, value) => values(draft).genres = _split(value),
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
            setValue: (draft, value) => values(draft).backCoverImageUrl = value,
          ),
        ],
      ),
    ],
  );
}

List<String> _split(String value) => value
    .split(RegExp(r'[,\r\n]+'))
    .map((entry) => entry.trim())
    .where((entry) => entry.isNotEmpty)
    .toSet()
    .toList(growable: false);
