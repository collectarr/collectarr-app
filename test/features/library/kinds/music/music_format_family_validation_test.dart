import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_contents.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc_format_family.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_schema.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('edit and manual add block custom formats without an explicit family',
      () {
    final album = MusicAlbum(
      id: const CatalogItemRef(kind: CatalogMediaKind.music, id: 'album-1'),
      title: 'Album',
      discs: [
        MusicDisc(
          id: const MusicDiscId('disc-1'),
          discNumber: 1,
          format: 'custom silver disc',
        ),
      ],
    );
    final editDraft = MusicAlbumEditDraft.fromAlbum(album);
    expect(
      musicAlbumEditSchema.validate!(album, editDraft),
      'Choose a family for each custom disc format',
    );
    editDraft.discList.updateDiscFormatFamily(
      const MusicDiscId('disc-1'),
      MusicDiscFormatFamily.other,
    );
    expect(musicAlbumEditSchema.validate!(album, editDraft), isNull);

    final addDraft = MusicAddManualDraft(
      catalogTitle: 'Album',
      discs: [
        MusicAddManualDisc(format: 'custom silver disc'),
      ],
    );
    expect(
      musicAddSchema.validate!(addDraft),
      'Choose a family for each custom disc format',
    );
    addDraft.discs.single.formatFamily = MusicDiscFormatFamily.other;
    expect(musicAddSchema.validate!(addDraft), isNull);
  });
}
