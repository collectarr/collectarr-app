import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_release.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/release/game_release_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/vocabulary/game_vocabularies.dart';
import 'package:flutter/material.dart';

final EditSchema<GameRelease, GameReleaseEditDraft> gameReleaseEditSchema =
    EditSchema(
  title: (release) => 'Edit ${release.title}',
  validate: (_, draft) {
    if (draft.releaseDateController.text.trim().isNotEmpty &&
        DateTime.tryParse(draft.releaseDateController.text.trim()) == null) {
      return 'Release date is invalid';
    }
    return null;
  },
  tabs: [
    EditTabSpec(
      id: 'release',
      label: 'Release',
      icon: Icons.album_outlined,
      sections: [
        EditSectionSpec(
          id: 'identity',
          label: 'Identity',
          fields: [
            _textField(
              id: 'title',
              label: 'Title',
              value: (draft) => draft.titleController.text,
              setValue: (draft, value) => draft.titleController.text = value,
            ),
            VocabularyEditField<GameReleaseEditDraft, String>(
              id: 'platform',
              label: 'Platform',
              value: (draft) => _nullableText(
                draft.platformController.text,
              ),
              setValue: (draft, value) =>
                  draft.platformController.text = value ?? '',
              options: _options(GameVocabularies.platform.builtIns),
            ),
            VocabularyEditField<GameReleaseEditDraft, String>(
              id: 'region',
              label: 'Region',
              value: (draft) => _nullableText(draft.regionController.text),
              setValue: (draft, value) =>
                  draft.regionController.text = value ?? '',
              options: _options(GameVocabularies.region.builtIns),
            ),
            _textField(
              id: 'format',
              label: 'Format',
              value: (draft) => draft.formatController.text,
              setValue: (draft, value) => draft.formatController.text = value,
            ),
            DateEditField<GameReleaseEditDraft>(
              id: 'release_date',
              label: 'Release date',
              value: (draft) => DateTime.tryParse(
                draft.releaseDateController.text.trim(),
              ),
              setValue: (draft, value) => draft.releaseDateController.text =
                  value == null ? '' : _formatDate(value),
              validator: (draft) => _validDate(
                draft.releaseDateController.text,
                'Release date',
              ),
            ),
          ],
        ),
        EditSectionSpec(
          id: 'publishing',
          label: 'Publishing',
          fields: [
            _textField(
              id: 'publisher',
              label: 'Publisher',
              value: (draft) => draft.publisherController.text,
              setValue: (draft, value) =>
                  draft.publisherController.text = value,
            ),
            _textField(
              id: 'catalog_number',
              label: 'Catalog number',
              value: (draft) => draft.catalogNumberController.text,
              setValue: (draft, value) =>
                  draft.catalogNumberController.text = value,
            ),
            _textField(
              id: 'barcode',
              label: 'Barcode',
              value: (draft) => draft.barcodeController.text,
              setValue: (draft, value) => draft.barcodeController.text = value,
            ),
            _textField(
              id: 'release_status',
              label: 'Release status',
              value: (draft) => draft.releaseStatusController.text,
              setValue: (draft, value) =>
                  draft.releaseStatusController.text = value,
            ),
            _textField(
              id: 'language',
              label: 'Language',
              value: (draft) => draft.languageController.text,
              setValue: (draft, value) => draft.languageController.text = value,
            ),
            _textField(
              id: 'cover_image_url',
              label: 'Cover image URL',
              value: (draft) => draft.coverImageUrlController.text,
              setValue: (draft, value) =>
                  draft.coverImageUrlController.text = value,
            ),
          ],
        ),
      ],
    ),
  ],
);

TextEditField<GameReleaseEditDraft> _textField({
  required String id,
  required String label,
  required String Function(GameReleaseEditDraft draft) value,
  required void Function(GameReleaseEditDraft draft, String value) setValue,
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

String? _validDate(String value, String label) {
  return value.trim().isNotEmpty && DateTime.tryParse(value.trim()) == null
      ? '$label is invalid'
      : null;
}

String _formatDate(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';
