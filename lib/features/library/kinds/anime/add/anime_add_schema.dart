import 'dart:async';

import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/schema/library_form_schema.dart';
import 'package:collectarr_app/features/library/add/schema/library_add_catalog_title_field.dart';
import 'package:collectarr_app/features/library/kinds/anime/add/anime_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata_children.dart';
import 'package:collectarr_app/features/library/kinds/anime/forms/anime_catalog_form_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/vocabulary/anime_vocabularies.dart';

final LibraryFormSchema<AnimeAddManualDraft> animeAddSchema =
    animeAddSchemaFor();

const animeMainFieldIds = {
  'catalog_title',
  'display_title',
  'original_title',
  'localized_title',
  'search_aliases',
  'sort_key',
  'format',
  'season',
  'source_material',
  'original_language',
  'genres',
  'themes',
  'studios',
  'producers',
  'licensors',
  'airing_status',
  'season_year',
  'episode_count',
  'episode_runtime_minutes',
  'age_rating',
  'audience_rating',
  'start_date',
  'end_date',
};

const animeDetailsFieldIds = {
  'native_title',
  'romaji_title',
  'english_title',
  'alternate_titles',
  'country',
  'characters',
};

const animeEditionFieldIds = {
  'edition_title',
  'physical_format',
  'publisher',
  'barcode',
  'release_date',
  'variant_name',
  'region',
  'description',
};

const animeSpecsFieldIds = {
  'nr_discs',
  'audio_tracks',
  'subtitles',
  'screen_ratio',
  'layers',
  'color',
};

const animeCoverFieldIds = {'cover_image_url'};
const animeSynopsisFieldIds = {'synopsis'};

