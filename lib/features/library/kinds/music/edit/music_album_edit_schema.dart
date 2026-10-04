import 'package:collectarr_app/features/library/kinds/music/edit/music_album_details_pane.dart';
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
    return null;
  },
  tabs: [
    EditTabSpec<MusicAlbumEditDraft>(
      id: 'main',
      label: 'Main',
      icon: Icons.music_note_outlined,
      sections: [
        LibraryFormSectionSpec<MusicAlbumEditDraft>(
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
        LibraryFormSectionSpec<MusicAlbumEditDraft>(
          id: 'details_layout',
          label: '',
          maxColumns: 1,
          fields: [
            LibraryCustomFieldSpec<MusicAlbumEditDraft>(
              id: 'music_details',
              label: '',
              builder: (context, draft) => MusicAlbumDetailsPane(draft: draft),
            )
          ],
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
