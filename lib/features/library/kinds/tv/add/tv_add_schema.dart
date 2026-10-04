import 'dart:async';

import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/kinds/tv/add/tv_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/kinds/tv/forms/tv_catalog_form_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/vocabulary/tv_vocabularies.dart';

final AddSchema<TvAddManualDraft> tvAddSchema = tvAddSchemaFor();

const tvMainFieldIds = {
  'catalog_title',
  'sort_key',
  'original_title',
  'localized_title',
  'display_title',
  'country',
  'publisher',
  'language',
  'age_rating',
  'genres',
  'runtime_minutes',
  'season_number',
};

const tvEditionFieldIds = {
  'edition_title',
  'variant_name',
  'physical_format',
  'release_date',
  'barcode',
};

const tvSpecsFieldIds = {
  'audio_tracks',
  'subtitles',
  'nr_discs',
  'screen_ratio',
  'layers',
  'color',
};

AddSchema<TDraft> tvAddSchemaFor<TDraft extends TvCatalogFormDraft>({
  Set<String>? fieldIds,
  String sectionLabel = 'Catalog Item',
  Iterable<String>? formatOptions,
  Iterable<String>? audioTrackOptions,
  Iterable<String>? subtitleOptions,
  String? Function(String value)? physicalFormatIdForValue,
  FutureOr<void> Function()? onManageFormat,
}) =>
    AddSchema<TDraft>(
      title: (_) => 'Manual TV Catalog Item',
      validate: (draft) {
        final metadata = draft.metadata;
        if (metadata.seasonNumber != null && metadata.seasonNumber! < 0) {
          return 'Season number cannot be negative';
        }
        if (metadata.episodeRuntimeMinutes != null &&
            metadata.episodeRuntimeMinutes! < 1) {
          return 'Runtime must be greater than zero';
        }
        if (metadata.nrDiscs != null && metadata.nrDiscs! < 1) {
          return 'Disc count must be greater than zero';
        }
        return null;
      },
      sections: [
        AddSectionSpec<TDraft>(
          id: 'catalog_item',
          label: sectionLabel,
          fields: [
            libraryAddCatalogTitleField<TDraft>(),
            _text<TDraft>(
              id: 'sort_key',
              label: 'Sort Title',
              read: (metadata) => metadata.sortKey ?? '',
              write: (draft, value) =>
                  _writeNullable(draft, 'sort_key', _nullable(value)),
            ),
            _text<TDraft>(
              id: 'original_title',
              label: 'Original Title',
              read: (metadata) => metadata.originalTitle ?? '',
              write: (draft, value) =>
                  _writeNullable(draft, 'original_title', _nullable(value)),
            ),
            _text<TDraft>(
              id: 'localized_title',
              label: 'Localized Title',
              read: (metadata) => metadata.localizedTitle ?? '',
              write: (draft, value) => _writeNullable(
                draft,
                'localized_title',
                _nullable(value),
              ),
            ),
            _text<TDraft>(
              id: 'display_title',
              label: 'Custom Display Title',
              read: (metadata) => metadata.displayTitle ?? '',
              write: (draft, value) => _writeNullable(
                draft,
                'display_title',
                _nullable(value),
              ),
            ),
            _text<TDraft>(
              id: 'edition_title',
              label: 'Edition Title',
              read: (metadata) => metadata.editionTitle ?? '',
              write: (draft, value) =>
                  _writeNullable(draft, 'edition_title', _nullable(value)),
            ),
            _text<TDraft>(
              id: 'variant_name',
              label: 'Variant',
              read: (metadata) => metadata.variant ?? '',
              write: (draft, value) =>
                  _writeNullable(draft, 'variant_name', _nullable(value)),
            ),
            _text<TDraft>(
              id: 'synopsis',
              label: 'Synopsis',
              read: (metadata) => metadata.synopsis ?? '',
              write: (draft, value) =>
                  _writeNullable(draft, 'synopsis', _nullable(value)),
              maxLines: 4,
            ),
            LibraryImageFieldSpec<TDraft, String>(
              id: 'cover_image_url',
              label: 'Front Cover URL',
              value: (draft) => _nullable(draft.metadata.coverImageUrl),
              setValue: (draft, value) => _writeNullable(
                draft,
                'cover_image_url',
                _nullable(value ?? ''),
              ),
            ),
            LibraryDateFieldSpec<TDraft>(
              id: 'release_date',
              label: 'Release Date',
              value: (draft) => draft.metadata.releaseDateParts?.asDateTime,
              setValue: (draft, value) {
                final date =
                    value == null ? null : PartialDate.fromDateTime(value);
                _writeNullableFields(draft, {
                  'release_date': date?.isoString,
                  'release_date_parts': date?.toJson(),
                });
              },
            ),
            _vocabulary<TDraft>(
              id: 'physical_format',
              label: 'Format',
              read: (metadata) =>
                  metadata.physicalFormatLabel ?? metadata.physicalFormat ?? '',
              write: (draft, value) {
                final normalized = _nullable(value ?? '');
                _writeNullableFields(draft, {
                  'physical_format': normalized == null
                      ? null
                      : physicalFormatIdForValue?.call(normalized) ??
                          normalized,
                  'physical_format_label': normalized,
                });
              },
              options: formatOptions ?? TvVocabularies.physicalFormat.builtIns,
              onManage: onManageFormat,
            ),
            _text<TDraft>(
              id: 'country',
              label: 'Country',
              read: (metadata) => metadata.country,
              write: (draft, value) =>
                  _writeNullable(draft, 'country', value.trim()),
            ),
            _text<TDraft>(
              id: 'publisher',
              label: 'Publisher / Network',
              read: (metadata) => metadata.publisher ?? metadata.network ?? '',
              write: (draft, value) => _writeNullableFields(draft, {
                'publisher': _nullable(value),
                'network': _nullable(value),
              }),
            ),
            _text<TDraft>(
              id: 'language',
              label: 'Language',
              read: (metadata) => metadata.originalLanguage,
              write: (draft, value) => _writeNullable(
                draft,
                'original_language',
                value.trim(),
              ),
            ),
            _text<TDraft>(
              id: 'age_rating',
              label: 'Age Rating',
              read: (metadata) => metadata.contentRating ?? '',
              write: (draft, value) =>
                  _writeNullable(draft, 'age_rating', _nullable(value)),
            ),
            LibraryMultiVocabularyFieldSpec<TDraft, String>(
              id: 'genres',
              label: 'Genres',
              values: (draft) => draft.metadata.genres.toSet(),
              setValues: (draft, values) => draft.metadata =
                  draft.metadata.copyWith(genres: values.toList()),
              options: const [],
              allowCustomValues: true,
            ),
            _text<TDraft>(
              id: 'barcode',
              label: 'Barcode',
              read: (metadata) => metadata.barcode ?? '',
              write: (draft, value) =>
                  _writeNullable(draft, 'barcode', _nullable(value)),
            ),
            _text<TDraft>(
              id: 'characters',
              label: 'Characters',
              read: (metadata) => metadata.characters
                  .map((character) => character.name)
                  .join(', '),
              write: (draft, value) => draft.metadata = draft.metadata.copyWith(
                characters:
                    _updatedCharacters(draft.metadata.characters, value),
              ),
            ),
            _multiVocabulary<TDraft>(
              id: 'audio_tracks',
              label: 'Audio tracks',
              read: (metadata) => metadata.audioTracks ?? '',
              write: (draft, values) => _writeNullable(
                draft,
                'audio_tracks',
                values.isEmpty ? null : values.join(', '),
              ),
              options: audioTrackOptions ?? TvVocabularies.audio.builtIns,
              pickListKey: TvVocabularyIds.audio.value,
            ),
            _multiVocabulary<TDraft>(
              id: 'subtitles',
              label: 'Subtitles',
              read: (metadata) => metadata.subtitles ?? '',
              write: (draft, values) => _writeNullable(
                draft,
                'subtitles',
                values.isEmpty ? null : values.join(', '),
              ),
              options: subtitleOptions ?? TvVocabularies.subtitles.builtIns,
              pickListKey: TvVocabularyIds.subtitles.value,
            ),
            _number<TDraft>(
              id: 'season_number',
              label: 'Season Number',
              read: (metadata) => metadata.seasonNumber,
              write: (draft, value) =>
                  _writeNullable(draft, 'season_number', value?.toInt()),
              minimum: 0,
            ),
            _number<TDraft>(
              id: 'runtime_minutes',
              label: 'Runtime (minutes)',
              read: (metadata) => metadata.episodeRuntimeMinutes,
              write: (draft, value) => _writeNullable(
                draft,
                'episode_runtime_minutes',
                value?.toInt(),
              ),
              minimum: 1,
            ),
            _number<TDraft>(
              id: 'nr_discs',
              label: 'Disc Count',
              read: (metadata) => metadata.nrDiscs,
              write: (draft, value) =>
                  _writeNullable(draft, 'nr_discs', value?.toInt()),
              minimum: 1,
            ),
            _text<TDraft>(
              id: 'screen_ratio',
              label: 'Screen Ratio',
              read: (metadata) => metadata.screenRatio ?? '',
              write: (draft, value) =>
                  _writeNullable(draft, 'screen_ratio', _nullable(value)),
            ),
            _text<TDraft>(
              id: 'layers',
              label: 'Layers',
              read: (metadata) => metadata.layers ?? '',
              write: (draft, value) =>
                  _writeNullable(draft, 'layers', _nullable(value)),
            ),
            _text<TDraft>(
              id: 'color',
              label: 'Color',
              read: (metadata) => metadata.color ?? '',
              write: (draft, value) =>
                  _writeNullable(draft, 'color', _nullable(value)),
            ),
          ]
              .where((field) => fieldIds == null || fieldIds.contains(field.id))
              .toList(),
          fullWidthFieldIds: const {'catalog_title'},
        ),
      ],
    );

