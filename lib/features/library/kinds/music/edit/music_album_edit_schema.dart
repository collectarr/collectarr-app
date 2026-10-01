import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_edit_header_title.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_catalog_field_specs.dart';
import 'package:flutter/material.dart';

final EditSchema<MusicAlbum, MusicAlbumEditDraft> musicAlbumEditSchema =
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
    EditTabSpec<MusicAlbumEditDraft>(
      id: 'main',
      label: 'Main',
      icon: Icons.music_note_outlined,
      sections: [
        EditSectionSpec<MusicAlbumEditDraft>(
          id: 'catalog_item',
          label: '',
          maxColumns: 4,
          fieldColumnSpans: const {
            'title': 2,
            'sort_title': 2,
            'subtitle': 2,
            'artist': 2,
            'catalog_number': 2,
            'genres': 2,
          },
          rightAlignedFieldIds: const {'genres'},
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
    EditTabSpec<MusicAlbumEditDraft>(
      id: 'details',
      label: 'Details',
      icon: Icons.info_outline,
      sections: [
        EditSectionSpec<MusicAlbumEditDraft>(
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
  ],
);

List<LibraryFieldSpec<MusicAlbumEditDraft>> _fields(List<String> ids) {
  final all = musicAlbumFields<MusicAlbumEditDraft>(
    values: (draft) => draft.values,
  );
  final fieldsById = {for (final field in all) field.id: field};
  return [for (final id in ids) fieldsById[id]!];
}
