import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_group_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_catalog_field_specs.dart';
import 'package:flutter/material.dart';

final EditSchema<MusicReleaseGroup, MusicReleaseGroupEditDraft>
    musicReleaseGroupEditSchema = EditSchema(
  title: (group) => 'Edit ${group.title}',
  validate: (_, draft) {
    if (draft.values.title.trim().isEmpty) {
      return 'Release group title is required';
    }
    return null;
  },
  tabs: [
    EditTabSpec<MusicReleaseGroupEditDraft>(
      id: 'release_group',
      label: 'Release group',
      icon: Icons.music_note_outlined,
      sections: [
        EditSectionSpec<MusicReleaseGroupEditDraft>(
          id: 'identity',
          label: 'Identity',
          fields: musicReleaseGroupFields(
            values: (draft) => draft.values,
            include: {
              'title',
              'sort_title',
              'artist',
              'original_title',
              'is_live',
            },
          ),
        ),
        EditSectionSpec<MusicReleaseGroupEditDraft>(
          id: 'recording',
          label: 'Recording',
          fields: musicReleaseGroupFields(
            values: (draft) => draft.values,
            include: {
              'original_release_date',
              'recording_date',
              'studio',
              'genres',
            },
          ),
        ),
      ],
    ),
  ],
);
