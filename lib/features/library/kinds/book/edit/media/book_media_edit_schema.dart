import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_media.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/media/book_media_edit_draft.dart';
import 'package:flutter/material.dart';

final EditSchema<BookMedia, BookMediaEditDraft> bookMediaEditSchema =
    EditSchema(
  title: (_) => 'Edit book media',
  validate: (_, draft) {
    if (draft.title.trim().isEmpty) return 'Book title is required';
    if (_invalidDate(draft.firstPublicationDateController.text) ||
        _invalidDate(draft.originalPublicationDateController.text)) {
      return 'Publication date is invalid';
    }
    return null;
  },
  tabs: [
    EditTabSpec<BookMediaEditDraft>(
      id: 'identity',
      label: 'Identity',
      icon: Icons.title,
      sections: [
        EditSectionSpec<BookMediaEditDraft>(
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
    EditTabSpec<BookMediaEditDraft>(
      id: 'publication',
      label: 'Publication',
      icon: Icons.menu_book,
      sections: [
        EditSectionSpec<BookMediaEditDraft>(
          id: 'details',
          label: 'Publication details',
          fields: [
            _text(
              'original_language',
              'Original language',
              (draft) => draft.originalLanguage,
              (draft, value) => draft.originalLanguage = value,
            ),
            _date(
              'first_publication_date',
              'First publication date',
              (draft) => draft.firstPublicationDate,
              (draft, value) => draft.firstPublicationDate = value,
              (draft) => _dateError(
                draft.firstPublicationDateController.text,
                'First publication date',
              ),
            ),
            _date(
              'original_publication_date',
              'Original publication date',
              (draft) => draft.originalPublicationDate,
              (draft, value) => draft.originalPublicationDate = value,
              (draft) => _dateError(
                draft.originalPublicationDateController.text,
                'Original publication date',
              ),
            ),
            _text('genres', 'Genres', (draft) => draft.genres.join(', '),
                (draft, value) => draft.genres = _split(value)),
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

LibraryTextFieldSpec<BookMediaEditDraft> _text(
  String id,
  String label,
  String Function(BookMediaEditDraft) value,
  void Function(BookMediaEditDraft, String) setValue, {
  int maxLines = 1,
}) =>
    LibraryTextFieldSpec(
      id: id,
      label: label,
      value: value,
      setValue: setValue,
      maxLines: maxLines,
    );

LibraryDateFieldSpec<BookMediaEditDraft> _date(
  String id,
  String label,
  DateTime? Function(BookMediaEditDraft) value,
  void Function(BookMediaEditDraft, DateTime?) setValue,
  String? Function(BookMediaEditDraft) validator,
) =>
    LibraryDateFieldSpec(
      id: id,
      label: label,
      value: value,
      setValue: setValue,
      validator: validator,
    );

bool _invalidDate(String value) =>
    value.trim().isNotEmpty && DateTime.tryParse(value.trim()) == null;

String? _dateError(String value, String label) =>
    _invalidDate(value) ? '$label is invalid' : null;

List<String> _split(String value) => value
    .split(RegExp(r'[,\r\n]+'))
    .map((entry) => entry.trim())
    .where((entry) => entry.isNotEmpty)
    .toSet()
    .toList(growable: false);
