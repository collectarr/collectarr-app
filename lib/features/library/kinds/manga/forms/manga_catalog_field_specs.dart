import 'dart:async';

import 'package:collectarr_app/features/library/kinds/manga/forms/manga_catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/manga/vocabulary/manga_vocabularies.dart';
import 'package:collectarr_app/features/library/forms/library_field_spec.dart';

typedef MangaFormValuesReader<TDraft> = MangaCatalogFormValues Function(
  TDraft draft,
);

List<LibraryFieldSpec<TDraft>> mangaReleaseFields<TDraft>({
  required MangaFormValuesReader<TDraft> values,
  Set<String>? include,
  Iterable<String>? formatOptions,
  Iterable<String>? publisherOptions,
  Iterable<String>? imprintOptions,
  FutureOr<void> Function()? onManageFormat,
  FutureOr<void> Function()? onManagePublisher,
  FutureOr<void> Function()? onManageImprint,
}) =>
    [
      LibraryTextFieldSpec<TDraft>(
        id: 'release_title',
        label: 'Edition title',
        value: (draft) => values(draft).releaseTitle,
        setValue: (draft, value) => values(draft).releaseTitle = value,
      ),
      _vocabularyOrText<TDraft>(
        id: 'format',
        label: 'Format',
        value: (draft) => values(draft).format,
        setValue: (draft, value) => values(draft).format = value,
        options: formatOptions ?? MangaVocabularies.format.builtIns,
        onManage: onManageFormat,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'binding',
        label: 'Binding',
        value: (draft) => values(draft).binding,
        setValue: (draft, value) => values(draft).binding = value,
      ),
      _vocabularyOrText<TDraft>(
        id: 'publisher',
        label: 'Publisher',
        value: (draft) => values(draft).publisher,
        setValue: (draft, value) => values(draft).publisher = value,
        options: publisherOptions ?? MangaVocabularies.publisher.builtIns,
        onManage: onManagePublisher,
      ),
      _vocabularyOrText<TDraft>(
        id: 'imprint',
        label: 'Imprint',
        value: (draft) => values(draft).imprint,
        setValue: (draft, value) => values(draft).imprint = value,
        options: imprintOptions ?? MangaVocabularies.imprint.builtIns,
        onManage: onManageImprint,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'isbn',
        label: 'ISBN',
        value: (draft) => values(draft).isbn,
        setValue: (draft, value) => values(draft).isbn = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'barcode',
        label: 'Barcode',
        value: (draft) => values(draft).barcode,
        setValue: (draft, value) => values(draft).barcode = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'language',
        label: 'Language',
        value: (draft) => values(draft).language,
        setValue: (draft, value) => values(draft).language = value,
      ),
      LibraryDateFieldSpec<TDraft>(
        id: 'release_date',
        label: 'Publication date',
        value: (draft) => values(draft).releaseDate,
        setValue: (draft, value) {
          values(draft)
            ..releaseDate = value
            ..releaseDateEdited = true;
        },
      ),
      LibraryNumberFieldSpec<TDraft>(
        id: 'page_count',
        label: 'Page count',
        value: (draft) => values(draft).pageCount?.toDouble(),
        setValue: (draft, value) => values(draft).pageCount = value?.toInt(),
        minimum: 0,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'release_description',
        label: 'Description',
        value: (draft) => values(draft).releaseDescription,
        setValue: (draft, value) => values(draft).releaseDescription = value,
        maxLines: 4,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'cover_image_url',
        label: 'Cover image URL',
        value: (draft) => values(draft).coverImageUrl,
        setValue: (draft, value) => values(draft).coverImageUrl = value,
      ),
    ].where((field) => include == null || include.contains(field.id)).toList();

LibraryFieldSpec<TDraft> _vocabularyOrText<TDraft>({
  required String id,
  required String label,
  required String Function(TDraft draft) value,
  required void Function(TDraft draft, String value) setValue,
  required Iterable<String> options,
  FutureOr<void> Function()? onManage,
}) {
  final choices = [
    for (final option in options)
      LibraryFieldOption<String>(value: option, label: option),
  ];
  if (choices.isEmpty) {
    return LibraryTextFieldSpec<TDraft>(
      id: id,
      label: label,
      value: value,
      setValue: setValue,
    );
  }
  return LibraryVocabularyFieldSpec<TDraft, String>(
    id: id,
    label: label,
    value: (draft) {
      final current = value(draft).trim();
      return current.isEmpty ? null : current;
    },
    setValue: (draft, next) => setValue(draft, next ?? ''),
    options: choices,
    onManage: onManage == null ? null : (_) => onManage(),
  );
}
