import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_edit_header_title.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/music/tracking/music_tracking_profile.dart';
import 'package:flutter/material.dart';

final EditSchema<MusicRelease, MusicReleaseEditDraft> musicReleaseEditSchema =
    EditSchema(
  title: (item) {
    return musicEditHeaderTitle(title: item.title, artist: item.artist);
  },
  validate: (_, draft) {
    if (draft.values.title.trim().isEmpty) return 'Title is required';
    if (draft.hasIncompleteContributions) {
      return 'Complete or remove each unfinished music credit';
    }
    return null;
  },
  tabs: [
    EditTabSpec<MusicReleaseEditDraft>(
      id: 'main',
      label: 'Main',
      icon: Icons.music_note_outlined,
      sections: [
        EditSectionSpec<MusicReleaseEditDraft>(
          id: 'catalog_item',
          label: 'Catalog Item',
          maxColumns: 3,
          fullWidthFieldIds: const {'genres'},
          fields: _fields([
            'title',
            'release_date',
            'original_release_date',
            'sort_title',
            'record_label',
            'recording_date',
            'subtitle',
            'format',
            'barcode',
            'artist',
            'catalog_number',
            'genres',
          ]),
        ),
      ],
    ),
    EditTabSpec<MusicReleaseEditDraft>(
      id: 'details',
      label: 'Details',
      icon: Icons.info_outline,
      sections: [
        EditSectionSpec<MusicReleaseEditDraft>(
          id: 'additional_details',
          label: 'Additional details',
          fields: _fields([
            'original_title',
            'is_live',
            'studios',
            'country',
            'language',
            'release_type',
            'release_status',
            'packaging',
            'box_set_ref',
            'box_set_name',
            'box_set_position',
            'upc',
            'cover_image_url',
            'sound_types',
            'vinyl_color',
            'vinyl_weight',
            'rpm',
            'extra',
            'spars',
          ]),
        ),
      ],
    ),
    EditTabSpec<MusicReleaseEditDraft>(
      id: 'personal',
      label: 'Personal',
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
              value: (draft) => draft.trackingRating?.toDouble(),
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

List<LibraryFieldSpec<MusicReleaseEditDraft>> _fields(List<String> ids) {
  final all = musicReleaseFields<MusicReleaseEditDraft>(
    values: (draft) => draft.values,
  );
  final fieldsById = {for (final field in all) field.id: field};
  return [for (final id in ids) fieldsById[id]!];
}