LibraryTextFieldSpec<TDraft> _text<TDraft extends TvCatalogFormDraft>({
  required String id,
  required String label,
  required String Function(TvMetadata metadata) read,
  required void Function(TDraft draft, String value) write,
  int maxLines = 1,
}) =>
    LibraryTextFieldSpec<TDraft>(
      id: id,
      label: label,
      value: (draft) => read(draft.metadata),
      setValue: write,
      maxLines: maxLines,
    );

LibraryNumberFieldSpec<TDraft> _number<TDraft extends TvCatalogFormDraft>({
  required String id,
  required String label,
  required num? Function(TvMetadata metadata) read,
  required void Function(TDraft draft, num? value) write,
  required num minimum,
}) =>
    LibraryNumberFieldSpec<TDraft>(
      id: id,
      label: label,
      value: (draft) => read(draft.metadata),
      setValue: write,
      minimum: minimum,
    );

LibraryVocabularyFieldSpec<TDraft, String>
    _vocabulary<TDraft extends TvCatalogFormDraft>({
  required String id,
  required String label,
  required String Function(TvMetadata metadata) read,
  required void Function(TDraft draft, String? value) write,
  required Iterable<String> options,
  FutureOr<void> Function()? onManage,
}) =>
        LibraryVocabularyFieldSpec<TDraft, String>(
          id: id,
          label: label,
          value: (draft) => read(draft.metadata),
          setValue: write,
          options: [
            for (final value in options)
              LibraryFieldOption(value: value, label: value),
          ],
          onManage: onManage == null ? null : (_) => onManage(),
        );

