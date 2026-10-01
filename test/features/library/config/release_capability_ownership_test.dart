import 'package:collectarr_app/core/api/dto/catalog/catalog_edition_dto.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/anime/release/anime_release_projection_capability.dart';
import 'package:collectarr_app/features/library/config/library_browser_navigation_policy.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_view_enums.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_data_factories.dart';

void main() {
  group('Release Capability Ownership Contract Tests', () {
    test('anime registers a concrete release capability', () {
      expect(
        animeKindReleaseCapability,
        isA<AnimeReleaseProjectionCapability>(),
      );
    });

    test('release capabilities belong only to kinds with release children', () {
      for (final registration in collectarrKindRegistrationsList) {
        final kind = registration.kind;
        if (kind == CatalogMediaKind.music ||
            kind == CatalogMediaKind.movie ||
            kind == CatalogMediaKind.tv) {
          continue;
        }
        expect(
          libraryReleaseCapabilityForKind(kind),
          isNotNull,
          reason: '${kind.apiValue} must expose a release capability',
        );
      }
    });

    test('flat catalog kinds do not register a release scope', () {
      for (final kind in [
        CatalogMediaKind.music,
        CatalogMediaKind.movie,
        CatalogMediaKind.tv,
      ]) {
        expect(libraryReleaseCapabilityForKind(kind), isNull);
      }
    });

    test('release projection with no canonical releases is empty', () {
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
        libraryItemsForShelf(
          shelf,
          libraryKindRegistrationForKind(CatalogMediaKind.comic),
          browserMode: LibraryWorkspaceBrowserMode.release,
        ),
        isEmpty,
      );
    });

    test('Movie edition is the root item, with no release child projection',
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
        browserMode: LibraryWorkspaceBrowserMode.release,
      );

      expect(items, isEmpty);
    });

    test('browser policy opens the structural release folder', () {
      expect(
        libraryBrowserNavigationPolicy.shouldOpenReleaseFolderOnOpen(
          browserMode: LibraryWorkspaceBrowserMode.work,
          browseScope: LibraryEntityScope.work,
        ),
        isTrue,
      );
      expect(
        libraryBrowserNavigationPolicy.shouldOpenReleaseFolderOnOpen(
          browserMode: LibraryWorkspaceBrowserMode.work,
          browseScope: LibraryEntityScope.work,
        ),
        isTrue,
      );
    });
  });
}
