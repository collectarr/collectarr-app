import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/media/comic_media_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/vocabulary/comic_vocabularies.dart';
import 'package:flutter/material.dart';

final EditSchema<ComicMedia, ComicMediaEditDraft> comicMediaEditSchema =
    EditSchema(
  title: (_) => 'Edit comic',
  validate: (_, draft) {
    if (draft.pageCount case final pageCount? when pageCount < 0) {
      return 'Page count cannot be negative';
    }
    if (draft.coverDate == null && draft.coverDateController.text.isNotEmpty) {
      return 'Cover date is invalid';
    }
    if (draft.releaseDate == null &&
        draft.releaseDateController.text.isNotEmpty) {
      return 'Release date is invalid';
    }
    return null;
  },
  tabs: [
    EditTabSpec(
      id: 'main',
      label: 'Main',
      icon: Icons.article,
      sections: [
        EditSectionSpec(
          id: 'catalog_snapshot',
          label: 'Issue',
          fields: [
            _textField(
              id: 'series',
              label: 'Series',
              value: (draft) => draft.seriesTitle,
              setValue: (draft, value) => draft.seriesTitle = value,
            ),
            _textField(
              id: 'issue_number',
              label: 'Issue number',
              value: (draft) => draft.number,
              setValue: (draft, value) => draft.number = value,
            ),
            _textField(
              id: 'variant',
              label: 'Variant',
              value: (draft) => draft.variant,
              setValue: (draft, value) => draft.variant = value,
            ),
            _textField(
              id: 'edition_title',
              label: 'Edition title',
              value: (draft) => draft.editionTitle,
              setValue: (draft, value) => draft.editionTitle = value,
            ),
            _textField(
              id: 'barcode',
              label: 'Barcode',
              value: (draft) => draft.barcode,
              setValue: (draft, value) => draft.barcode = value,
            ),
            VocabularyEditField<ComicMediaEditDraft, String>(
              id: 'physical_format',
              label: 'Format',
              value: (draft) => draft.physicalFormat,
              setValue: (draft, value) => draft.physicalFormat = value ?? '',
              options: _options(ComicVocabularies.physicalFormat.builtIns),
            ),
            DateEditField<ComicMediaEditDraft>(
              id: 'cover_date',
              label: 'Cover date',
              value: (draft) => draft.coverDate,
              setValue: (draft, value) => draft.coverDate = value,
              validator: (draft) =>
                  _validDate(draft.coverDateController.text, 'Cover date'),
            ),
            DateEditField<ComicMediaEditDraft>(
              id: 'release_date',
              label: 'Release date',
              value: (draft) => draft.releaseDate,
              setValue: (draft, value) => draft.releaseDate = value,
              validator: (draft) =>
                  _validDate(draft.releaseDateController.text, 'Release date'),
            ),
          ],
        ),
      ],
    ),
    EditTabSpec(
      id: 'details',
      label: 'Details',
      icon: Icons.search,
      sections: [
        EditSectionSpec(
          id: 'catalog_details',
          label: 'Publication details',
          fields: [
            VocabularyEditField<ComicMediaEditDraft, String>(
              id: 'publisher',
              label: 'Publisher',
              value: (draft) => _nullableText(draft.publisher),
              setValue: (draft, value) => draft.publisher = value ?? '',
              options: _options(ComicVocabularies.publisher.builtIns),
            ),
            VocabularyEditField<ComicMediaEditDraft, String>(
              id: 'imprint',
              label: 'Imprint',
              value: (draft) => _nullableText(draft.imprint),
              setValue: (draft, value) => draft.imprint = value ?? '',
              options: _options(ComicVocabularies.imprint.builtIns),
            ),
            VocabularyEditField<ComicMediaEditDraft, String>(
              id: 'series_group',
              label: 'Series group',
              value: (draft) => _nullableText(draft.seriesGroup),
              setValue: (draft, value) => draft.seriesGroup = value ?? '',
              options: _options(ComicVocabularies.seriesGroup.builtIns),
            ),
            NumberEditField<ComicMediaEditDraft>(
              id: 'page_count',
              label: 'Page count',
              value: (draft) => draft.pageCount,
              setValue: (draft, value) => draft.pageCount = value?.round(),
              minimum: 0,
              validator: _validPageCount,
            ),
            _textField(
              id: 'age_rating',
              label: 'Age rating',
              value: (draft) => draft.ageRating,
              setValue: (draft, value) => draft.ageRating = value,
            ),
            MultiVocabularyEditField<ComicMediaEditDraft, String>(
              id: 'genres',
              label: 'Genres',
              values: (draft) => draft.genres,
              setValues: (draft, values) => draft.genres = values,
              options: const [],
            ),
            _textField(
              id: 'language',
              label: 'Language',
              value: (draft) => draft.language,
              setValue: (draft, value) => draft.language = value,
            ),
            _textField(
              id: 'country',
              label: 'Country',
              value: (draft) => draft.country,
              setValue: (draft, value) => draft.country = value,
            ),
            MultiVocabularyEditField<ComicMediaEditDraft, String>(
              id: 'crossover',
              label: 'Crossover',
              values: (draft) => draft.crossovers,
              setValues: (draft, values) => draft.crossovers = values,
              options: const [],
            ),
            MultiVocabularyEditField<ComicMediaEditDraft, String>(
              id: 'story_arcs',
              label: 'Story arcs',
              values: (draft) => draft.storyArcs,
              setValues: (draft, values) => draft.storyArcs = values,
              options: const [],
            ),
          ],
        ),
      ],
    ),
    _customTab(
      id: 'creators',
      label: 'Creators',
      icon: Icons.group,
      sectionId: 'comic_creators',
      sectionLabel: 'Creator credits',
      fieldId: 'creator_credits',
      fieldLabel: 'Creators',
    ),
    _customTab(
      id: 'characters',
      label: 'Characters',
      icon: Icons.face,
      sectionId: 'comic_characters',
      sectionLabel: 'Character appearances',
      fieldId: 'character_appearances',
      fieldLabel: 'Characters',
    ),
    _customTab(
      id: 'links',
      label: 'Links',
      icon: Icons.link,
      sectionId: 'external_links',
      sectionLabel: 'External links',
      fieldId: 'external_links',
      fieldLabel: 'Links',
    ),
    _customTab(
      id: 'cover',
      label: 'Covers',
      icon: Icons.image,
      sectionId: 'cover_images',
      sectionLabel: 'Cover images',
      fieldId: 'cover_images',
      fieldLabel: 'Covers',
    ),
    _customTab(
      id: 'photos',
      label: 'My Images',
      icon: Icons.photo_library,
      sectionId: 'photos',
      sectionLabel: 'Personal images',
      fieldId: 'photos',
      fieldLabel: 'Photos',
    ),
  ],
);

