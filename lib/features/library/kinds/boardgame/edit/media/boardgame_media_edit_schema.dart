import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit/boardgame_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/vocabulary/boardgame_vocabularies.dart';
import 'package:flutter/material.dart';

final EditSchema<BoardGameMetadata, BoardGameEditDraft>
    boardGameMediaEditSchema = EditSchema(
  title: (_) => 'Edit board game',
  validate: (_, draft) {
    final integerFields = <String, TextEditingController>{
      'Minimum players': draft.minPlayersController,
      'Maximum players': draft.maxPlayersController,
      'Minimum playtime': draft.minPlaytimeController,
      'Maximum playtime': draft.maxPlaytimeController,
      'Minimum age': draft.minimumAgeController,
      'BGG rating count': draft.bggRatingCountController,
      'BGG rank': draft.bggRankController,
    };
    for (final entry in integerFields.entries) {
      final value = entry.value.text.trim();
      if (value.isNotEmpty && int.tryParse(value) == null) {
        return '${entry.key} must be a whole number';
      }
    }
    final rating = draft.bggRatingController.text.trim();
    if (rating.isNotEmpty && double.tryParse(rating) == null) {
      return 'BGG rating must be a number';
    }
    final complexity = draft.complexityWeightController.text.trim();
    if (complexity.isNotEmpty && double.tryParse(complexity) == null) {
      return 'Complexity weight must be a number';
    }
    return null;
  },
  tabs: [
    EditTabSpec(
      id: 'identity',
      label: 'Identity',
      icon: Icons.title,
      sections: [
        EditSectionSpec(
          id: 'titles',
          label: 'Titles and identifiers',
          fields: [
            _textField(
              id: 'original_title',
              label: 'Original title',
              value: (draft) => draft.originalTitleController.text,
              setValue: (draft, value) =>
                  draft.originalTitleController.text = value,
            ),
            _textField(
              id: 'year_published',
              label: 'Year published',
              value: (draft) => draft.releaseYearController.text,
              setValue: (draft, value) =>
                  draft.releaseYearController.text = value,
            ),
            _textField(
              id: 'series',
              label: 'Series',
              value: (draft) => draft.seriesTitleController.text,
              setValue: (draft, value) =>
                  draft.seriesTitleController.text = value,
            ),
            _textField(
              id: 'item_number',
              label: 'Item number',
              value: (draft) => draft.itemNumberController.text,
              setValue: (draft, value) =>
                  draft.itemNumberController.text = value,
            ),
            _textField(
              id: 'variant',
              label: 'Variant',
              value: (draft) => draft.variantController.text,
              setValue: (draft, value) => draft.variantController.text = value,
            ),
            _textField(
              id: 'barcode',
              label: 'Barcode',
              value: (draft) => draft.barcodeController.text,
              setValue: (draft, value) => draft.barcodeController.text = value,
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
              id: 'recommended_players',
              label: 'Recommended players',
              value: (draft) => draft.recommendedPlayersController.text,
              setValue: (draft, value) =>
                  draft.recommendedPlayersController.text = value,
            ),
            _textField(
              id: 'best_players',
              label: 'Best players',
              value: (draft) => draft.bestPlayersController.text,
              setValue: (draft, value) =>
                  draft.bestPlayersController.text = value,
            ),
            _textField(
              id: 'min_playtime',
              label: 'Minimum playtime (minutes)',
              value: (draft) => draft.minPlaytimeController.text,
              setValue: (draft, value) =>
                  draft.minPlaytimeController.text = value,
            ),
            _textField(
              id: 'max_playtime',
              label: 'Maximum playtime (minutes)',
              value: (draft) => draft.maxPlaytimeController.text,
              setValue: (draft, value) =>
                  draft.maxPlaytimeController.text = value,
            ),
            _textField(
              id: 'minimum_age',
              label: 'Minimum age',
              value: (draft) => draft.minimumAgeController.text,
              setValue: (draft, value) =>
                  draft.minimumAgeController.text = value,
            ),
            _textField(
              id: 'complexity_weight',
              label: 'Complexity weight',
              value: (draft) => draft.complexityWeightController.text,
              setValue: (draft, value) =>
                  draft.complexityWeightController.text = value,
            ),
          ],
        ),
      ],
    ),
    EditTabSpec(
      id: 'classification',
      label: 'Classification',
      icon: Icons.category_outlined,
      sections: [
        EditSectionSpec(
          id: 'credits',
          label: 'Credits and classification',
          fields: [
            _textField(
              id: 'designers',
              label: 'Designers',
              value: (draft) => draft.designersController.text,
              setValue: (draft, value) =>
                  draft.designersController.text = value,
            ),
            _textField(
              id: 'artists',
              label: 'Artists',
              value: (draft) => draft.artistsController.text,
              setValue: (draft, value) => draft.artistsController.text = value,
            ),
            VocabularyEditField<BoardGameEditDraft, String>(
              id: 'publisher',
              label: 'Publishers',
              value: (draft) => _nullableText(draft.publisherController.text),
              setValue: (draft, value) =>
                  draft.publisherController.text = value ?? '',
              options: _options(BoardGameVocabularies.publisher.builtIns),
            ),
            _textField(
              id: 'mechanics',
              label: 'Mechanics',
              value: (draft) => draft.mechanicsController.text,
              setValue: (draft, value) =>
                  draft.mechanicsController.text = value,
            ),
            _textField(
              id: 'categories',
              label: 'Categories',
              value: (draft) => draft.categoriesController.text,
              setValue: (draft, value) =>
                  draft.categoriesController.text = value,
            ),
            _textField(
              id: 'families',
              label: 'Families',
              value: (draft) => draft.familiesController.text,
              setValue: (draft, value) => draft.familiesController.text = value,
            ),
            _textField(
              id: 'themes',
              label: 'Themes',
              value: (draft) => draft.themesController.text,
              setValue: (draft, value) => draft.themesController.text = value,
            ),
            _textField(
              id: 'expansions',
              label: 'Expansions',
              value: (draft) => draft.expansionsController.text,
              setValue: (draft, value) =>
                  draft.expansionsController.text = value,
            ),
            _textField(
              id: 'expansion_for',
              label: 'Expansion for',
              value: (draft) => draft.expansionForController.text,
              setValue: (draft, value) =>
                  draft.expansionForController.text = value,
            ),
            _textField(
              id: 'languages',
              label: 'Languages',
              value: (draft) => draft.languagesController.text,
              setValue: (draft, value) =>
                  draft.languagesController.text = value,
            ),
            VocabularyEditField<BoardGameEditDraft, String>(
              id: 'format',
              label: 'Format',
              value: (draft) => _nullableText(
                draft.physicalFormatController.text,
              ),
              setValue: (draft, value) =>
                  draft.physicalFormatController.text = value ?? '',
              options: _options(BoardGameVocabularies.format.builtIns),
            ),
          ],
        ),
      ],
    ),
    EditTabSpec(
      id: 'bgg',
      label: 'BoardGameGeek',
      icon: Icons.insights_outlined,
      sections: [
        EditSectionSpec(
          id: 'bgg_stats',
          label: 'BGG statistics',
          fields: [
            _textField(
              id: 'bgg_rating',
              label: 'Rating',
              value: (draft) => draft.bggRatingController.text,
              setValue: (draft, value) =>
                  draft.bggRatingController.text = value,
            ),
            _textField(
              id: 'bgg_rating_count',
              label: 'Rating count',
              value: (draft) => draft.bggRatingCountController.text,
              setValue: (draft, value) =>
                  draft.bggRatingCountController.text = value,
            ),
            _textField(
              id: 'bgg_rank',
              label: 'Rank',
              value: (draft) => draft.bggRankController.text,
              setValue: (draft, value) => draft.bggRankController.text = value,
            ),
          ],
        ),
      ],
    ),
  ],
);

TextEditField<BoardGameEditDraft> _textField({
  required String id,
  required String label,
  required String Function(BoardGameEditDraft draft) value,
  required void Function(BoardGameEditDraft draft, String value) setValue,
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
