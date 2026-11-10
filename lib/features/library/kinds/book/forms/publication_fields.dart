import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/forms/field_spec.dart';
import 'package:collectarr_app/features/library/ui/primitives/segmented_choice_field.dart';
import 'catalog_form_values.dart';

List<LibraryFieldSpec<TDraft>> bookPublicationFields<TDraft>(
        {required BookCatalogFormValues Function(TDraft) values}) =>
    [
      LibraryVocabularyFieldSpec<TDraft, String>(
          id: 'box_set',
          label: 'Box Set',
          value: (draft) =>
              values(draft).boxSet.isEmpty ? null : values(draft).boxSet,
          setValue: (draft, value) => values(draft).boxSet = value ?? '',
          options: const [],
          pickListKey: 'book.box_set'),
      LibraryVocabularyFieldSpec<TDraft, String>(
          id: 'publication_place',
          label: 'Publication Place',
          value: (draft) => values(draft).publicationPlace.isEmpty
              ? null
              : values(draft).publicationPlace,
          setValue: (draft, value) =>
              values(draft).publicationPlace = value ?? '',
          options: const [],
          pickListKey: 'book.publication_place'),
      LibraryVocabularyFieldSpec<TDraft, String>(
          id: 'printed_by',
          label: 'Printed By',
          value: (draft) =>
              values(draft).printedBy.isEmpty ? null : values(draft).printedBy,
          setValue: (draft, value) => values(draft).printedBy = value ?? '',
          options: const [],
          pickListKey: 'book.printed_by'),
      LibraryVocabularyFieldSpec<TDraft, String>(
          id: 'paper_type',
          label: 'Paper Type',
          value: (draft) =>
              values(draft).paperType.isEmpty ? null : values(draft).paperType,
          setValue: (draft, value) => values(draft).paperType = value ?? '',
          options: const [],
          pickListKey: 'book.paper_type'),
      LibraryTextFieldSpec<TDraft>(
          id: 'number_line',
          label: 'Number Line',
          value: (draft) => values(draft).numberLine,
          setValue: (draft, value) => values(draft).numberLine = value),
      LibraryTextFieldSpec<TDraft>(
          id: 'original_subtitle',
          label: 'Subtitle',
          value: (draft) => values(draft).originalSubtitle,
          setValue: (draft, value) => values(draft).originalSubtitle = value),
      LibraryVocabularyFieldSpec<TDraft, String>(
          id: 'original_country',
          label: 'Country',
          value: (draft) => values(draft).originalCountry.isEmpty
              ? null
              : values(draft).originalCountry,
          setValue: (draft, value) =>
              values(draft).originalCountry = value ?? '',
          options: const [],
          pickListKey: 'book.country'),
      LibraryVocabularyFieldSpec<TDraft, String>(
          id: 'original_publisher',
          label: 'Publisher',
          value: (draft) => values(draft).originalPublisher.isEmpty
              ? null
              : values(draft).originalPublisher,
          setValue: (draft, value) =>
              values(draft).originalPublisher = value ?? '',
          options: const [],
          pickListKey: 'book.publisher'),
      LibraryVocabularyFieldSpec<TDraft, String>(
          id: 'original_publication_place',
          label: 'Publication Place',
          value: (draft) => values(draft).originalPublicationPlace.isEmpty
              ? null
              : values(draft).originalPublicationPlace,
          setValue: (draft, value) =>
              values(draft).originalPublicationPlace = value ?? '',
          options: const [],
          pickListKey: 'book.publication_place'),
      LibraryNumberFieldSpec<TDraft>(
          id: 'printing_number',
          label: 'Printing',
          minimum: 0,
          value: (draft) => values(draft).printingNumber?.toDouble(),
          setValue: (draft, value) =>
              values(draft).printingNumber = value?.toInt()),
      LibraryNumberFieldSpec<TDraft>(
          id: 'width_mm',
          label: 'Width (mm)',
          minimum: 0,
          value: (draft) => values(draft).widthMm?.toDouble(),
          setValue: (draft, value) => values(draft).widthMm = value?.toInt()),
      LibraryNumberFieldSpec<TDraft>(
          id: 'height_mm',
          label: 'Height (mm)',
          minimum: 0,
          value: (draft) => values(draft).heightMm?.toDouble(),
          setValue: (draft, value) => values(draft).heightMm = value?.toInt()),
      LibraryNumberFieldSpec<TDraft>(
          id: 'spine_thickness_mm',
          label: 'Spine Thickness (mm)',
          minimum: 0,
          value: (draft) => values(draft).spineThicknessMm?.toDouble(),
          setValue: (draft, value) =>
              values(draft).spineThicknessMm = value?.toInt()),
      LibraryNumberFieldSpec<TDraft>(
          id: 'weight_grams',
          label: 'Weight (g)',
          minimum: 0,
          value: (draft) => values(draft).weightGrams?.toDouble(),
          setValue: (draft, value) =>
              values(draft).weightGrams = value?.toInt()),
      LibraryMultiVocabularyFieldSpec<TDraft, String>(
          id: 'extras',
          label: 'Extras',
          values: (draft) => values(draft).extras.toSet(),
          setValues: (draft, next) => values(draft).extras = next.toList(),
          options: const [],
          pickListKey: 'book.extras'),
      LibraryCustomFieldSpec<TDraft>(
          id: 'audio_abridged',
          label: 'Audiobook Abridged',
          builder: (context, draft) => StatefulBuilder(
              builder: (context, setState) => LibrarySegmentedChoiceField<bool>(
                  label: 'Audiobook Abridged',
                  options: const [(false, 'No'), (true, 'Yes')],
                  value: values(draft).audioAbridged,
                  onChanged: (value) =>
                      setState(() => values(draft).audioAbridged = value)))),
    ];
