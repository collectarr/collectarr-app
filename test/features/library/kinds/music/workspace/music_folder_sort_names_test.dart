import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/library/domain/library_target_ref.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_artist_credit.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_catalog_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_data.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_context.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_projection_context.dart';
import 'package:flutter_test/flutter_test.dart';

const _registration = MusicRegistration();

LibraryProjectionItem _item(MusicAlbum album) =>
    LibraryProjectionItem.fromShelf(
      LibraryWorkspaceContext(
        item: WorkspaceItem(
          target: CatalogTargetRef(
            CatalogItemRef(kind: CatalogMediaKind.music, id: album.title),
          ),
          kindPresentationData: MusicWorkspaceData.fromMusic(album),
        ),
        personal: const PersonalOverlay(),
      ),
      _registration,
    );

MusicAlbum _byArtist(String name, {String? sortName}) => MusicAlbum(
      title: '$name album',
      artistCredits: [
        MusicArtistCredit(
            id: name, creditedName: name, sortName: sortName, sequence: 1),
      ],
    );

List<String> _folders(
  List<MusicAlbum> albums,
  String fieldId, {
  LibrarySortingOptions sorting = const LibrarySortingOptions(),
}) {
  final groupId = libraryKindWorkspaceForKind(CatalogMediaKind.music)
      .fields
      .groups
      .singleWhere((group) => group.id.value == fieldId)
      .id;
  return const LibraryGroupingEngine()
      .buildBuckets(
          [for (final album in albums) _item(album)], _registration, groupId,
          sorting: sorting)
      .map((bucket) => bucket.title)
      .where((title) => !title.startsWith('['))
      .toList();
}

void main() {
  final artistField = MusicCatalogWorkspaceFields.artist.id.value;
  final albums = [
    _byArtist('Yuki Hayashi'),
    _byArtist('Akira Yamaoka', sortName: 'Yamaoka, Akira'),
    _byArtist('Sabaton'),
  ];

  test('artist folders show the name but follow the sort name', () {
    expect(_folders(albums, artistField),
        ['Sabaton', 'Akira Yamaoka', 'Yuki Hayashi']);
  });

  test('artist folders follow the names when Settings ignores sort names', () {
    expect(
      _folders(albums, artistField,
          sorting: const LibrarySortingOptions(useSortNames: false)),
      ['Akira Yamaoka', 'Sabaton', 'Yuki Hayashi'],
    );
  });

  test('a pick-list Sort Name orders that value\'s folder', () {
    final labelField = MusicCatalogWorkspaceFields.publisher.id.value;
    final labels = [
      MusicAlbum(title: 'One', publisher: 'The End Records'),
      MusicAlbum(title: 'Two', publisher: 'Napalm Records'),
    ];
    const sortNames = {
      'music.record_label': {'the end records': 'End Records, The'},
    };

    expect(_folders(labels, labelField), ['Napalm Records', 'The End Records']);
    expect(
      _folders(labels, labelField,
          sorting: const LibrarySortingOptions(pickListSortNames: sortNames)),
      ['The End Records', 'Napalm Records'],
    );
    expect(
      _folders(labels, labelField,
          sorting: const LibrarySortingOptions(
              useSortNames: false, pickListSortNames: sortNames)),
      ['Napalm Records', 'The End Records'],
    );
  });
}
