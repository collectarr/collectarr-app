import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/library/domain/library_target_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_artist_credit.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_data.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/sorts/music_workspace_sorts.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_projection_context.dart';
import 'package:flutter_test/flutter_test.dart';

LibraryProjectionContext<MusicWorkspaceProjection> _context(
  MusicAlbum album, {
  LibrarySortingOptions sorting = const LibrarySortingOptions(),
}) {
  final item = WorkspaceItem(
    target: CatalogTargetRef(
        CatalogItemRef(kind: CatalogMediaKind.music, id: album.title)),
    kindPresentationData: MusicWorkspaceData.fromMusic(album),
  );
  const personal = PersonalOverlay();
  return LibraryProjectionContext(
    item: item,
    personal: personal,
    dto: const MusicLibraryEntryWorkspaceProjector()
        .project(item: item, personal: personal),
    sorting: sorting,
  );
}

void main() {
  test('title order follows sort titles unless Settings ignores them', () {
    final sort = musicTitleSort();
    final wall = MusicAlbum(title: 'The Wall', sortTitle: 'Wall, The');
    final vanilla = MusicAlbum(title: 'Vanilla');
    const ignore = LibrarySortingOptions(useSortTitles: false);

    expect(sort.compare(_context(vanilla), _context(wall)), lessThan(0));
    expect(
      sort.compare(
          _context(vanilla, sorting: ignore), _context(wall, sorting: ignore)),
      greaterThan(0),
    );
  });

  test('artist order follows sort names unless Settings ignores them', () {
    final sort = musicArtistSort();
    final adams = MusicAlbum(
      title: 'Reckless',
      artist: 'Bryan Adams',
      artistCredits: const [
        MusicArtistCredit(
            id: 'a',
            creditedName: 'Bryan Adams',
            sortName: 'Adams, Bryan',
            sequence: 1),
      ],
    );
    final joel = MusicAlbum(
      title: 'The Stranger',
      artist: 'Billy Joel',
      artistCredits: const [
        MusicArtistCredit(
            id: 'j',
            creditedName: 'Billy Joel',
            sortName: 'Joel, Billy',
            sequence: 1),
      ],
    );
    const ignore = LibrarySortingOptions(useSortNames: false);

    expect(sort.compare(_context(joel), _context(adams)), greaterThan(0));
    expect(
      sort.compare(
          _context(joel, sorting: ignore), _context(adams, sorting: ignore)),
      lessThan(0),
    );
    expect(musicArtistSortName(_context(adams).dto), 'Adams, Bryan');
  });
}
