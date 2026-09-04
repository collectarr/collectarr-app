import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_release.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit/release/boardgame_edition_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/vocabulary/boardgame_vocabularies.dart';
import 'package:flutter/material.dart';

final EditSchema<BoardGameRelease, BoardGameEditionEditDraft>
    boardGameEditionEditSchema = EditSchema(
  title: (release) => 'Edit ${release.title}',
  validate: (_, draft) {
    final integerFields = <String, TextEditingController>{
      'Minimum players': draft.minPlayersController,
      'Maximum players': draft.maxPlayersController,
      'Minimum age': draft.minAgeController,
      'Playing time': draft.playingTimeController,
    };
    for (final entry in integerFields.entries) {
      final value = entry.value.text.trim();
      if (value.isNotEmpty && int.tryParse(value) == null) {
        return '${entry.key} must be a whole number';
      }
    }
    if (draft.releaseDateController.text.trim().isNotEmpty &&
        DateTime.tryParse(draft.releaseDateController.text.trim()) == null) {
      return 'Release date is invalid';
    }
    return null;
  },
  tabs: [
    EditTabSpec(
      id: 'identity',
      label: 'Identity',
      icon: Icons.album_outlined,
      sections: [
        EditSectionSpec(
          id: 'titles',
          label: 'Titles and identifiers',
          fields: [
            _textField(
              id: 'title',
              label: 'Title',
              value: (draft) => draft.titleController.text,
              setValue: (draft, value) => draft.titleController.text = value,
            ),
            _textField(
              id: 'edition_title',
              label: 'Edition title',
              value: (draft) => draft.editionTitleController.text,
              setValue: (draft, value) =>
                  draft.editionTitleController.text = value,
            ),
            _textField(
              id: 'barcode',
              label: 'Barcode',
              value: (draft) => draft.barcodeController.text,
              setValue: (draft, value) => draft.barcodeController.text = value,
            ),
            _textField(
              id: 'catalog_number',
              label: 'Catalog number',
              value: (draft) => draft.catalogNumberController.text,
              setValue: (draft, value) =>
                  draft.catalogNumberController.text = value,
            ),
            VocabularyEditField<BoardGameEditionEditDraft, String>(
              id: 'format',
              label: 'Format',
              value: (draft) => _nullableText(draft.formatController.text),
              setValue: (draft, value) =>
                  draft.formatController.text = value ?? '',
              options: _options(BoardGameVocabularies.format.builtIns),
            ),
          ],
        ),
      ],
    ),
    EditTabSpec(
      id: 'publication',
      label: 'Publication',
      icon: Icons.public,
      sections: [
        EditSectionSpec(
          id: 'publication_details',
          label: 'Publication details',
          fields: [
            VocabularyEditField<BoardGameEditionEditDraft, String>(
              id: 'publisher',
              label: 'Publisher',
              value: (draft) => _nullableText(draft.publisherController.text),
              setValue: (draft, value) =>
                  draft.publisherController.text = value ?? '',
              options: _options(BoardGameVocabularies.publisher.builtIns),
            ),
            _textField(
              id: 'country',
              label: 'Country / region',
              value: (draft) => draft.countryController.text,
              setValue: (draft, value) => draft.countryController.text = value,
            ),
            _textField(
              id: 'language',
              label: 'Language',
              value: (draft) => draft.languageController.text,
              setValue: (draft, value) => draft.languageController.text = value,
            ),
            DateEditField<BoardGameEditionEditDraft>(
              id: 'release_date',
              label: 'Release date',
              value: (draft) =>
                  DateTime.tryParse(draft.releaseDateController.text.trim()),
              setValue: (draft, value) => draft.releaseDateController.text =
                  value == null ? '' : _formatDate(value),
              validator: (draft) => _dateValidator(
                draft.releaseDateController.text,
                'Release date',
              ),
            ),
            _textField(
              id: 'release_status',
              label: 'Release status',
              value: (draft) => draft.releaseStatusController.text,
              setValue: (draft, value) =>
                  draft.releaseStatusController.text = value,
            ),
          ],
        ),
      ],
    ),
    EditTabSpec(
      id: 'details',
      label: 'Details',
      icon: Icons.info_outline,
      sections: [
        EditSectionSpec(
          id: 'ratings_and_media',
          label: 'Ratings and media',
          fields: [
            _textField(
              id: 'age_rating',
              label: 'Age rating',
              value: (draft) => draft.ageRatingController.text,
              setValue: (draft, value) =>
                  draft.ageRatingController.text = value,
            ),
            _textField(
              id: 'audience_rating',
              label: 'Audience rating',
              value: (draft) => draft.audienceRatingController.text,
              setValue: (draft, value) =>
                  draft.audienceRatingController.text = value,
            ),
            _textField(
              id: 'cover_image_url',
              label: 'Cover image URL',
              value: (draft) => draft.coverImageUrlController.text,
              setValue: (draft, value) =>
                  draft.coverImageUrlController.text = value,
            ),
            _textField(
              id: 'description',
              label: 'Description',
              value: (draft) => draft.descriptionController.text,
              setValue: (draft, value) =>
                  draft.descriptionController.text = value,
            ),
          ],
        ),
      ],
    ),
    EditTabSpec(
      id: 'play_profile',
      label: 'Play profile',
      icon: Icons.groups_outlined,
      sections: [
        EditSectionSpec(
          id: 'players',
          label: 'Players and time',
          fields: [
            _textField(
              id: 'min_players',
              label: 'Minimum players',
              value: (draft) => draft.minPlayersController.text,
              setValue: (draft, value) =>
                  draft.minPlayersController.text = value,
            ),
            _textField(
              id: 'max_players',
              label: 'Maximum players',
              value: (draft) => draft.maxPlayersController.text,
              setValue: (draft, value) =>
                  draft.maxPlayersController.text = value,
            ),
            _textField(
              id: 'min_age',
              label: 'Minimum age',
              value: (draft) => draft.minAgeController.text,
              setValue: (draft, value) => draft.minAgeController.text = value,
            ),
            _textField(
              id: 'playing_time_minutes',
              label: 'Playing time (minutes)',
              value: (draft) => draft.playingTimeController.text,
              setValue: (draft, value) =>
                  draft.playingTimeController.text = value,
            ),
          ],
        ),
      ],
    ),
  ],
);

TextEditField<BoardGameEditionEditDraft> _textField({
  required String id,
  required String label,
  required String Function(BoardGameEditionEditDraft draft) value,
  required void Function(BoardGameEditionEditDraft draft, String value)
      setValue,
}) {
  return TextEditField(
    id: id,
    label: label,
    value: value,
    setValue: setValue,
  );
}

List<EditOption<String>> _options(Iterable<String> values) => [
      for (final value in values) EditOption(value: value, label: value),
    ];

String? _nullableText(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

String? _dateValidator(String value, String label) {
  return value.trim().isNotEmpty && DateTime.tryParse(value.trim()) == null
      ? '$label is invalid'
      : null;
}

String _formatDate(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';
