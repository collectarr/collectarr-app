import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/game_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/vocabulary/game_vocabularies.dart';

final EditSchema<GameCatalogMetadata, GameEditDraft> gameMediaEditSchema =
    EditSchema(
  title: (_) => 'Edit game media',
  tabs: [
    EditTabSpec(
      id: 'media',
      label: 'Media',
      sections: [
        EditSectionSpec(
          id: 'publishing',
          label: 'Publishing and identity',
          fields: [
            _textField(
              id: 'publisher',
              label: 'Publisher',
              value: (draft) => draft.gameEdit.publisherController.text,
              setValue: (draft, value) =>
                  draft.gameEdit.publisherController.text = value,
            ),
            _textField(
              id: 'developers',
              label: 'Developers',
              value: (draft) => draft.gameEdit.developersController.text,
              setValue: (draft, value) =>
                  draft.gameEdit.developersController.text = value,
            ),
            _textField(
              id: 'series',
              label: 'Series',
              value: (draft) => draft.gameEdit.seriesTitleController.text,
              setValue: (draft, value) =>
                  draft.gameEdit.seriesTitleController.text = value,
            ),
            _textField(
              id: 'franchise',
              label: 'Franchise',
              value: (draft) => draft.gameEdit.franchiseController.text,
              setValue: (draft, value) =>
                  draft.gameEdit.franchiseController.text = value,
            ),
          ],
        ),
        EditSectionSpec(
          id: 'classification',
          label: 'Classification',
          fields: [
            _textField(
              id: 'platforms',
              label: 'Platforms',
              value: (draft) => draft.gameEdit.platformsController.text,
              setValue: (draft, value) =>
                  draft.gameEdit.platformsController.text = value,
            ),
            _textField(
              id: 'genres',
              label: 'Genres',
              value: (draft) => draft.gameEdit.genresController.text,
              setValue: (draft, value) =>
                  draft.gameEdit.genresController.text = value,
            ),
            VocabularyEditField<GameEditDraft, String>(
              id: 'age_rating',
              label: 'Age rating',
              value: (draft) => _nullableText(
                draft.gameEdit.ageRatingController.text,
              ),
              setValue: (draft, value) =>
                  draft.gameEdit.ageRatingController.text = value ?? '',
              options: _options(GameVocabularies.ageRating.builtIns),
            ),
            _textField(
              id: 'language',
              label: 'Language',
              value: (draft) => draft.gameEdit.languageController.text,
              setValue: (draft, value) =>
                  draft.gameEdit.languageController.text = value,
            ),
            _textField(
              id: 'country',
              label: 'Country',
              value: (draft) => draft.gameEdit.countryController.text,
              setValue: (draft, value) =>
                  draft.gameEdit.countryController.text = value,
            ),
            DateEditField<GameEditDraft>(
              id: 'release_date',
              label: 'Release date',
              value: (draft) => DateTime.tryParse(
                draft.gameEdit.releaseDateController.text.trim(),
              ),
              setValue: (draft, value) => draft.gameEdit.releaseDateController
                  .text = value == null ? '' : _formatDate(value),
              validator: (draft) => _validDate(
                draft.gameEdit.releaseDateController.text,
                'Release date',
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);

TextEditField<GameEditDraft> _textField({
  required String id,
  required String label,
  required String Function(GameEditDraft draft) value,
  required void Function(GameEditDraft draft, String value) setValue,
}) {
  return TextEditField(
    id: id,
    label: label,
    value: value,
    setValue: setValue,
  );
}

String? _nullableText(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

List<EditOption<String>> _options(Iterable<String> values) => [
      for (final value in values) EditOption(value: value, label: value),
    ];

String? _validDate(String value, String label) {
  return value.trim().isNotEmpty && DateTime.tryParse(value.trim()) == null
      ? '$label is invalid'
      : null;
}

String _formatDate(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';
