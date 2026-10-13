import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_data.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../helpers/test_data_factories.dart';

void main() {
  test('search scopes isolate album and contained track facts', () {
    final type = defaultLibraryKindRegistry.require(CatalogMediaKind.music);
    final album = MusicAlbum(
      id: const CatalogItemRef(kind: CatalogMediaKind.music, id: 'album'),
      title: 'Album Only',
      discs: [
        MusicDisc(id: const MusicDiscId('disc'), discNumber: 1, tracks: [
          MusicTrack(
              id: const MusicTrackId('track'),
              position: '1',
              title: 'First Song',
              artist: 'Guest Artist',
              composition: 'Work Title'),
        ])
      ],
    );
    final shelf = ShelfState(
        entries: [
          testLibraryWorkspaceSource(
            itemId: 'album',
            kind: 'music',
            title: album.title,
            catalogData: MusicWorkspaceData.fromMusic(album),
          )
        ],
        entryCount: 1,
        wishlistCount: 0,
        pricedCount: 0,
        totalPaidCents: null,
        primaryCurrency: null,
        hasMixedCurrencies: false);
    final engine = LibraryProjectionEngine();
    int search(String query, LibrarySearchTarget target) => engine
        .execute(
          shelf: shelf,
          type: type,
          viewState: libraryViewProfileForKind(type.kind).defaults(),
          query: LibraryProjectionQuery(searchQuery: query),
          searchTarget: target,
        )
        .filteredItems
        .length;
    for (final query in ['First Song', 'Guest Artist', 'Work Title']) {
      expect(search(query, LibrarySearchTarget.tracksOnly), 1);
      expect(search(query, LibrarySearchTarget.all), 1);
    }
    expect(search('First Song', LibrarySearchTarget.mediaOnly), 0);
    expect(search('Album Only', LibrarySearchTarget.tracksOnly), 0);
    expect(search('Album Only', LibrarySearchTarget.mediaOnly), 1);
    expect(search('', LibrarySearchTarget.tracksOnly), 1);
  });
}
