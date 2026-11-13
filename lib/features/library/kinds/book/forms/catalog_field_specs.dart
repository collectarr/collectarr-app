import 'dart:async';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/ui/primitives/segmented_choice_field.dart';
import 'audio_length_field.dart';

import 'package:collectarr_app/features/library/kinds/book/forms/catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/book/vocabulary/book_vocabularies.dart';
import 'package:collectarr_app/features/library/forms/field_spec.dart';
import 'package:collectarr_app/features/library/kinds/book/config/field_identities.dart';

typedef BookFormValuesReader<TDraft> = BookCatalogFormValues Function(
  TDraft draft,
);

List<LibraryFieldSpec<TDraft>> bookCatalogIdentityFields<TDraft>({
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
        label: 'Sort Title',
        value: (draft) => values(draft).sortTitle,
        setValue: (draft, value) => values(draft).sortTitle = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: BookFieldIdentities.subtitleId,
        label: BookFieldIdentities.subtitleLabel,
        value: (draft) => values(draft).subtitle,
        setValue: (draft, value) => values(draft).subtitle = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'description',
        label: descriptionLabel,
        formatted: true,
        value: (draft) => values(draft).description,
        setValue: (draft, value) => values(draft).description = value,
        maxLines: 18,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'original_title',
        label: 'Title',
        value: (draft) => values(draft).originalTitle,
        setValue: (draft, value) => values(draft).originalTitle = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'localized_title',
        label: 'Localized Title',
        value: (draft) => values(draft).localizedTitle,
        setValue: (draft, value) => values(draft).localizedTitle = value,
      ),
    ].where((field) => include == null || include.contains(field.id)).toList();

List<LibraryFieldSpec<TDraft>> bookPublicationHistoryFields<TDraft>({
  required BookFormValuesReader<TDraft> values,
  Set<String>? include,
}) =>
    [
      _vocabulary<TDraft>(
        id: 'original_language',
        label: 'Language',
        value: (draft) => values(draft).originalLanguage,
        setValue: (draft, value) => values(draft).originalLanguage = value,
        options: BookVocabularies.language.builtIns,
        pickListKey: BookVocabularyIds.language.value,
      ),
      LibraryDateFieldSpec<TDraft>(
        id: 'first_publication_date',
        label: 'First publication date',
        value: (draft) => values(draft).firstPublicationDate,
        setValue: (draft, value) => values(draft).firstPublicationDate = value,
      ),
      LibraryDateFieldSpec<TDraft>(
        id: 'original_publication_date',
        label: 'Publication Date',
        value: (draft) => values(draft).originalPublicationDate,
        setValue: (draft, value) =>
            values(draft).originalPublicationDate = value,
      ),
      LibraryMultiVocabularyFieldSpec<TDraft, String>(
        id: 'genres',
        label: 'Genre',
        pluralLabel: 'Genres',
        values: (draft) => values(draft).genres.toSet(),
        setValues: (draft, next) => values(draft).genres = next.toList(),
        options: const [],
        pickListKey: BookVocabularyIds.genre.value,
      ),
      LibraryMultiVocabularyFieldSpec<TDraft, String>(
        id: 'subjects',
        label: 'Subject',
        pluralLabel: 'Subjects',
        values: (draft) => values(draft).subjects.toSet(),
        setValues: (draft, next) => values(draft).subjects = next.toList(),
        options: const [],
        pickListKey: BookVocabularyIds.subject.value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: 'search_aliases',
        label: 'Search Aliases',
        value: (draft) => values(draft).searchAliases.join(', '),
        setValue: (draft, value) => values(draft).searchAliases = _split(value),
      ),
    ].where((field) => include == null || include.contains(field.id)).toList();

List<LibraryFieldSpec<TDraft>> bookCatalogEditionFields<TDraft>({
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
        pickListKey: BookVocabularyIds.binding.value,
        onManage: onManageBinding,
      ),
      _vocabulary<TDraft>(
        id: BookFieldIdentities.formatId,
        label: BookFieldIdentities.formatLabel,
        value: (draft) => values(draft).format,
        setValue: (draft, value) => values(draft).format = value,
        options: formatOptions ?? BookVocabularies.format.builtIns,
        pickListKey: BookVocabularyIds.format.value,
        onManage: onManageFormat,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: BookFieldIdentities.isbnId,
        label: BookFieldIdentities.isbnLabel,
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
        id: BookFieldIdentities.publisherId,
        label: BookFieldIdentities.publisherLabel,
        value: (draft) => values(draft).publisher,
        setValue: (draft, value) => values(draft).publisher = value,
        options: publisherOptions ?? BookVocabularies.publisher.builtIns,
        pickListKey: BookVocabularyIds.publisher.value,
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
        id: BookFieldIdentities.releaseDateId,
        label: BookFieldIdentities.releaseDateLabel,
        value: (draft) => values(draft).releaseDate,
        setValue: (draft, value) => values(draft).releaseDate = value,
      ),
      LibraryNumberFieldSpec<TDraft>(
        id: BookFieldIdentities.pageCountId,
        label: BookFieldIdentities.pageCountLabel,
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
        pickListKey: BookVocabularyIds.language.value,
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
      _vocabulary<TDraft>(
        id: 'edition_statement',
        label: 'Edition',
        value: (draft) => values(draft).editionStatement,
        setValue: (draft, value) => values(draft).editionStatement = value,
        options: const [],
        pickListKey: BookVocabularyIds.edition.value,
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
      _vocabulary<TDraft>(
        id: BookFieldIdentities.seriesId,
        label: BookFieldIdentities.seriesLabel,
        value: (draft) => values(draft).seriesTitle,
        setValue: (draft, value) => values(draft).seriesTitle = value,
        options: const [],
        pickListKey: BookVocabularyIds.series.value,
      ),
      LibraryCustomFieldSpec<TDraft>(
          id: 'first_edition',
          label: 'First Edition',
          builder: (context, draft) => StatefulBuilder(
              builder: (context, setState) => LibrarySegmentedChoiceField<bool>(
                  label: 'First Edition',
                  options: const [(false, 'No'), (true, 'Yes')],
                  value: values(draft).firstEdition,
                  onChanged: (value) =>
                      setState(() => values(draft).firstEdition = value)))),
      LibraryCustomFieldSpec<TDraft>(
          id: 'audio_length_minutes',
          label: 'Audiobook Length',
          builder: (context, draft) => BookAudioLengthField(
              minutes: values(draft).audioLengthMinutes,
              onChanged: (value) => values(draft).audioLengthMinutes = value)),
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
  String? pickListKey,
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
      pickListKey: pickListKey,
      onManage: onManage == null ? null : (_) => onManage(),
    );

List<String> _split(String value) => value
    .split(RegExp(r'[,\r\n]+'))
    .map((entry) => entry.trim())
    .where((entry) => entry.isNotEmpty)
    .toSet()
    .toList(growable: false);
