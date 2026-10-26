import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/library/domain/library_target_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/data.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('an album without a cover never borrows its Core summary image', () {
    const coreRef = CatalogItemRef(kind: CatalogMediaKind.music, id: 'core-1');
    WorkspaceItem item(String? cover) => WorkspaceItem(
          target: const CatalogTargetRef(coreRef),
          presentation: const CatalogDisplaySummary(
            ref: coreRef,
            kind: CatalogMediaKind.music,
            primaryLabel: 'Northern Lights',
            imageUrl: 'https://example.invalid/core-front.png',
          ),
          kindPresentationData: MusicWorkspaceData.fromMusic(
            MusicAlbum(title: 'Northern Lights', coverImageUrl: cover),
          ),
        );
    const projector = MusicLibraryEntryWorkspaceProjector();

    final withoutCover = projector.project(
      item: item(null),
      personal: const PersonalOverlay(),
    );
    final withCover = projector.project(
      item: item('https://example.invalid/own-front.png'),
      personal: const PersonalOverlay(),
    );

    expect(withoutCover.common.coverImageUrl, isNull);
    expect(
      withCover.common.coverImageUrl,
      'https://example.invalid/own-front.png',
    );
  });
}