TextEditField<ComicMediaEditDraft> _textField({
  required String id,
  required String label,
  required String Function(ComicMediaEditDraft draft) value,
  required void Function(ComicMediaEditDraft draft, String value) setValue,
}) {
  return TextEditField(
    id: id,
    label: label,
    value: value,
    setValue: setValue,
  );
}

EditTabSpec<ComicMediaEditDraft> _customTab({
  required String id,
  required String label,
  required IconData icon,
  required String sectionId,
  required String sectionLabel,
  required String fieldId,
  required String fieldLabel,
}) {
  return EditTabSpec(
    id: id,
    label: label,
    icon: icon,
    sections: [
      EditSectionSpec(
        id: sectionId,
        label: sectionLabel,
        fields: [
          CustomEditField(
            id: fieldId,
            label: fieldLabel,
            builder: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    ],
  );
}

List<EditOption<String>> _options(Iterable<String> values) => [
      for (final value in values) EditOption(value: value, label: value),
    ];

String? _validDate(String value, String label) {
  return value.isNotEmpty && DateTime.tryParse(value) == null
      ? '$label is invalid'
      : null;
}

String? _validPageCount(ComicMediaEditDraft draft) {
  final value = draft.pageCount;
  return value != null && value < 0 ? 'Page count cannot be negative' : null;
}

String? _nullableText(String value) => value.trim().isEmpty ? null : value;