LibraryFormSchema<TDraft> animeAddSchemaFor<
        TDraft extends AnimeCatalogFormDraft>({
  Set<String>? fieldIds,
  String? sectionLabel,
  Iterable<String>? formatOptions,
  Iterable<String>? seasonOptions,
  Iterable<String>? airingStatusOptions,
  Iterable<String>? sourceMaterialOptions,
  Iterable<String>? physicalFormatOptions,
  Iterable<String>? regionOptions,
  FutureOr<void> Function()? onManageFormat,
  FutureOr<void> Function()? onManageSeason,
  FutureOr<void> Function()? onManagePhysicalFormat,
  FutureOr<void> Function()? onManageRegion,
}) =>
    LibraryFormSchema<TDraft>(
      title: (_) => 'Manual anime',
      validate: (draft) {
        final metadata = draft.metadata;
        if (metadata.seasonYear != null && metadata.seasonYear! < 0) {
          return 'Season year cannot be negative';
        }
        if (metadata.episodeCount != null && metadata.episodeCount! < 0) {
          return 'Episode count cannot be negative';
        }
        if (metadata.episodeRuntimeMinutes != null &&
            metadata.episodeRuntimeMinutes! < 0) {
          return 'Episode runtime cannot be negative';
        }
        if (metadata.startDate != null &&
            metadata.endDate != null &&
            metadata.endDate!.isBefore(metadata.startDate!)) {
          return 'End date cannot be before start date';
        }
        if (metadata.nrDiscs != null && metadata.nrDiscs! < 0) {
          return 'Disc count cannot be negative';
        }
        return null;
      },
      sections: _filterSections(fieldIds, sectionLabel, [
        LibraryFormSectionSpec<TDraft>(
          id: 'catalog',
          label: 'Catalog item',
          fields: [
            libraryAddCatalogTitleField<TDraft>(),
            _text<TDraft>(
              id: 'display_title',
              label: 'Display Title',
              read: (metadata) => metadata.displayTitle ?? '',
              write: (draft, value) => _writeNullable(
                draft,
                'display_title',
                _nullable(value),
              ),
            ),
            _text<TDraft>(
              id: 'original_title',
              label: 'Original Title',
              read: (metadata) => metadata.originalTitle ?? '',
              write: (draft, value) => _writeNullable(
                draft,
                'original_title',
                _nullable(value),
              ),
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
              id: 'search_aliases',
              label: 'Search Aliases',
              read: (metadata) => metadata.searchAliases.join(', '),
              write: (draft, value) => draft.metadata = draft.metadata.copyWith(
                searchAliases: _split(value),
              ),
            ),
            _text<TDraft>(
              id: 'sort_key',
              label: 'Sort Title',
              read: (metadata) => metadata.sortKey ?? '',
              write: (draft, value) =>
                  _writeNullable(draft, 'sort_key', _nullable(value)),
            ),
            LibraryTextFieldSpec<TDraft>(
              id: 'synopsis',
              label: 'Synopsis',
              value: (draft) => draft.metadata.synopsis ?? '',
              setValue: (draft, value) => _writeNullable(
                draft,
                'synopsis',
                _nullable(value),
              ),
              maxLines: 4,
            ),
            LibraryImageFieldSpec<TDraft, String>(
              id: 'cover_image_url',
              label: 'Cover image URL',
              value: (draft) => _nullable(draft.metadata.coverImageUrl),
              setValue: (draft, value) => _writeNullable(
                draft,
                'cover_image_url',
                _nullable(value ?? ''),
              ),
            ),
            _vocabulary<TDraft>(
              id: 'format',
              label: 'Anime format',
              read: (metadata) => metadata.format.label,
              write: (draft, value) => draft.metadata = draft.metadata.copyWith(
                format: AnimeFormat.fromString(value),
              ),
              options: formatOptions ?? AnimeVocabularies.format.builtIns,
              pickListKey: AnimeVocabularyIds.format.value,
              onManage: onManageFormat,
            ),
            _vocabulary<TDraft>(
              id: 'season',
              label: 'Season',
              read: (metadata) => metadata.season?.label ?? '',
              write: (draft, value) => _writeNullable(
                draft,
                'season',
                _animeSeason(value)?.name,
              ),
              options: seasonOptions ?? AnimeVocabularies.season.builtIns,
              pickListKey: AnimeVocabularyIds.season.value,
              onManage: onManageSeason,
            ),
            _vocabulary<TDraft>(
              id: 'source_material',
              label: 'Source material',
              read: (metadata) => metadata.sourceMaterial.label,
              write: (draft, value) => draft.metadata = draft.metadata.copyWith(
                sourceMaterial: AnimeSource.fromString(value),
              ),
              options: sourceMaterialOptions ??
                  const [
                    'Manga',
                    'Light Novel',
                    'Original',
                    'Visual Novel',
                    'Game',
                    'Novel',
                    'Other',
                  ],
            ),
            _text<TDraft>(
              id: 'original_language',
              label: 'Original language',
              read: (metadata) => metadata.language,
              write: (draft, value) =>
                  draft.metadata = draft.metadata.copyWith(language: value),
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
              id: 'themes',
              label: 'Themes',
              read: (metadata) => metadata.themes.join(', '),
              write: (draft, value) => draft.metadata =
                  draft.metadata.copyWith(themes: _split(value)),
            ),
            _text<TDraft>(
              id: 'studios',
              label: 'Studios',
              read: (metadata) => metadata.studios.join(', '),
              write: (draft, value) => draft.metadata =
                  draft.metadata.copyWith(studios: _split(value)),
            ),
            _text<TDraft>(
              id: 'producers',
              label: 'Producers',
              read: (metadata) => metadata.producers.join(', '),
              write: (draft, value) => draft.metadata =
                  draft.metadata.copyWith(producers: _split(value)),
            ),
            _text<TDraft>(
              id: 'licensors',
              label: 'Licensors',
              read: (metadata) => metadata.licensors.join(', '),
              write: (draft, value) => draft.metadata =
                  draft.metadata.copyWith(licensors: _split(value)),
            ),
            _vocabulary<TDraft>(
              id: 'airing_status',
              label: 'Airing status',
              read: (metadata) => metadata.airingStatus.label,
              write: (draft, value) => draft.metadata = draft.metadata.copyWith(
                airingStatus: AnimeAiringStatus.fromString(value),
              ),
              options: airingStatusOptions ??
                  const [
                    'Currently Airing',
                    'Finished Airing',
                    'Not Yet Aired',
                    'Cancelled',
                  ],
            ),
            _number<TDraft>(
              id: 'season_year',
              label: 'Season year',
              read: (metadata) => metadata.seasonYear,
              write: (draft, value) => draft.metadata =
                  draft.metadata.copyWith(seasonYear: value?.toInt()),
            ),
            _number<TDraft>(
              id: 'episode_count',
              label: 'Episode count',
              read: (metadata) => metadata.episodeCount,
              write: (draft, value) => draft.metadata =
                  draft.metadata.copyWith(episodeCount: value?.toInt()),
            ),
            _number<TDraft>(
              id: 'episode_runtime_minutes',
              label: 'Episode runtime (minutes)',
              read: (metadata) => metadata.episodeRuntimeMinutes,
              write: (draft, value) => draft.metadata = draft.metadata
                  .copyWith(episodeRuntimeMinutes: value?.toInt()),
            ),
            _text<TDraft>(
              id: 'age_rating',
              label: 'Age Rating',
              read: (metadata) => metadata.ageRating ?? '',
              write: (draft, value) => _writeNullable(
                draft,
                'age_rating',
                _nullable(value),
              ),
            ),
            _text<TDraft>(
              id: 'audience_rating',
              label: 'Audience Rating',
              read: (metadata) => metadata.audienceRating ?? '',
              write: (draft, value) => _writeNullable(
                draft,
                'audience_rating',
                _nullable(value),
              ),
            ),
            LibraryDateFieldSpec<TDraft>(
              id: 'start_date',
              label: 'Start date',
              value: (draft) => draft.metadata.startDate,
              setValue: (draft, value) => _writeNullable(
                draft,
                'start_date',
                value?.toIso8601String(),
              ),
            ),
            LibraryDateFieldSpec<TDraft>(
              id: 'end_date',
              label: 'End date',
              value: (draft) => draft.metadata.endDate,
              setValue: (draft, value) => _writeNullable(
                draft,
                'end_date',
                value?.toIso8601String(),
              ),
            ),
          ],
          fullWidthFieldIds: const {'catalog_title'},
        ),
        LibraryFormSectionSpec<TDraft>(
          id: 'edition_details',
          label: 'Edition details',
          fields: [
            _text<TDraft>(
              id: 'edition_title',
              label: 'Edition title',
              read: (metadata) => metadata.editionTitle ?? '',
              write: (draft, value) =>
                  _writeNullable(draft, 'edition_title', _nullable(value)),
            ),
            _vocabulary<TDraft>(
              id: 'physical_format',
              label: 'Physical format',
              read: (metadata) =>
                  metadata.physicalFormatLabel ?? metadata.physicalFormat ?? '',
              write: (draft, value) => _writeNullableFields(draft, {
                'physical_format': _nullable(value ?? ''),
                'physical_format_label': _nullable(value ?? ''),
              }),
              options: physicalFormatOptions ??
                  AnimeVocabularies.physicalFormat.builtIns,
              pickListKey: AnimeVocabularyIds.physicalFormat.value,
              onManage: onManagePhysicalFormat,
            ),
            _text<TDraft>(
              id: 'publisher',
              label: 'Publisher',
              read: (metadata) => metadata.publisher ?? '',
              write: (draft, value) =>
                  _writeNullable(draft, 'publisher', _nullable(value)),
            ),
            _text<TDraft>(
              id: 'barcode',
              label: 'Barcode',
              read: (metadata) => metadata.barcode ?? '',
              write: (draft, value) =>
                  _writeNullable(draft, 'barcode', _nullable(value)),
            ),
            LibraryDateFieldSpec<TDraft>(
              id: 'release_date',
              label: 'Release Date',
              value: (draft) => draft.metadata.releaseDateParts?.asDateTime,
              setValue: (draft, value) {
                final partialDate =
                    value == null ? null : PartialDate.fromDateTime(value);
                _writeNullableFields(draft, {
                  'release_date': partialDate?.isoString,
                  'release_date_parts': partialDate?.toJson(),
                });
              },
            ),
            _number<TDraft>(
              id: 'nr_discs',
              label: 'Disc count',
              read: (metadata) => metadata.nrDiscs,
              write: (draft, value) => draft.metadata =
                  draft.metadata.copyWith(nrDiscs: value?.toInt()),
            ),
            _text<TDraft>(
              id: 'audio_tracks',
              label: 'Audio languages',
              read: (metadata) => metadata.audioTracks ?? '',
              write: (draft, value) =>
                  _writeNullable(draft, 'audio_tracks', _nullable(value)),
            ),
            _text<TDraft>(
              id: 'subtitles',
              label: 'Subtitle languages',
              read: (metadata) => metadata.subtitles ?? '',
              write: (draft, value) =>
                  _writeNullable(draft, 'subtitles', _nullable(value)),
            ),
            _text<TDraft>(
              id: 'screen_ratio',
              label: 'Screen ratio',
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
            _text<TDraft>(
              id: 'description',
              label: 'Description',
              read: (metadata) => metadata.description ?? '',
              write: (draft, value) =>
                  _writeNullable(draft, 'description', _nullable(value)),
              maxLines: 4,
            ),
            _text<TDraft>(
              id: 'variant_name',
              label: 'Variant',
              read: (metadata) => metadata.variant ?? '',
              write: (draft, value) =>
                  _writeNullable(draft, 'variant_name', _nullable(value)),
            ),
            _vocabulary<TDraft>(
              id: 'region',
              label: 'Region',
              read: _region,
              write: (draft, value) =>
                  draft.metadata = _withRegion(draft.metadata, value),
              options: regionOptions ?? AnimeVocabularies.region.builtIns,
              pickListKey: AnimeVocabularyIds.region.value,
              onManage: onManageRegion,
            ),
          ],
        ),
        LibraryFormSectionSpec<TDraft>(
          id: 'titles_and_people',
          label: 'Titles and people',
          fields: [
            _text<TDraft>(
              id: 'native_title',
              label: 'Native title',
              read: (metadata) => metadata.nativeTitle ?? '',
              write: (draft, value) =>
                  _writeNullable(draft, 'native_title', _nullable(value)),
            ),
            _text<TDraft>(
              id: 'romaji_title',
              label: 'Romaji title',
              read: (metadata) => metadata.romajiTitle ?? '',
              write: (draft, value) =>
                  _writeNullable(draft, 'romaji_title', _nullable(value)),
            ),
            _text<TDraft>(
              id: 'english_title',
              label: 'English title',
              read: (metadata) => metadata.englishTitle ?? '',
              write: (draft, value) =>
                  _writeNullable(draft, 'english_title', _nullable(value)),
            ),
            _text<TDraft>(
              id: 'alternate_titles',
              label: 'Alternate titles',
              read: (metadata) => metadata.alternateTitles.join(', '),
              write: (draft, value) => draft.metadata =
                  draft.metadata.copyWith(alternateTitles: _split(value)),
            ),
            _text<TDraft>(
              id: 'country',
              label: 'Country',
              read: (metadata) => metadata.country,
              write: (draft, value) =>
                  draft.metadata = draft.metadata.copyWith(country: value),
            ),
            _text<TDraft>(
              id: 'characters',
              label: 'Characters',
              read: (metadata) => metadata.characters
                  .map((character) => character.name)
                  .join(', '),
              write: (draft, value) => draft.metadata = draft.metadata.copyWith(
                characters: _charactersFromNames(
                  value,
                  draft.characterBaseline,
                ),
              ),
            ),
          ],
        ),
      ]),
    );

List<LibraryFormSectionSpec<TDraft>>
    _filterSections<TDraft extends AnimeCatalogFormDraft>(
  Set<String>? fieldIds,
  String? sectionLabel,
  List<LibraryFormSectionSpec<TDraft>> sections,
) {
  if (fieldIds == null && sectionLabel == null) return sections;
  return [
    for (final section in sections)
      if (section.fields
          .where((field) => fieldIds == null || fieldIds.contains(field.id))
          .isNotEmpty)
        LibraryFormSectionSpec<TDraft>(
          id: section.id,
          label: sectionLabel ?? section.label,
          fields: [
            for (final field in section.fields)
              if (fieldIds == null || fieldIds.contains(field.id)) field,
          ],
          maxColumns: section.maxColumns,
          fullWidthFieldIds: section.fullWidthFieldIds,
          fieldColumnSpans: section.fieldColumnSpans,
          rightAlignedFieldIds: section.rightAlignedFieldIds,
          visibleWhen: section.visibleWhen,
        ),
  ];
}

LibraryTextFieldSpec<TDraft> _text<TDraft extends AnimeCatalogFormDraft>({
  required String id,
  required String label,
  required String Function(AnimeMetadata metadata) read,
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

LibraryNumberFieldSpec<TDraft> _number<TDraft extends AnimeCatalogFormDraft>({
  required String id,
  required String label,
  required num? Function(AnimeMetadata metadata) read,
  required void Function(TDraft draft, num? value) write,
}) =>
    LibraryNumberFieldSpec<TDraft>(
      id: id,
      label: label,
      value: (draft) => read(draft.metadata),
      setValue: write,
      minimum: 0,
    );

LibraryVocabularyFieldSpec<TDraft, String>
    _vocabulary<TDraft extends AnimeCatalogFormDraft>({
  required String id,
  required String label,
  required String Function(AnimeMetadata metadata) read,
  required void Function(TDraft draft, String? value) write,
  required Iterable<String> options,
  String? pickListKey,
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
          pickListKey: pickListKey,
          onManage: onManage == null ? null : (_) => onManage(),
        );

AnimeSeason? _animeSeason(String? value) {
  final normalized = value?.trim().toLowerCase();
  for (final season in AnimeSeason.values) {
    if (season.name == normalized || season.label.toLowerCase() == normalized) {
      return season;
    }
  }
  return null;
}

void _writeNullable<TDraft extends AnimeCatalogFormDraft>(
  TDraft draft,
  String key,
  Object? value,
) =>
    _writeNullableFields(draft, {key: value});

void _writeNullableFields<TDraft extends AnimeCatalogFormDraft>(
  TDraft draft,
  Map<String, Object?> fields,
) {
  final payload = Map<String, dynamic>.from(draft.metadata.toJson())
    ..addAll(fields);
  draft.metadata = AnimeMetadata.fromJson(payload);
}

String _region(AnimeMetadata metadata) {
  for (final media in metadata.media) {
    if (media.position == 0) return media.regionCode ?? '';
  }
  return '';
}

AnimeMetadata _withRegion(AnimeMetadata metadata, String? value) {
  final normalized = _nullable(value ?? '');
  final media = [...metadata.media];
  final index = media.indexWhere((item) => item.position == 0);
  if (index == -1) {
    if (normalized != null) {
      media.add(AnimeMediaMetadata(position: 0, regionCode: normalized));
    }
  } else {
    final current = media[index];
    final updated = AnimeMediaMetadata(
      position: current.position,
      id: current.id,
      mediaNumber: current.mediaNumber,
      mediaType: current.mediaType,
      title: current.title,
      episodeCount: current.episodeCount,
      runtimeMinutes: current.runtimeMinutes,
      regionCode: normalized,
      encoding: current.encoding,
      aspectRatio: current.aspectRatio,
      audioTracks: current.audioTracks,
      subtitles: current.subtitles,
      resolution: current.resolution,
      hdrFormat: current.hdrFormat,
    );
    if (normalized == null &&
        current.id == null &&
        current.mediaNumber == null &&
        current.mediaType == null &&
        current.title == null &&
        current.episodeCount == null &&
        current.runtimeMinutes == null &&
        current.encoding == null &&
        current.aspectRatio == null &&
        current.audioTracks == null &&
        current.subtitles == null &&
        current.resolution == null &&
        current.hdrFormat == null) {
      media.removeAt(index);
    } else {
      media[index] = updated;
    }
  }
  media.sort((left, right) => left.position.compareTo(right.position));
  return metadata.copyWith(media: media);
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

List<AnimeCharacterMetadata> _charactersFromNames(
  String value,
  List<AnimeCharacterMetadata> existing,
) {
  final byName = {
    for (final character in existing)
      character.name.trim().toLowerCase(): character,
  };
  final characters = <AnimeCharacterMetadata>[];
  for (final name in _split(value)) {
    final previous = byName.remove(name.toLowerCase());
    characters.add(
      previous == null
          ? AnimeCharacterMetadata(name: name)
          : AnimeCharacterMetadata(
              name: name,
              id: previous.id,
              characterId: previous.characterId,
              aliases: previous.aliases,
              role: previous.role,
              description: previous.description,
              imageUrl: previous.imageUrl,
              stringValue: previous.stringValue,
            ),
    );
  }
  return characters;
}
