import 'package:collectarr_app/features/library/add/contracts/library_add_result_policy.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/library_add_video_result_policy.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_result_policy.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_kind_module.dart';
import 'package:collectarr_app/features/providers/transport/provider_candidate.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TV Add policy classifies and filters media scopes', () {
    final series = CatalogSearchCandidate.fromItem(testCatalogItemFromJson({
      'id': 'tv-series',
      'kind': 'tv',
      'title': 'Example Show',
    }));
    final season = CatalogSearchCandidate.fromItem(testCatalogItemFromJson({
      'id': 'tv-season',
      'kind': 'tv',
      'title': 'Example Show',
      'series': {
        'series_title': 'Example Show',
        'season_number': 1,
      },
    }));
    final release =
        CatalogSearchCandidate.fromItem(testCatalogItemFromJson({
      'id': 'tv-release',
      'kind': 'tv',
      'title': 'Example Show',
      'item_number': 'Disc 1',
      'physical_format': 'Blu-ray',
    }));
    final policy = tvKindModule.add.resultPolicy;

    final visible = policy.filterCoreResults(
      items: [series, season, release],
      state: const LibraryAddResultPolicyState(
        values: {
          libraryAddVideoMediaOptionId: false,
          libraryAddVideoSeasonOptionId: true,
          libraryAddVideoReleaseOptionId: false,
        },
      ),
    );

    expect(visible.map((item) => item.id), ['tv-season']);
  });

  test('TV Add policy keeps all scopes visible by default', () {
    final series = CatalogSearchCandidate.fromItem(testCatalogItemFromJson({
      'id': 'tv-series',
      'kind': 'tv',
      'title': 'Example Show',
    }));
    final season = CatalogSearchCandidate.fromItem(testCatalogItemFromJson({
      'id': 'tv-season',
      'kind': 'tv',
      'title': 'Example Show',
      'series': {'season_number': 2},
    }));
    final release =
        CatalogSearchCandidate.fromItem(testCatalogItemFromJson({
      'id': 'tv-release',
      'kind': 'tv',
      'title': 'Example Show',
      'item_number': 'Disc 1',
      'variant': 'Season Box Set',
    }));

    final visible = tvKindModule.add.resultPolicy.filterCoreResults(
      items: [series, season, release],
      state: const LibraryAddResultPolicyState(),
    );

    expect(visible, hasLength(3));
  });

  test('Comic Add policy owns owned and variant visibility', () {
    final owned = CatalogSearchCandidate.fromItem(testCatalogItemFromJson({
      'id': 'comic-owned',
      'kind': 'comic',
      'title': 'Owned Comic',
    }));
    final variant =
        CatalogSearchCandidate.fromItem(testCatalogItemFromJson({
      'id': 'comic-variant',
      'kind': 'comic',
      'title': 'Variant Comic',
      'variant': 'Foil',
    }));
    final regular =
        CatalogSearchCandidate.fromItem(testCatalogItemFromJson({
      'id': 'comic-regular',
      'kind': 'comic',
      'title': 'Regular Comic',
    }));

    final state = const LibraryAddResultPolicyState(
      values: {
        comicAddHideOwnedOptionId: true,
        comicAddHideVariantsOptionId: true,
      },
    );
    final visible = comicAddResultPolicy.filterCoreResults(
      items: [owned, variant, regular],
      state: state,
      ownedCatalogRefs: {
        CatalogEntityRef(
          kind: CatalogMediaKind.comic,
          entityType: const CatalogEntityTypeId('work'),
          id: 'comic-owned',
        ),
      },
    );
    final visibleProviders = comicAddResultPolicy.filterProviderResults(
      candidates: const [
        ProviderCandidate(
          provider: 'gcd',
          providerItemId: 'regular',
          title: 'Regular Comic',
          kind: CatalogMediaKind.comic,
          candidateType: 'issue',
          issueNumber: '1',
        ),
        ProviderCandidate(
          provider: 'gcd',
          providerItemId: 'variant',
          title: 'Variant Comic',
          kind: CatalogMediaKind.comic,
          candidateType: 'variant',
        ),
      ],
      state: state,
    );

    expect(visible.map((item) => item.id), ['comic-regular']);
    expect(visibleProviders.map((candidate) => candidate.providerItemId),
        ['regular']);
    expect(
      comicAddResultPolicy.isProviderGroupCandidate(
        const ProviderCandidate(
          provider: 'gcd',
          providerItemId: 'series',
          title: 'Regular Comic',
          kind: CatalogMediaKind.comic,
          candidateType: 'series',
        ),
      ),
      isTrue,
    );
  });
}
