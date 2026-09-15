import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/music/tracking/music_tracking_profile.dart';
import 'package:flutter/material.dart';

final EditSchema<MusicRelease, MusicReleaseEditDraft> musicReleaseEditSchema =
    EditSchema(
  title: (release) => 'Edit ${release.title}',
  validate: (_, draft) =>
      draft.title.trim().isEmpty ? 'Release title is required' : null,
  tabs: [
    EditTabSpec<MusicReleaseEditDraft>(
      id: 'release',
      label: 'Release',
      sections: [
        EditSectionSpec<MusicReleaseEditDraft>(
          id: 'identity',
          label: 'Identity',
          fields: [
            _text(
                id: 'title',
                label: 'Title',
                value: (draft) => draft.title,
                setValue: (draft, value) => draft.title = value),
            _text(
                id: 'sort_title',
                label: 'Sort title',
                value: (draft) => draft.sortTitle ?? '',
                setValue: (draft, value) => draft.sortTitle = value),
            _text(
                id: 'subtitle',
                label: 'Subtitle',
                value: (draft) => draft.subtitle ?? '',
                setValue: (draft, value) => draft.subtitle = value),
            VocabularyEditField<MusicReleaseEditDraft, String>(
              id: 'release_type',
              label: 'Release type',
              value: (draft) => draft.releaseType,
              setValue: (draft, value) => draft.releaseType = value,
              options: _options(
                  const ['Album', 'EP', 'Single', 'Compilation', 'Live']),
            ),
            VocabularyEditField<MusicReleaseEditDraft, String>(
              id: 'release_status',
              label: 'Release status',
              value: (draft) => draft.releaseStatus,
              setValue: (draft, value) => draft.releaseStatus = value,
              options: _options(const ['Official', 'Promotional', 'Bootleg']),
            ),
            DateEditField<MusicReleaseEditDraft>(
              id: 'release_date',
              label: 'Release date',
              value: (draft) => draft.releaseDate,
              setValue: (draft, value) => draft.releaseDate = value,
            ),
          ],
        ),
        EditSectionSpec<MusicReleaseEditDraft>(
          id: 'edition',
          label: 'Edition',
          fields: [
            _text(
                id: 'publisher',
                label: 'Record label',
                value: (draft) => draft.publisher ?? '',
                setValue: (draft, value) => draft.publisher = value),
            _text(
                id: 'catalog_number',
                label: 'Catalog number',
                value: (draft) => draft.catalogNumber ?? '',
                setValue: (draft, value) => draft.catalogNumber = value),
            _text(
                id: 'barcode',
                label: 'Barcode',
                value: (draft) => draft.barcode ?? '',
                setValue: (draft, value) => draft.barcode = value),
            _text(
                id: 'upc',
                label: 'UPC',
                value: (draft) => draft.upc ?? '',
                setValue: (draft, value) => draft.upc = value),
            VocabularyEditField<MusicReleaseEditDraft, String>(
              id: 'country_code',
              label: 'Country',
              value: (draft) => draft.countryCode,
              setValue: (draft, value) => draft.countryCode = value,
              options: _options(MusicVocabularies.country.builtIns),
            ),
            _text(
                id: 'language',
                label: 'Language',
                value: (draft) => draft.language ?? '',
                setValue: (draft, value) => draft.language = value),
            _text(
                id: 'packaging',
                label: 'Packaging',
                value: (draft) => draft.packaging ?? '',
                setValue: (draft, value) => draft.packaging = value),
            _text(
                id: 'cover_image_url',
                label: 'Cover image URL',
                value: (draft) => draft.coverImageUrl ?? '',
                setValue: (draft, value) => draft.coverImageUrl = value),
          ],
        ),
      ],
    ),
    EditTabSpec<MusicReleaseEditDraft>(
      id: 'tracking',
      label: 'Tracking',
      icon: Icons.headphones_outlined,
      sections: [
        EditSectionSpec<MusicReleaseEditDraft>(
          id: 'listening',
          label: 'Listening',
          fields: [
            VocabularyEditField<MusicReleaseEditDraft, String>(
              id: 'tracking_status',
              label: 'Status',
              value: (draft) => draft.trackingStatus,
              setValue: (draft, value) => draft.trackingStatus = value,
              options: [
                for (final option in musicTrackingProfile.options)
                  EditOption(
                    value: option.storageValue,
                    label: option.label,
                  ),
              ],
            ),
            NumberEditField<MusicReleaseEditDraft>(
              id: 'tracking_rating',
              label: 'Rating',
              value: (draft) => draft.trackingRating,
              setValue: (draft, value) => draft.trackingRating = value?.toInt(),
              minimum: 0,
              maximum: 5,
            ),
            NumberEditField<MusicReleaseEditDraft>(
              id: 'tracking_progress_current',
              label: 'Progress',
              value: (draft) => draft.trackingProgressCurrent,
              setValue: (draft, value) =>
                  draft.trackingProgressCurrent = value?.toInt(),
              minimum: 0,
            ),
            NumberEditField<MusicReleaseEditDraft>(
              id: 'tracking_progress_total',
              label: 'Progress total',
              value: (draft) => draft.trackingProgressTotal,
              setValue: (draft, value) =>
                  draft.trackingProgressTotal = value?.toInt(),
              minimum: 0,
            ),
            NumberEditField<MusicReleaseEditDraft>(
              id: 'tracking_times_completed',
              label: 'Times completed',
              value: (draft) => draft.trackingTimesCompleted,
              setValue: (draft, value) =>
                  draft.trackingTimesCompleted = value?.toInt(),
              minimum: 0,
            ),
            DateEditField<MusicReleaseEditDraft>(
              id: 'tracking_started_at',
              label: 'Started',
              value: (draft) => draft.trackingStartedAt,
              setValue: (draft, value) => draft.trackingStartedAt = value,
            ),
            DateEditField<MusicReleaseEditDraft>(
              id: 'tracking_finished_at',
              label: 'Finished',
              value: (draft) => draft.trackingFinishedAt,
              setValue: (draft, value) => draft.trackingFinishedAt = value,
            ),
            _text(
              id: 'tracking_notes',
              label: 'Notes',
              value: (draft) => draft.trackingNotes ?? '',
              setValue: (draft, value) => draft.trackingNotes = value,
              maxLines: 3,
            ),
          ],
        ),
      ],
    ),
  ],
);

TextEditField<MusicReleaseEditDraft> _text({
  required String id,
  required String label,
  required String Function(MusicReleaseEditDraft draft) value,
  required void Function(MusicReleaseEditDraft draft, String value) setValue,
  int maxLines = 1,
}) =>
    TextEditField(
      id: id,
      label: label,
      value: value,
      setValue: setValue,
      maxLines: maxLines,
    );

List<EditOption<String>> _options(Iterable<String> values) => [
      for (final value in values) EditOption(value: value, label: value),
    ];
