import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/music/tracking/music_tracking_profile.dart';
import 'package:flutter/material.dart';

final EditSchema<MusicRelease, MusicReleaseEditDraft> musicReleaseEditSchema =
    EditSchema(
  title: (release) => 'Edit ${release.title}',
  validate: (_, draft) {
    if (draft.values.title.trim().isEmpty) return 'Title is required';
    if (draft.hasIncompleteContributions) {
      return 'Complete or remove each unfinished release credit';
    }
    return null;
  },
  tabs: [
    EditTabSpec<MusicReleaseEditDraft>(
      id: 'release',
      label: 'Release',
      icon: Icons.album_outlined,
      sections: [
        EditSectionSpec<MusicReleaseEditDraft>(
          id: 'identity',
          label: 'Identity',
          fields: musicReleaseFields(
            values: (draft) => draft.values,
            include: {
              'title',
              'sort_title',
              'subtitle',
              'format',
              'release_type',
              'release_status',
              'release_date',
            },
          ),
        ),
        EditSectionSpec<MusicReleaseEditDraft>(
          id: 'edition',
          label: 'Edition',
          fields: musicReleaseFields(
            values: (draft) => draft.values,
            include: {
              'record_label',
              'catalog_number',
              'barcode',
              'upc',
              'country',
              'language',
              'packaging',
              'box_set_ref',
              'box_set_name',
              'box_set_position',
            },
          ),
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
            LibraryVocabularyFieldSpec<MusicReleaseEditDraft, String>(
              id: 'tracking_status',
              label: 'Status',
              value: (draft) => draft.trackingStatus,
              setValue: (draft, value) => draft.trackingStatus = value,
              options: [
                for (final option in musicTrackingProfile.options)
                  LibraryFieldOption(
                    value: option.storageValue,
                    label: option.label,
                  ),
              ],
            ),
            LibraryNumberFieldSpec<MusicReleaseEditDraft>(
              id: 'tracking_rating',
              label: 'Rating',
              value: (draft) => draft.trackingRating,
              setValue: (draft, value) => draft.trackingRating = value?.toInt(),
              minimum: 0,
              maximum: 5,
            ),
            LibraryTextFieldSpec<MusicReleaseEditDraft>(
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
