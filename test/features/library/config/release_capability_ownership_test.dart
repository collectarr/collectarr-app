import 'package:collectarr_app/core/api/dto/catalog/catalog_edition_dto.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/anime/release/anime_release_projection_capability.dart';
import 'package:collectarr_app/features/library/kinds/movie/release/movie_release_projection_capability.dart';
import 'package:collectarr_app/features/library/kinds/tv/release/tv_release_projection_capability.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_view_enums.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_data_factories.dart';

void main() {
  group('Release Capability Ownership Contract Tests', () {
    test('movie, tv, and anime kinds register concrete release capabilities',
        () {
      expect(
        movieKindModule.releaseCapability,
        isA<MovieReleaseProjectionCapability>(),
      );
      expect(
        tvKindModule.releaseCapability,
        isA<TvReleaseProjectionCapability>(),
      );
      expect(
        animeKindModule.releaseCapability,
        isA<AnimeReleaseProjectionCapability>(),
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
          LibraryWorkspaceSource(
            itemId: 'comic-1',
            catalogData: testWorkspaceCatalogData(testCatalogItem(
              id: 'comic-1',
              kind: 'comic',
              title: 'Comic 1',
            ).asShelfCatalogItem),
          ),
        ],
        ownedCount: 0,
        wishlistCount: 0,
        pricedCount: 0,
        totalPaidCents: 0,
        primaryCurrency: null,
        hasMixedCurrencies: false,
      );

      expect(
        () => libraryItemsForShelf(
          shelf,
          libraryKindRegistrationForKind(CatalogMediaKind.comic),
          browserMode: LibraryWorkspaceBrowserMode.releases,
        ),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('supported kind projects releases through its concrete capability',
        () {
      final shelf = ShelfState(
        entries: [
          LibraryWorkspaceSource(
            itemId: 'movie-1',
            catalogData: testWorkspaceCatalogData(testCatalogItem(
              id: 'movie-1',
              kind: 'movie',
              title: 'Inception',
              editions: [
                const CatalogEditionDto(
                  id: 'ed-1',
                  title: '4K Ultra HD',
                  publisher: 'Warner Bros',
                ),
              ],
            ).asShelfCatalogItem),
          ),
        ],
        ownedCount: 0,
        wishlistCount: 0,
        pricedCount: 0,
        totalPaidCents: 0,
        primaryCurrency: null,
        hasMixedCurrencies: false,
      );

      final items = libraryItemsForShelf(
        shelf,
        libraryKindRegistrationForKind(CatalogMediaKind.movie),
        browserMode: LibraryWorkspaceBrowserMode.releases,
      );

      expect(items, isNotEmpty);
      expect(items.first.dto.title, 'Inception');
      expect(items.first.node, isA<LibraryReleaseNodeRef>());
      final releaseNode = items.first.node as LibraryReleaseNodeRef;
      expect(releaseNode.edition.title, '4K Ultra HD');
    });

    test('kinds without release capability do not open release folder on open',
        () {
      expect(
        bookKindModule.hierarchy.shouldOpenReleaseFolderOnOpen(
          browserMode: LibraryWorkspaceBrowserMode.media,
          browseScope: LibraryBrowserScope.title,
          hasReleaseCapability: bookKindModule.releaseCapability != null,
        ),
        isFalse,
      );
      expect(
        movieKindModule.hierarchy.shouldOpenReleaseFolderOnOpen(
          browserMode: LibraryWorkspaceBrowserMode.media,
          browseScope: LibraryBrowserScope.title,
          hasReleaseCapability: movieKindModule.releaseCapability != null,
        ),
        isTrue,
      );
    });
  });
}
