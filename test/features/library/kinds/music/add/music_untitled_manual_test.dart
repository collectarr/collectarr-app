import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_manual_candidate.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_album_edit_schema.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a manual album can be added and edited with no title', () {
    final candidate =
        buildMusicManualCandidate(MusicAddManualDraft(), title: '');
    expect(candidate, isNotNull);
    expect(candidate!.summary.primaryLabel, isEmpty);

    final album = MusicAlbum(
        id: const CatalogItemRef(kind: CatalogMediaKind.music, id: 'manual-1'),
        title: '');
    expect(
        musicAlbumEditSchema.validate!(
            album, MusicAlbumEditDraft.fromAlbum(album)),
        isNull);
  });
}
