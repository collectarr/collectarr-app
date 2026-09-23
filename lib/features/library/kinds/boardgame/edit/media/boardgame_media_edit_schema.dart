import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_media.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit/media/boardgame_media_edit_draft.dart';
import 'package:flutter/material.dart';

final EditSchema<BoardGameMedia, BoardGameMediaEditDraft>
    boardGameMediaEditSchema = EditSchema(
  title: (_) => 'Edit board game media',
  validate: (_, draft) {
    if (draft.title.trim().isEmpty) return 'Board game title is required';
    if (draft.releaseDateController.text.trim().isNotEmpty &&
        draft.releaseDate == null) {
      return 'Release date is invalid';
    }
    return null;
  },
  tabs: [
    EditTabSpec<BoardGameMediaEditDraft>(
      id: 'identity',
      label: 'Identity',
      icon: Icons.title,
      sections: [
        EditSectionSpec<BoardGameMediaEditDraft>(
          id: 'titles',
          label: 'Titles',
          fields: [
            _text('title', 'Title', (draft) => draft.title,
                (draft, value) => draft.title = value),
            _text('sort_title', 'Sort title', (draft) => draft.sortTitle,
                (draft, value) => draft.sortTitle = value),
            _text('subtitle', 'Subtitle', (draft) => draft.subtitle,
                (draft, value) => draft.subtitle = value),
            _text('description', 'Description', (draft) => draft.description,
                (draft, value) => draft.description = value,
                maxLines: 4),
          ],
        ),
      ],
    ),
    EditTabSpec<BoardGameMediaEditDraft>(
      id: 'classification',
      label: 'Classification',
      icon: Icons.category_outlined,
      sections: [
        EditSectionSpec<BoardGameMediaEditDraft>(
          id: 'details',
          label: 'Board game details',
          fields: [
            _text('publisher', 'Publisher', (draft) => draft.publisher ?? '',
                (draft, value) => draft.publisher = value),
            _text(
                'platforms',
                'Platforms',
                (draft) => draft.platforms.join(', '),
                (draft, value) => draft.platforms = _split(value)),
            _text(
              'identifiers',
              'Identifiers',
              (draft) => draft.identifiers.join(', '),
              (draft, value) => draft.identifiers = _split(value),
            ),
            _text(
              'contributors',
              'Contributors',
              (draft) => draft.contributors.join(', '),
              (draft, value) => draft.contributors = _split(value),
            ),
            _text(
                'mechanics',
                'Mechanics',
                (draft) => draft.mechanics.join(', '),
                (draft, value) => draft.mechanics = _split(value)),
            _text(
                'categories',
                'Categories',
                (draft) => draft.categories.join(', '),
                (draft, value) => draft.categories = _split(value)),
            _text('families', 'Families', (draft) => draft.families.join(', '),
                (draft, value) => draft.families = _split(value)),
            _text(
                'expansions',
                'Expansions',
                (draft) => draft.expansions.join(', '),
                (draft, value) => draft.expansions = _split(value)),
            _text('rankings', 'Rankings', (draft) => draft.rankings.join(', '),
                (draft, value) => draft.rankings = _split(value)),
            _text(
              'original_language',
              'Original language',
              (draft) => draft.originalLanguage ?? '',
              (draft, value) => draft.originalLanguage = value,
            ),
            _date(
              'release_date',
              'Release date',
              (draft) => draft.releaseDate,
              (draft, value) => draft.releaseDate = value,
              (draft) => draft.releaseDateController.text.trim().isNotEmpty &&
                      draft.releaseDate == null
                  ? 'Release date is invalid'
                  : null,
            ),
            _text(
              'search_aliases',
              'Search aliases',
              (draft) => draft.searchAliases.join(', '),
              (draft, value) => draft.searchAliases = _split(value),
            ),
          ],
        ),
      ],
    ),
  ],
);

LibraryTextFieldSpec<BoardGameMediaEditDraft> _text(
  String id,
  String label,
  String Function(BoardGameMediaEditDraft) value,
  void Function(BoardGameMediaEditDraft, String) setValue, {
  int maxLines = 1,
}) =>
    LibraryTextFieldSpec(
      id: id,
      label: label,
      value: value,
      setValue: setValue,
      maxLines: maxLines,
    );

LibraryDateFieldSpec<BoardGameMediaEditDraft> _date(
  String id,
  String label,
  DateTime? Function(BoardGameMediaEditDraft) value,
  void Function(BoardGameMediaEditDraft, DateTime?) setValue,
  String? Function(BoardGameMediaEditDraft) validator,
) =>
    LibraryDateFieldSpec(
      id: id,
      label: label,
      value: value,
      setValue: setValue,
      validator: validator,
    );

List<String> _split(String value) => value
    .split(RegExp(r'[,\r\n]+'))
    .map((entry) => entry.trim())
    .where((entry) => entry.isNotEmpty)
    .toSet()
    .toList(growable: false);
