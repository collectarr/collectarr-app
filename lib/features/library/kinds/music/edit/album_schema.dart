import 'package:collectarr_app/features/library/kinds/music/forms/main_form_section.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/album_details_pane.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/header_title.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/album_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/catalog_field_specs.dart';
import 'package:collectarr_app/ui/app_icons.dart';

final EditSchema<MusicAlbum, MusicAlbumEditDraft> musicAlbumEditSchema =
    EditSchema(
  title: (item) {
    return musicEditHeaderTitle(title: item.title, artist: item.artist);
  },
  validate: (_, draft) {
    if (draft.discList.hasUnclassifiedFormat) {
      return 'Choose a family for each custom disc format';
    }
    return null;
  },
  tabs: [
    EditTabSpec<MusicAlbumEditDraft>(
      id: 'main',
      label: 'Main',
      icon: AppIcons.tabMain,
      sections: [
        musicMainFormSection<MusicAlbumEditDraft>(
          fields: musicAlbumFields<MusicAlbumEditDraft>(
              values: (draft) => draft.values),
        ),
      ],
    ),
    EditTabSpec<MusicAlbumEditDraft>(
      id: 'details',
      label: 'Details',
      icon: AppIcons.tabDetails,
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
