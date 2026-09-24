import 'dart:async';

import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/kinds/anime/add/anime_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/forms/anime_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/anime/vocabulary/anime_vocabularies.dart';

final AddSchema<AnimeAddManualDraft> animeAddSchema = animeAddSchemaFor();

AddSchema<AnimeAddManualDraft> animeAddSchemaFor({
  Iterable<String>? formatOptions,
  Iterable<String>? seasonOptions,
  Iterable<String>? airingStatusOptions,
  Iterable<String>? sourceMaterialOptions,
  Iterable<String>? physicalFormatOptions,
  Iterable<String>? regionOptions,
  Iterable<String>? distributorOptions,
  FutureOr<void> Function()? onManageFormat,
  FutureOr<void> Function()? onManageSeason,
  FutureOr<void> Function()? onManagePhysicalFormat,
  FutureOr<void> Function()? onManageRegion,
  FutureOr<void> Function()? onManageDistributor,
}) =>
    AddSchema<AnimeAddManualDraft>(
      title: (_) => 'Manual anime',
      validate: (draft) {
        final media = draft.media;
        final release = draft.release;
        if (media.seasonYear != null && media.seasonYear! < 0) {
          return 'Season year cannot be negative';
        }
        if (media.episodeCount != null && media.episodeCount! < 0) {
          return 'Episode count cannot be negative';
        }
        if (media.episodeRuntimeMinutes != null &&
            media.episodeRuntimeMinutes! < 0) {
          return 'Episode runtime cannot be negative';
        }
        if (media.startDate != null &&
            media.endDate != null &&
            media.endDate!.isBefore(media.startDate!)) {
          return 'End date cannot be before start date';
        }
        if (release.mediaCount != null && release.mediaCount! < 0) {
          return 'Media count cannot be negative';
        }
        return null;
      },
      sections: [
        AddSectionSpec<AnimeAddManualDraft>(
          id: 'series',
          label: 'Series',
          fields: [
            ...animeMediaIdentityFields(
              values: (draft) => draft.media,
              includeTitle: false,
            ),
            ...animeMediaClassificationFields(
              values: (draft) => draft.media,
              formatOptions: formatOptions ?? AnimeVocabularies.format.builtIns,
              seasonOptions: seasonOptions ?? AnimeVocabularies.season.builtIns,
              sourceMaterialOptions: sourceMaterialOptions,
              onManageFormat: onManageFormat,
              onManageSeason: onManageSeason,
            ),
            ...animeMediaProductionFields(
              values: (draft) => draft.media,
              airingStatusOptions: airingStatusOptions,
            ),
            ...animeMediaScheduleFields(values: (draft) => draft.media),
          ],
        ),
        AddSectionSpec<AnimeAddManualDraft>(
          id: 'release',
          label: 'Release',
          fields: [
            ...animeReleaseIdentityFields(
              values: (draft) => draft.release,
              formatOptions: physicalFormatOptions ??
                  AnimeVocabularies.physicalFormat.builtIns,
              regionOptions: regionOptions ?? AnimeVocabularies.region.builtIns,
              onManageFormat: onManagePhysicalFormat,
              onManageRegion: onManageRegion,
            ),
            ...animeReleasePublishingFields(
              values: (draft) => draft.release,
            ),
            ..._releaseExtraFields(
              distributorOptions:
                  distributorOptions ?? AnimeVocabularies.distributor.builtIns,
              onManageDistributor: onManageDistributor,
            ),
          ],
        ),
        AddSectionSpec<AnimeAddManualDraft>(
          id: 'metadata',
          label: 'Metadata',
          fields: _extraMediaFields(),
        ),
      ],
    );

List<LibraryFieldSpec<AnimeAddManualDraft>> _releaseExtraFields({
  required Iterable<String> distributorOptions,
  FutureOr<void> Function()? onManageDistributor,
}) =>
    [
      LibraryVocabularyFieldSpec<AnimeAddManualDraft, String>(
        id: 'distributor',
        label: 'Distributor',
        value: (draft) => _nullable(draft.release.distributor),
        setValue: (draft, value) => draft.release.distributor = value ?? '',
        options: [
          for (final value in distributorOptions)
            LibraryFieldOption(value: value, label: value),
        ],
        onManage:
            onManageDistributor == null ? null : (_) => onManageDistributor(),
      ),
      LibraryTextFieldSpec<AnimeAddManualDraft>(
        id: 'variant',
        label: 'Variant',
        value: (draft) => draft.release.variant,
        setValue: (draft, value) => draft.release.variant = value,
      ),
    ];

List<LibraryFieldSpec<AnimeAddManualDraft>> _extraMediaFields() => [
      for (final entry in [
        (id: 'native_title', label: 'Native title'),
        (id: 'romaji_title', label: 'Romaji title'),
        (id: 'english_title', label: 'English title'),
        (id: 'alternate_titles', label: 'Alternate titles'),
      ])
        LibraryTextFieldSpec<AnimeAddManualDraft>(
          id: entry.id,
          label: entry.label,
          value: (draft) => switch (entry.id) {
            'native_title' => draft.media.nativeTitle,
            'romaji_title' => draft.media.romajiTitle,
            'english_title' => draft.media.englishTitle,
            _ => draft.media.alternateTitles.join(', '),
          },
          setValue: (draft, value) {
            switch (entry.id) {
              case 'native_title':
                draft.media.nativeTitle = value;
                break;
              case 'romaji_title':
                draft.media.romajiTitle = value;
                break;
              case 'english_title':
                draft.media.englishTitle = value;
                break;
              case 'alternate_titles':
                draft.media.alternateTitles = _split(value);
                break;
            }
          },
        ),
      LibraryTextFieldSpec<AnimeAddManualDraft>(
        id: 'country',
        label: 'Country',
        value: (draft) => draft.media.country,
        setValue: (draft, value) => draft.media.country = value,
      ),
      LibraryTextFieldSpec<AnimeAddManualDraft>(
        id: 'creators',
        label: 'Creators',
        value: (draft) => draft.media.creators.join(', '),
        setValue: (draft, value) => draft.media.creators = _split(value),
      ),
      LibraryTextFieldSpec<AnimeAddManualDraft>(
        id: 'characters',
        label: 'Characters',
        value: (draft) => draft.media.characters.join(', '),
        setValue: (draft, value) => draft.media.characters = _split(value),
      ),
    ];

List<String> _split(String value) => value
    .split(RegExp(r'[,\r\n]+'))
    .map((entry) => entry.trim())
    .where((entry) => entry.isNotEmpty)
    .toSet()
    .toList(growable: false);

String? _nullable(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
