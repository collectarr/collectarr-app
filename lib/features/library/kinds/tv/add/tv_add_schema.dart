import 'dart:async';

import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/kinds/tv/add/tv_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/kinds/tv/vocabulary/tv_vocabularies.dart';

final AddSchema<TvAddManualDraft> tvAddSchema = tvAddSchemaFor();

AddSchema<TvAddManualDraft> tvAddSchemaFor({
  Iterable<String>? formatOptions,
  FutureOr<void> Function()? onManageFormat,
}) =>
    AddSchema<TvAddManualDraft>(
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
        AddSectionSpec<TvAddManualDraft>(
          id: 'catalog_item',
          label: 'Catalog Item',
          fields: [
            libraryAddCatalogTitleField<TvAddManualDraft>(),
            _text(
              id: 'sort_key',
              label: 'Sort Title',
              read: (metadata) => metadata.sortKey ?? '',
              write: (draft, value) =>
                  _writeNullable(draft, 'sort_key', _nullable(value)),
            ),
            _text(
              id: 'original_title',
              label: 'Original Title',
              read: (metadata) => metadata.originalTitle ?? '',
              write: (draft, value) =>
                  _writeNullable(draft, 'original_title', _nullable(value)),
            ),
            _text(
              id: 'edition_title',
              label: 'Edition Title',
              read: (metadata) => metadata.editionTitle ?? '',
              write: (draft, value) =>
                  _writeNullable(draft, 'edition_title', _nullable(value)),
            ),
            _text(
              id: 'synopsis',
              label: 'Synopsis',
              read: (metadata) => metadata.synopsis ?? '',
              write: (draft, value) =>
                  _writeNullable(draft, 'synopsis', _nullable(value)),
              maxLines: 4,
            ),
            LibraryImageFieldSpec<TvAddManualDraft, String>(
              id: 'cover_image_url',
              label: 'Front Cover URL',
              value: (draft) => _nullable(draft.metadata.coverImageUrl),
              setValue: (draft, value) => _writeNullable(
                draft,
                'cover_image_url',
                _nullable(value ?? ''),
              ),
            ),
            LibraryDateFieldSpec<TvAddManualDraft>(
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
            _vocabulary(
              id: 'physical_format',
              label: 'Format',
              read: (metadata) =>
                  metadata.physicalFormatLabel ?? metadata.physicalFormat ?? '',
              write: (draft, value) => _writeNullableFields(draft, {
                'physical_format': _nullable(value ?? ''),
                'physical_format_label': _nullable(value ?? ''),
              }),
              options: formatOptions ?? TvVocabularies.physicalFormat.builtIns,
              onManage: onManageFormat,
            ),
            _text(
              id: 'country',
              label: 'Country',
              read: (metadata) => metadata.country,
              write: (draft, value) =>
                  _writeNullable(draft, 'country', value.trim()),
            ),
            _text(
              id: 'publisher',
              label: 'Publisher / Network',
              read: (metadata) => metadata.publisher ?? metadata.network ?? '',
              write: (draft, value) => _writeNullableFields(draft, {
                'publisher': _nullable(value),
                'network': _nullable(value),
              }),
            ),
            _text(
              id: 'language',
              label: 'Language',
              read: (metadata) => metadata.originalLanguage,
              write: (draft, value) => _writeNullable(
                draft,
                'original_language',
                value.trim(),
              ),
            ),
            _text(
              id: 'age_rating',
              label: 'Age Rating',
              read: (metadata) => metadata.contentRating ?? '',
              write: (draft, value) =>
                  _writeNullable(draft, 'age_rating', _nullable(value)),
            ),
            _text(
              id: 'genres',
              label: 'Genres',
              read: (metadata) => metadata.genres.join(', '),
              write: (draft, value) => draft.metadata =
                  draft.metadata.copyWith(genres: _split(value)),
            ),
            _text(
              id: 'barcode',
              label: 'Barcode',
              read: (metadata) => metadata.barcode ?? '',
              write: (draft, value) =>
                  _writeNullable(draft, 'barcode', _nullable(value)),
            ),
            _text(
              id: 'characters',
              label: 'Characters',
              read: (metadata) => metadata.characters
                  .map((character) => character.name)
                  .join(', '),
              write: (draft, value) => draft.metadata = draft.metadata.copyWith(
                characters: [
                  for (final name in _split(value))
                    TvCharacterMetadata(name: name),
                ],
              ),
            ),
            _text(
              id: 'audio_tracks',
              label: 'Audio Tracks',
              read: (metadata) => metadata.audioTracks ?? '',
              write: (draft, value) =>
                  _writeNullable(draft, 'audio_tracks', _nullable(value)),
            ),
            _text(
              id: 'subtitles',
              label: 'Subtitles',
              read: (metadata) => metadata.subtitles ?? '',
              write: (draft, value) =>
                  _writeNullable(draft, 'subtitles', _nullable(value)),
            ),
            _number(
              id: 'season_number',
              label: 'Season Number',
              read: (metadata) => metadata.seasonNumber,
              write: (draft, value) =>
                  _writeNullable(draft, 'season_number', value?.toInt()),
              minimum: 0,
            ),
            _number(
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
            _number(
              id: 'nr_discs',
              label: 'Disc Count',
              read: (metadata) => metadata.nrDiscs,
              write: (draft, value) =>
                  _writeNullable(draft, 'nr_discs', value?.toInt()),
              minimum: 1,
            ),
            _text(
              id: 'screen_ratio',
              label: 'Screen Ratio',
              read: (metadata) => metadata.screenRatio ?? '',
              write: (draft, value) =>
                  _writeNullable(draft, 'screen_ratio', _nullable(value)),
            ),
          ],
          fullWidthFieldIds: const {'catalog_title'},
        ),
      ],
    );

LibraryTextFieldSpec<TvAddManualDraft> _text({
  required String id,
  required String label,
  required String Function(TvMetadata metadata) read,
  required void Function(TvAddManualDraft draft, String value) write,
  int maxLines = 1,
}) =>
    LibraryTextFieldSpec<TvAddManualDraft>(
      id: id,
      label: label,
      value: (draft) => read(draft.metadata),
      setValue: write,
      maxLines: maxLines,
    );

LibraryNumberFieldSpec<TvAddManualDraft> _number({
  required String id,
  required String label,
  required num? Function(TvMetadata metadata) read,
  required void Function(TvAddManualDraft draft, num? value) write,
  required num minimum,
}) =>
    LibraryNumberFieldSpec<TvAddManualDraft>(
      id: id,
      label: label,
      value: (draft) => read(draft.metadata),
      setValue: write,
      minimum: minimum,
    );

LibraryVocabularyFieldSpec<TvAddManualDraft, String> _vocabulary({
  required String id,
  required String label,
  required String Function(TvMetadata metadata) read,
  required void Function(TvAddManualDraft draft, String? value) write,
  required Iterable<String> options,
  FutureOr<void> Function()? onManage,
}) =>
    LibraryVocabularyFieldSpec<TvAddManualDraft, String>(
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

void _writeNullable(TvAddManualDraft draft, String key, Object? value) =>
    _writeNullableFields(draft, {key: value});

void _writeNullableFields(
  TvAddManualDraft draft,
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
