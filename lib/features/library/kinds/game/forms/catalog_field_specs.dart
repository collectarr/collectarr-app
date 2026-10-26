import 'package:collectarr_app/core/utils/title_case.dart';
import 'package:collectarr_app/features/library/forms/library_field_spec.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/game/vocabulary/game_vocabularies.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_definition.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_ordered_names_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_ordered_pick_list_field.dart';
import 'package:flutter/material.dart';

typedef GameFormValuesReader<TDraft> = GameCatalogFormValues Function(
    TDraft draft);

/// Field ids of the reference Main tab, shared by Game Add and Edit.
abstract final class GameMainFieldIds {
  static const title = 'title';
  static const sortTitle = 'sort_title';
  static const platform = 'platform';
  static const releaseDate = 'release_date';
  static const developer = 'developer';
  static const publisher = 'publisher';
  static const series = 'series';
  static const barcode = 'barcode';
  static const format = 'format';
  static const edition = 'edition';
  static const region = 'region';
  static const audienceRating = 'audience_rating';
  static const genre = 'genre';
}

const gameTitleActions = [
  LibraryTextFieldAction(
    label: 'Autocap',
    iconText: 'Aa',
    transform: applyTitleCase,
    appliesAsYouType: true,
  ),
];

List<LibraryFieldSpec<TDraft>> gameMainFields<TDraft>({
  required GameFormValuesReader<TDraft> values,
}) =>
    [
      LibraryTextFieldSpec<TDraft>(
        id: GameMainFieldIds.title,
        label: 'Title',
        value: (draft) => values(draft).title,
        setValue: (draft, value) => values(draft).title = value,
        actions: gameTitleActions,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: GameMainFieldIds.sortTitle,
        label: 'Sort Title',
        value: (draft) => values(draft).sortTitle,
        setValue: (draft, value) => values(draft).sortTitle = value,
      ),
      _vocabulary<TDraft>(
        id: GameMainFieldIds.platform,
        definition: GameVocabularies.platform,
        read: (draft) => values(draft).platform,
        write: (draft, value) => values(draft).platform = value,
      ),
      LibraryPartialDateFieldSpec<TDraft>(
        id: GameMainFieldIds.releaseDate,
        label: 'Release Date',
        value: (draft) => values(draft).releaseDateParts,
        setValue: (draft, value) => values(draft).releaseDateParts = value,
      ),
      _names<TDraft>(
        id: GameMainFieldIds.developer,
        definition: GameVocabularies.developer,
        read: (draft) => values(draft).developers,
        write: (draft, names) => values(draft).developers = names,
      ),
      _names<TDraft>(
        id: GameMainFieldIds.publisher,
        definition: GameVocabularies.publisher,
        read: (draft) => values(draft).publishers,
        write: (draft, names) => values(draft).publishers = names,
      ),
      _vocabulary<TDraft>(
        id: GameMainFieldIds.series,
        definition: GameVocabularies.series,
        read: (draft) => values(draft).series,
        write: (draft, value) => values(draft).series = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: GameMainFieldIds.barcode,
        label: 'Barcode',
        value: (draft) => values(draft).barcode,
        setValue: (draft, value) => values(draft).barcode = value,
      ),
      _vocabulary<TDraft>(
        id: GameMainFieldIds.format,
        definition: GameVocabularies.format,
        read: (draft) => values(draft).format,
        write: (draft, value) => values(draft).format = value,
      ),
      LibraryTextFieldSpec<TDraft>(
        id: GameMainFieldIds.edition,
        label: 'Edition',
        value: (draft) => values(draft).editionTitle,
        setValue: (draft, value) => values(draft).editionTitle = value,
      ),
      _vocabulary<TDraft>(
        id: GameMainFieldIds.region,
        definition: GameVocabularies.region,
        read: (draft) => values(draft).region,
        write: (draft, value) => values(draft).region = value,
      ),
      _vocabulary<TDraft>(
        id: GameMainFieldIds.audienceRating,
        definition: GameVocabularies.audienceRating,
        read: (draft) => values(draft).audienceRating,
        write: (draft, value) => values(draft).audienceRating = value,
      ),
      LibraryMultiVocabularyFieldSpec<TDraft, String>(
        id: GameMainFieldIds.genre,
        label: 'Genre',
        pickListKey: GameVocabularyIds.genre.value,
        pluralLabel: 'Genres',
        values: (draft) => values(draft).genres.toSet(),
        setValues: (draft, next) =>
            values(draft).genres = next.toList(growable: false),
        options: _options(GameVocabularies.genre.builtIns),
      ),
    ];

LibraryVocabularyFieldSpec<TDraft, String> _vocabulary<TDraft>({
  required String id,
  required VocabularyDefinition<String> definition,
  required String Function(TDraft draft) read,
  required void Function(TDraft draft, String value) write,
}) =>
    LibraryVocabularyFieldSpec<TDraft, String>(
      id: id,
      label: definition.label ?? '',
      value: (draft) {
        final value = read(draft).trim();
        return value.isEmpty ? null : value;
      },
      setValue: (draft, value) => write(draft, value ?? ''),
      options: _options(definition.builtIns),
      pickListKey: definition.key,
    );

/// Repeated pick list with + and × per row, as the reference Developer and
/// Publisher fields.
LibraryCustomFieldSpec<TDraft> _names<TDraft>({
  required String id,
  required VocabularyDefinition<String> definition,
  required List<String> Function(TDraft draft) read,
  required void Function(TDraft draft, List<String> names) write,
}) =>
    LibraryCustomFieldSpec<TDraft>(
      id: id,
      label: definition.label ?? '',
      builder: (context, draft) => StatefulBuilder(builder: (context, refresh) {
        final names = read(draft);
        return LibraryOrderedPickListField(
          label: definition.label ?? '',
          listName: definition.key,
          mediaKind: 'game',
          loadOptions: (db) =>
              GameVocabularies.entryOptions(db, definition.key.split('.').last),
          values: [
            for (final (index, name) in names.indexed)
              LibraryNamedValue(id: '$id-$index', name: name),
          ],
          onChanged: (selected) => refresh(() => write(draft, [
                for (final value in selected)
                  if (value.name.trim().isNotEmpty) value.name.trim(),
              ])),
        );
      }),
    );

List<LibraryFieldOption<String>> _options(Iterable<String> values) => [
      for (final value in values)
        LibraryFieldOption(value: value, label: value),
    ];
