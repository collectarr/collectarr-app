import 'package:collectarr_app/features/library/forms/library_form_schema.dart';
import 'package:collectarr_app/core/utils/title_case.dart';
import 'game_toy_catalog_form_values.dart';
import '../vocabulary/game_toy_vocabularies.dart';

typedef GameToyValuesReader<T> = GameToyCatalogFormValues Function(T);
List<LibraryFieldSpec<T>> gameToyMainFields<T>(
        {required GameToyValuesReader<T> values}) =>
    [
      LibraryTextFieldSpec<T>(
          id: 'title',
          label: 'Title',
          value: (draft) => values(draft).title,
          setValue: (draft, value) => values(draft).title = value,
          actions: const [
            LibraryTextFieldAction(
                label: 'Autocap',
                iconText: 'Aa',
                transform: applyTitleCase,
                appliesAsYouType: true)
          ]),
      LibraryTextFieldSpec<T>(
          id: 'sort_title',
          label: 'Sort Title',
          value: (draft) => values(draft).sortTitle,
          setValue: (draft, value) => values(draft).sortTitle = value),
      LibraryTextFieldSpec<T>(
          id: 'barcode',
          label: 'Barcode',
          value: (draft) => values(draft).barcode,
          setValue: (draft, value) => values(draft).barcode = value),
      LibraryVocabularyFieldSpec<T, String>(
          id: 'series',
          label: 'Series',
          pickListKey: 'game_toy.series',
          options: [
            for (final name in GameToyVocabularies.series.builtIns)
              LibraryFieldOption(value: name, label: name)
          ],
          value: (draft) =>
              values(draft).series.isEmpty ? null : values(draft).series,
          setValue: (draft, value) => values(draft).series = value ?? ''),
      LibraryVocabularyFieldSpec<T, String>(
          id: 'toy_type',
          label: 'Type',
          pickListKey: 'game_toy.toy_type',
          options: [
            for (final name in GameToyVocabularies.toyType.builtIns)
              LibraryFieldOption(value: name, label: name)
          ],
          value: (draft) =>
              values(draft).toyType.isEmpty ? null : values(draft).toyType,
          setValue: (draft, value) => values(draft).toyType = value ?? ''),
      LibraryVocabularyFieldSpec<T, String>(
          id: 'toy_subtype',
          label: 'Subtype',
          pickListKey: 'game_toy.toy_subtype',
          options: [
            for (final name in GameToyVocabularies.toySubtype.builtIns)
              LibraryFieldOption(value: name, label: name)
          ],
          value: (draft) => values(draft).toySubtype.isEmpty
              ? null
              : values(draft).toySubtype,
          setValue: (draft, value) => values(draft).toySubtype = value ?? ''),
      LibraryPartialDateFieldSpec<T>(
          id: 'release_date',
          label: 'Release Date',
          value: (draft) => values(draft).releaseDateParts,
          setValue: (draft, value) => values(draft).releaseDateParts = value),
    ];
LibraryFormSectionSpec<T> gameToyMainSection<T>(
        {required List<LibraryFieldSpec<T>> fields,
        String titleFieldId = 'title'}) =>
    LibraryFormSectionSpec(
        id: 'catalog_item',
        label: '',
        columns: [
          LibraryFormColumnSpec(rows: [
            [titleFieldId],
            ['sort_title'],
            ['barcode', 'release_date']
          ]),
          const LibraryFormColumnSpec(rows: [
            ['series'],
            ['toy_type', 'toy_subtype']
          ]),
        ],
        fields: fields);
