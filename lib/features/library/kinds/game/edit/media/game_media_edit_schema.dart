import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_media.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/media/game_media_edit_draft.dart';
import 'package:flutter/material.dart';

final EditSchema<GameMedia, GameMediaEditDraft> gameMediaEditSchema =
    EditSchema(
  title: (_) => 'Edit game media',
  validate: (_, draft) {
    if (draft.title.trim().isEmpty) return 'Game title is required';
    if (draft.releaseDateController.text.trim().isNotEmpty &&
        draft.releaseDate == null) {
      return 'Release date is invalid';
    }
    return null;
  },
  tabs: [
    EditTabSpec<GameMediaEditDraft>(
      id: 'identity',
      label: 'Identity',
      icon: Icons.title,
      sections: [
        EditSectionSpec<GameMediaEditDraft>(
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
    EditTabSpec<GameMediaEditDraft>(
      id: 'classification',
      label: 'Classification',
      icon: Icons.category_outlined,
      sections: [
        EditSectionSpec<GameMediaEditDraft>(
          id: 'details',
          label: 'Game details',
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
              'company_roles',
              'Companies and roles',
              (draft) => draft.companyRoles.join(', '),
              (draft, value) => draft.companyRoles = _split(value),
            ),
            _text(
                'age_ratings',
                'Age ratings',
                (draft) => draft.ageRatings.join(', '),
                (draft, value) => draft.ageRatings = _split(value)),
            _text('genres', 'Genres', (draft) => draft.genres.join(', '),
                (draft, value) => draft.genres = _split(value)),
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

LibraryTextFieldSpec<GameMediaEditDraft> _text(
  String id,
  String label,
  String Function(GameMediaEditDraft) value,
  void Function(GameMediaEditDraft, String) setValue, {
  int maxLines = 1,
}) =>
    LibraryTextFieldSpec(
      id: id,
      label: label,
      value: value,
      setValue: setValue,
      maxLines: maxLines,
    );

LibraryDateFieldSpec<GameMediaEditDraft> _date(
  String id,
  String label,
  DateTime? Function(GameMediaEditDraft) value,
  void Function(GameMediaEditDraft, DateTime?) setValue,
  String? Function(GameMediaEditDraft) validator,
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