LibraryMultiVocabularyFieldSpec<TDraft, String>
    _multiVocabulary<TDraft extends TvCatalogFormDraft>({
  required String id,
  required String label,
  required String Function(TvMetadata metadata) read,
  required void Function(TDraft draft, Set<String> values) write,
  required Iterable<String> options,
  required String pickListKey,
}) =>
        LibraryMultiVocabularyFieldSpec<TDraft, String>(
          id: id,
          label: label,
          values: (draft) => _split(read(draft.metadata)).toSet(),
          setValues: write,
          options: [
            for (final value in options)
              LibraryFieldOption(value: value, label: value),
          ],
          pickListKey: pickListKey,
          pluralLabel: label,
          allowCustomValues: true,
        );

void _writeNullable<TDraft extends TvCatalogFormDraft>(
  TDraft draft,
  String key,
  Object? value,
) =>
    _writeNullableFields(draft, {key: value});

void _writeNullableFields<TDraft extends TvCatalogFormDraft>(
  TDraft draft,
  Map<String, Object?> fields,
) {
  final payload = Map<String, dynamic>.from(draft.metadata.toJson())
    ..addAll(fields);
  draft.metadata = TvMetadata.fromJson(payload);
}

String? _nullable(String? value) {
  final normalized = value?.trim() ?? '';
  return normalized.isEmpty ? null : normalized;
}

List<String> _split(String value) => value
    .split(RegExp(r'[,\r\n]+'))
    .map((entry) => entry.trim())
    .where((entry) => entry.isNotEmpty)
    .toSet()
    .toList(growable: false);

List<TvCharacterMetadata> _updatedCharacters(
  List<TvCharacterMetadata> existing,
  String value,
) {
  final previousByName = {
    for (final character in existing)
      character.name.trim().toLowerCase(): character,
  };
  return [
    for (final rawName in _split(value))
      if (previousByName.remove(rawName.toLowerCase()) case final previous?)
        TvCharacterMetadata(
          name: rawName,
          id: previous.id,
          characterId: previous.characterId,
          aliases: previous.aliases,
          role: previous.role,
          description: previous.description,
          imageUrl: previous.imageUrl,
          stringValue: previous.stringValue,
        )
      else
        TvCharacterMetadata(name: rawName),
  ];
}
