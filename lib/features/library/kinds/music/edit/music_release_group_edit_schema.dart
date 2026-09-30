import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_release_group_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_catalog_field_specs.dart';
import 'package:flutter/material.dart';

final EditSchema<MusicReleaseGroup, MusicReleaseGroupEditDraft>
    musicReleaseGroupEditSchema = EditSchema(
  title: (group) {
    final artist = group.artist?.trim();
    return artist == null || artist.isEmpty
        ? group.title
        : '${group.title} / $artist';
  },
  validate: (_, draft) {
    if (draft.values.title.trim().isEmpty) {
      return 'Album title is required';
    }
    return null;
  },
  tabs: [
    EditTabSpec<MusicReleaseGroupEditDraft>(
      id: 'album',
      label: 'Album',
      icon: Icons.music_note_outlined,
      sections: [
        EditSectionSpec<MusicReleaseGroupEditDraft>(
          id: 'album',
          label: 'Album',
          fields: _mainAlbumFields,
        ),
        EditSectionSpec<MusicReleaseGroupEditDraft>(
          id: 'additional_details',
          label: 'Additional details',
          fields: musicReleaseGroupFields(
            values: (draft) => draft.values,
            include: {
              'original_title',
              'is_live',
              'studios',
            },
          ),
        ),
        EditSectionSpec<MusicReleaseGroupEditDraft>(
          id: 'edition_details',
          label: 'Edition details',
          visibleWhen: (draft) => draft.original.primaryRelease != null,
          fields: musicReleaseFields(
            values: (draft) => draft.releaseValues,
            include: {
              'country',
              'packaging',
              'language',
              'box_set_ref',
              'box_set_name',
              'box_set_position',
              'upc',
            },
          ),
        ),
      ],
    ),
  ],
);

final _mainAlbumFields = _orderedFields();

List<LibraryFieldSpec<MusicReleaseGroupEditDraft>> _orderedFields() {
  final groupFields = musicReleaseGroupFields<MusicReleaseGroupEditDraft>(
    values: (draft) => draft.values,
  );
  final releaseFields = musicReleaseFields<MusicReleaseGroupEditDraft>(
    values: (draft) => draft.releaseValues,
  );
  LibraryFieldSpec<MusicReleaseGroupEditDraft> find(
    List<LibraryFieldSpec<MusicReleaseGroupEditDraft>> fields,
    String id,
  ) =>
      fields.firstWhere((field) => field.id == id);

  return [
    find(groupFields, 'title'),
    find(groupFields, 'sort_title'),
    find(releaseFields, 'subtitle'),
    find(groupFields, 'artist'),
    find(releaseFields, 'release_date'),
    find(groupFields, 'original_release_date'),
    find(releaseFields, 'record_label'),
    find(groupFields, 'recording_date'),
    find(releaseFields, 'format'),
    find(releaseFields, 'barcode'),
    find(releaseFields, 'catalog_number'),
    find(groupFields, 'genres'),
  ];
}
