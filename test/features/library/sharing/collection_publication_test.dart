import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/library/domain/library_target_ref.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_data.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/sharing/collection_publication.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_context.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('publication requires opt-in for personal values', () {
    final item = LibraryProjectionItem.fromShelf(
      LibraryWorkspaceContext(
        item: WorkspaceItem(
          target: const CatalogTargetRef(
            CatalogItemRef(kind: CatalogMediaKind.music, id: 'album-1'),
          ),
          kindPresentationData: MusicWorkspaceData.fromMusic(
            MusicAlbum(title: 'Public album'),
          ),
        ),
        personal: const PersonalOverlay(locationPath: 'Private shelf'),
      ),
      const MusicRegistration(),
    );
    Map<String, dynamic> publication(bool includePersonal) =>
        buildCollectionPublication(
          type: const MusicRegistration(),
          title: 'Albums',
          visibility: 'public',
          includePersonal: includePersonal,
          items: [item],
        );

    final publicItem = (publication(false)['items'] as List).single as Map;
    expect(publicItem['fields'], containsPair('Title', 'Public album'));
    expect(publicItem['fields'], contains('Format Summary'));
    expect(publicItem['fields'], isNot(contains('Location')));
    expect(publicItem['personal_fields'], isEmpty);
    expect(publication(false).toString(), isNot(contains('Private shelf')));

    final optedInItem = (publication(true)['items'] as List).single as Map;
    expect(optedInItem['personal_fields'],
        containsPair('Location', 'Private shelf'));
    final partial = buildCollectionPublication(
      type: const MusicRegistration(),
      title: 'Albums',
      visibility: 'partial',
      includePersonal: true,
      items: [item],
    );
    expect(partial['include_personal'], isFalse);
    expect(partial.toString(), isNot(contains('Private shelf')));
  });
}
