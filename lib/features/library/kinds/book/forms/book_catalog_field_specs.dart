import 'dart:async';

import 'package:collectarr_app/features/library/kinds/book/forms/book_catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/book/vocabulary/book_vocabularies.dart';
import 'package:collectarr_app/features/library/schema/library_field_spec.dart';

typedef BookFormValuesReader<TDraft> = BookCatalogFormValues Function(
  TDraft draft,
);

List<LibraryFieldSpec<TDraft>> bookWorkFields<TDraft>({
  required BookFormValuesReader<TDraft> values,
  bool includeTitle = true,
  Set<String>? include,
  String descriptionLabel = 'Description',
}) =>
    [
      if (includeTitle)
        LibraryTextFieldSpec<TDraft>(
          id: 'title',
          label: 'Title',
          value: (draft) => values(draft).title,
          setValue: (draft, value) => values(draft).title = value,
        ),
      LibraryTextFieldSpec<TDraft>(
        id: 'sort_title',
        label: 'Sort title',
        value: (draft) => values(draft).sortTitle,
        setValue: (draft, value) => values(draft).sortTitle = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'subtitle',
        label: 'Subtitle',
        value: (draft) => values(draft).subtitle,
        setValue: (draft, value) => values(draft).subtitle = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'description',
        label: descriptionLabel,
        value: (draft) => values(draft).description,
        setValue: (draft, value) => values(draft).description = value,
        maxLines: 4,
      ),
    ].where((field) => include == null || include.contains(field.id)).toList();

List<LibraryFieldSpec<TDraft>> bookWorkPublicationFields<TDraft>({
  required BookFormValuesReader<TDraft> values,
  Set<String>? include,
}) =>
    [
      LibraryTextFieldSpec<TDraft>(
        id: 'original_language',
        label: 'Original language',
        value: (draft) => values(draft).originalLanguage,
        setValue: (draft, value) => values(draft).originalLanguage = value,
      ),
      LibraryDateFieldSpec<TDraft>(
        id: 'first_publication_date',
        label: 'First publication date',
        value: (draft) => values(draft).firstPublicationDate,
        setValue: (draft, value) => values(draft).firstPublicationDate = value,
      ),
      LibraryDateFieldSpec<TDraft>(
        id: 'original_publication_date',
        label: 'Original publication date',
        value: (draft) => values(draft).originalPublicationDate,
        setValue: (draft, value) =>
            values(draft).originalPublicationDate = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'genres',
        label: 'Genres',
        value: (draft) => values(draft).genres.join(', '),
        setValue: (draft, value) => values(draft).genres = _split(value),
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'search_aliases',
        label: 'Search aliases',
        value: (draft) => values(draft).searchAliases.join(', '),
        setValue: (draft, value) => values(draft).searchAliases = _split(value),
      ),
    ].where((field) => include == null || include.contains(field.id)).toList();

