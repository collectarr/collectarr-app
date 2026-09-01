import 'package:collectarr_app/core/api/dto/catalog/catalog_edition_dto.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/video_release_projection_capability.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_view_enums.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_data_factories.dart';

void main() {
  group('Release Capability Ownership Contract Tests', () {
    test(
        'movie, tv, and anime kind specs register VideoReleaseProjectionCapability',
        () {
      expect(
        movieKindModule.releaseCapability,
        isA<VideoReleaseProjectionCapability>(),
      );
      expect(
        tvKindModule.releaseCapability,
        isA<VideoReleaseProjectionCapability>(),
      );
      expect(
        animeKindModule.releaseCapability,
        isA<VideoReleaseProjectionCapability>(),
      );
    });

    test('unsupported kinds have no release capability (null)', () {
      expect(comicKindModule.releaseCapability, isNull);
      expect(mangaKindModule.releaseCapability, isNull);
      expect(bookKindModule.releaseCapability, isNull);
      expect(gameKindModule.releaseCapability, isNull);
      expect(boardGameKindModule.releaseCapability, isNull);
      expect(musicKindModule.releaseCapability, isNull);
    });

    test(
        'asking for release projection on unsupported kind throws UnsupportedError',
        () {
      final shelf = ShelfState(
        entries: [
          ShelfEntry(
            itemId: 'comic-1',
            catalogItem: testCatalogItem(
              id: 'comic-1',
              kind: 'comic',
              title: 'Comic 1',
            ),
          ),
        ],
        ownedCount: 0,
        wishlistCount: 0,
        missingGradeCount: 0,
        pricedCount: 0,
        totalPaidCents: 0,
        primaryCurrency: null,
        hasMixedCurrencies: false,
      );

      expect(
        () => libraryItemsForShelf(
          shelf,
          comicKindModule,
          browserMode: LibraryWorkspaceBrowserMode.releases,
        ),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test(
        'supported kind projects releases successfully with VideoReleaseProjectionCapability',
        () {
      final shelf = ShelfState(
        entries: [
          ShelfEntry(
            itemId: 'movie-1',
            catalogItem: testCatalogItem(
              id: 'movie-1',
              kind: 'movie',
              title: 'Inception',
              editions: [
                const CatalogEdition(
                  id: 'ed-1',
                  title: '4K Ultra HD',
                  publisher: 'Warner Bros',
                ),
              ],
            ),
          ),
        ],
        ownedCount: 0,
        wishlistCount: 0,
        missingGradeCount: 0,
        pricedCount: 0,
        totalPaidCents: 0,
        primaryCurrency: null,
        hasMixedCurrencies: false,
      );

      final items = libraryItemsForShelf(
        shelf,
        movieKindModule,
        browserMode: LibraryWorkspaceBrowserMode.releases,
      );

      expect(items, isNotEmpty);
      expect(items.first.dto.title, 'Inception');
      expect(items.first.node, isA<LibraryReleaseNodeRef>());
      final releaseNode = items.first.node as LibraryReleaseNodeRef;
      expect(releaseNode.edition.title, '4K Ultra HD');
    });
  });
}
