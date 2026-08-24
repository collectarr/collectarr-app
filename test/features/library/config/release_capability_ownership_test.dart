import 'package:collectarr_app/core/api/dto/catalog/catalog_edition_dto.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/anime/config.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/config.dart';
import 'package:collectarr_app/features/library/kinds/book/config.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/game/config.dart';
import 'package:collectarr_app/features/library/kinds/manga/config.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/features/library/kinds/tv/config.dart';
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
        moviesLibraryConfig.releaseCapability,
        isA<VideoReleaseProjectionCapability>(),
      );
      expect(
        tvLibraryConfig.releaseCapability,
        isA<VideoReleaseProjectionCapability>(),
      );
      expect(
        animeLibraryConfig.releaseCapability,
        isA<VideoReleaseProjectionCapability>(),
      );
    });

    test('unsupported kinds have no release capability (null)', () {
      expect(comicsLibraryConfig.releaseCapability, isNull);
      expect(mangaLibraryConfig.releaseCapability, isNull);
      expect(booksLibraryConfig.releaseCapability, isNull);
      expect(gamesLibraryConfig.releaseCapability, isNull);
      expect(boardGamesLibraryConfig.releaseCapability, isNull);
      expect(musicLibraryConfig.releaseCapability, isNull);
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
          comicsLibraryConfig,
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
        moviesLibraryConfig,
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
