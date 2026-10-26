import 'package:collectarr_app/features/library/forms/library_form_schema.dart';
import 'package:collectarr_app/core/utils/title_case.dart';
import 'package:flutter/material.dart';
import 'catalog_form_values.dart';
import '../vocabulary/game_hardware_vocabularies.dart';

typedef GameHardwareValuesReader<T> = GameHardwareCatalogFormValues Function(T);
List<LibraryFieldSpec<T>> gameHardwareMainFields<T>(
        {required GameHardwareValuesReader<T> values,
        Widget Function(BuildContext, T)? serialNumberBuilder}) =>
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
          pickListKey: 'game_hardware.series',
          options: [
            for (final name in GameHardwareVocabularies.series.builtIns)
              LibraryFieldOption(value: name, label: name)
          ],
          value: (draft) =>
              values(draft).series.isEmpty ? null : values(draft).series,
          setValue: (draft, value) => values(draft).series = value ?? ''),
      LibraryVocabularyFieldSpec<T, String>(
          id: 'platform',
          label: 'Platform',
          pickListKey: 'game_hardware.platform',
          options: [
            for (final name in GameHardwareVocabularies.platform.builtIns)
              LibraryFieldOption(value: name, label: name)
          ],
          value: (draft) =>
              values(draft).platform.isEmpty ? null : values(draft).platform,
          setValue: (draft, value) => values(draft).platform = value ?? ''),
      LibraryTextFieldSpec<T>(
          id: 'hardware_type',
          label: 'Hardware Type',
          value: (draft) => values(draft).hardwareType,
          setValue: (draft, value) => values(draft).hardwareType = value),
      LibraryPartialDateFieldSpec<T>(
          id: 'release_date',
          label: 'Release Date',
          value: (draft) => values(draft).releaseDateParts,
          setValue: (draft, value) => values(draft).releaseDateParts = value),
      LibraryCustomFieldSpec<T>(
          id: 'serial_number',
          label: 'Serial No.',
          builder: serialNumberBuilder ??
              (context, draft) => const SizedBox.shrink()),
    ];
LibraryFormSectionSpec<T> gameHardwareMainSection<T>(
        {required List<LibraryFieldSpec<T>> fields,
        String titleFieldId = 'title'}) =>
    LibraryFormSectionSpec(
        id: 'catalog_item',
        label: '',
        columns: [
          LibraryFormColumnSpec(rows: [
            [titleFieldId],
            ['sort_title'],
            ['platform', 'release_date']
          ]),
          const LibraryFormColumnSpec(rows: [
            ['barcode', 'hardware_type'],
            ['series'],
            ['serial_number']
          ]),
        ],
        fields: fields);