List<LibraryFieldSpec<TDraft>> bookReleaseFields<TDraft>({
  required BookFormValuesReader<TDraft> values,
  Set<String>? include,
  String titleLabel = 'Title',
  Iterable<String>? formatOptions,
  Iterable<String>? bindingOptions,
  Iterable<String>? publisherOptions,
  Iterable<String>? languageOptions,
  FutureOr<void> Function()? onManageFormat,
  FutureOr<void> Function()? onManageBinding,
  FutureOr<void> Function()? onManagePublisher,
}) =>
    [
      LibraryTextFieldSpec<TDraft>(
        id: 'title',
        label: titleLabel,
        value: (draft) => values(draft).editionTitle,
        setValue: (draft, value) => values(draft).editionTitle = value,
      ),
      _vocabulary<TDraft>(
        id: 'binding',
        label: 'Binding',
        value: (draft) => values(draft).binding,
        setValue: (draft, value) => values(draft).binding = value,
        options: bindingOptions ?? BookVocabularies.binding.builtIns,
        onManage: onManageBinding,
      ),
      _vocabulary<TDraft>(
        id: 'format',
        label: 'Format',
        value: (draft) => values(draft).format,
        setValue: (draft, value) => values(draft).format = value,
        options: formatOptions ?? BookVocabularies.format.builtIns,
        onManage: onManageFormat,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'isbn',
        label: 'ISBN',
        value: (draft) => values(draft).isbn,
        setValue: (draft, value) => values(draft).isbn = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'upc',
        label: 'UPC',
        value: (draft) => values(draft).upc,
        setValue: (draft, value) => values(draft).upc = value,
      ),
      _vocabulary<TDraft>(
        id: 'publisher',
        label: 'Publisher',
        value: (draft) => values(draft).publisher,
        setValue: (draft, value) => values(draft).publisher = value,
        options: publisherOptions ?? BookVocabularies.publisher.builtIns,
        onManage: onManagePublisher,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'distributor',
        label: 'Distributor',
        value: (draft) => values(draft).distributor,
        setValue: (draft, value) => values(draft).distributor = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'imprint',
        label: 'Imprint',
        value: (draft) => values(draft).imprint,
        setValue: (draft, value) => values(draft).imprint = value,
      ),
      LibraryDateFieldSpec<TDraft>(
        id: 'release_date',
        label: 'Release date',
        value: (draft) => values(draft).releaseDate,
        setValue: (draft, value) => values(draft).releaseDate = value,
      ),
      LibraryNumberFieldSpec<TDraft>(
        id: 'page_count',
        label: 'Page count',
        value: (draft) => values(draft).pageCount?.toDouble(),
        setValue: (draft, value) => values(draft).pageCount = value?.toInt(),
        minimum: 0,
      ),
      _vocabulary<TDraft>(
        id: 'language',
        label: 'Language',
        value: (draft) => values(draft).language,
        setValue: (draft, value) => values(draft).language = value,
        options: languageOptions ?? BookVocabularies.language.builtIns,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'region',
        label: 'Region',
        value: (draft) => values(draft).region,
        setValue: (draft, value) => values(draft).region = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'release_status',
        label: 'Release status',
        value: (draft) => values(draft).releaseStatus,
        setValue: (draft, value) => values(draft).releaseStatus = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'edition_statement',
        label: 'Edition statement',
        value: (draft) => values(draft).editionStatement,
        setValue: (draft, value) => values(draft).editionStatement = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'dimensions',
        label: 'Dimensions',
        value: (draft) => values(draft).dimensions,
        setValue: (draft, value) => values(draft).dimensions = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'description',
        label: 'Description',
        value: (draft) => values(draft).description,
        setValue: (draft, value) => values(draft).description = value,
        maxLines: 4,
      ),
      LibraryToggleFieldSpec<TDraft>(
        id: 'first_edition',
        label: 'First edition',
        value: (draft) => values(draft).firstEdition,
        setValue: (draft, value) => values(draft).firstEdition = value,
      ),
      LibraryNumberFieldSpec<TDraft>(
        id: 'audio_length_minutes',
        label: 'Audio length (minutes)',
        value: (draft) => values(draft).audioLengthMinutes?.toDouble(),
        setValue: (draft, value) =>
            values(draft).audioLengthMinutes = value?.toInt(),
        minimum: 0,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'cover_image_url',
        label: 'Cover image URL',
        value: (draft) => values(draft).coverImageUrl,
        setValue: (draft, value) => values(draft).coverImageUrl = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'thumbnail_image_url',
        label: 'Thumbnail image URL',
        value: (draft) => values(draft).thumbnailImageUrl,
        setValue: (draft, value) => values(draft).thumbnailImageUrl = value,
      ),
    ].where((field) => include == null || include.contains(field.id)).toList();

LibraryVocabularyFieldSpec<TDraft, String> _vocabulary<TDraft>({
  required String id,
  required String label,
  required String Function(TDraft draft) value,
  required void Function(TDraft draft, String value) setValue,
  required Iterable<String> options,
  FutureOr<void> Function()? onManage,
}) =>
    LibraryVocabularyFieldSpec<TDraft, String>(
      id: id,
      label: label,
      value: (draft) {
        final current = value(draft).trim();
        return current.isEmpty ? null : current;
      },
      setValue: (draft, next) => setValue(draft, next ?? ''),
      options: [
        for (final option in options)
          LibraryFieldOption<String>(value: option, label: option),
      ],
      onManage: onManage == null ? null : (_) => onManage(),
    );

List<String> _split(String value) => value
    .split(RegExp(r'[,\r\n]+'))
    .map((entry) => entry.trim())
    .where((entry) => entry.isNotEmpty)
    .toSet()
    .toList(growable: false);
