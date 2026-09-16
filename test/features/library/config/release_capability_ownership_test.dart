import 'package:collectarr_app/core/api/dto/catalog/catalog_edition_dto.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/anime/release/anime_release_projection_capability.dart';
import 'package:collectarr_app/features/library/kinds/movie/release/movie_release_projection_capability.dart';
import 'package:collectarr_app/features/library/kinds/music/release/music_release_projection_capability.dart';
import 'package:collectarr_app/features/library/kinds/tv/release/tv_release_projection_capability.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_view_enums.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_data_factories.dart';

void main() {
  group('Release Capability Ownership Contract Tests', () {
    test('movie, tv, and anime kinds register concrete release capabilities',
        () {
      expect(
        movieKindReleaseCapability,
        isA<MovieReleaseProjectionCapability>(),
      );
      expect(
        tvKindReleaseCapability,
        isA<TvReleaseProjectionCapability>(),
      );
      expect(
        animeKindReleaseCapability,
        isA<AnimeReleaseProjectionCapability>(),
      );
    });

    test('release capability is registered only for supported kinds', () {
      expect(comicKindReleaseCapability, isNull);
      expect(mangaKindReleaseCapability, isNull);
      expect(bookKindReleaseCapability, isNull);
      expect(gameKindReleaseCapability, isNull);
      expect(boardGameKindReleaseCapability, isNull);
      expect(
          musicKindReleaseCapability, isA<MusicReleaseProjectionCapability>());
    });

    test('music projects concrete releases below each release group', () {
      final group = MusicReleaseGroup(
        id: const MusicReleaseGroupId('group-1'),
        title: 'Kind of Blue',
        artist: 'Miles Davis',
        releases: [
          MusicRelease(
            id: const MusicReleaseId('release-cd'),
            releaseGroupId: const MusicReleaseGroupId('group-1'),
            title: 'Kind of Blue (CD)',
            releaseType: 'Album',
          ),
          MusicRelease(
            id: const MusicReleaseId('release-vinyl'),
            releaseGroupId: const MusicReleaseGroupId('group-1'),
            title: 'Kind of Blue (Vinyl)',
            releaseType: 'Album',
          ),
        ],
      );
      final item = testCatalogItem(
        id: 'group-1',
        kind: 'music',
        title: group.title,
        payload: group.toJson(),
      ).withKindMetadata(group);
      final shelf = ShelfState(
        entries: [
          LibraryWorkspaceSource(
            itemId: 'group-1',
            catalogData: testWorkspaceCatalogData(item),
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
        libraryKindRegistrationForKind(CatalogMediaKind.music),
        browserMode: LibraryWorkspaceBrowserMode.release,
      );

      expect(items, hasLength(2));
      expect(
        items.map((item) => (item.node as LibraryReleaseRef).releaseId),
        ['release-cd', 'release-vinyl'],
      );
      expect(items.map((item) => item.dto.title), [
        'Kind of Blue (CD)',
        'Kind of Blue (Vinyl)',
      ]);
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
          browserMode: LibraryWorkspaceBrowserMode.release,
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
        browserMode: LibraryWorkspaceBrowserMode.release,
      );

      expect(items, isNotEmpty);
      expect(items.first.dto.title, 'Inception');
      expect(items.first.node, isA<LibraryReleaseRef>());
      final releaseNode = items.first.node as LibraryReleaseRef;
      expect(releaseNode.release.title, '4K Ultra HD');
    });

    test('kinds without release capability do not open release folder on open',
        () {
      expect(
        bookKindTopology.shouldOpenReleaseFolderOnOpen(
          browserMode: LibraryWorkspaceBrowserMode.work,
          browseScope: LibraryEntityScope.work,
          hasReleaseCapability: bookKindReleaseCapability != null,
        ),
        isFalse,
      );
      expect(
        movieKindTopology.shouldOpenReleaseFolderOnOpen(
          browserMode: LibraryWorkspaceBrowserMode.work,
          browseScope: LibraryEntityScope.work,
          hasReleaseCapability: true,
        ),
        isTrue,
      );
    });
  });
}
