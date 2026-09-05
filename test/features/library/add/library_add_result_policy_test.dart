import 'package:collectarr_app/features/library/add/contracts/library_add_result_policy.dart';
import 'package:collectarr_app/features/library/add/library_add_video_result_policy.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_result_policy.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_kind_module.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TV Add policy classifies and filters media scopes', () {
    final series = typedCatalogItemFromMap({
      'id': 'tv-series',
      'kind': 'tv',
      'title': 'Example Show',
    });
    final season = typedCatalogItemFromMap({
      'id': 'tv-season',
      'kind': 'tv',
      'title': 'Example Show',
      'series': {
        'series_title': 'Example Show',
        'season_number': 1,
      },
    });
    final release = typedCatalogItemFromMap({
      'id': 'tv-release',
      'kind': 'tv',
      'title': 'Example Show',
      'item_number': 'Disc 1',
      'physical_format': 'Blu-ray',
    });
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
    final series = typedCatalogItemFromMap({
      'id': 'tv-series',
      'kind': 'tv',
      'title': 'Example Show',
    });
    final season = typedCatalogItemFromMap({
      'id': 'tv-season',
      'kind': 'tv',
      'title': 'Example Show',
      'series': {'season_number': 2},
    });
    final release = typedCatalogItemFromMap({
      'id': 'tv-release',
      'kind': 'tv',
      'title': 'Example Show',
      'item_number': 'Disc 1',
      'variant': 'Season Box Set',
    });

    final visible = tvKindModule.add.resultPolicy.filterCoreResults(
      items: [series, season, release],
      state: const LibraryAddResultPolicyState(),
    );

    expect(visible, hasLength(3));
  });

  test('Comic Add policy owns owned and variant visibility', () {
    final owned = typedCatalogItemFromMap({
      'id': 'comic-owned',
      'kind': 'comic',
      'title': 'Owned Comic',
    });
    final variant = typedCatalogItemFromMap({
      'id': 'comic-variant',
      'kind': 'comic',
      'title': 'Variant Comic',
      'variant': 'Foil',
    });
    final regular = typedCatalogItemFromMap({
      'id': 'comic-regular',
      'kind': 'comic',
      'title': 'Regular Comic',
    });

    final state = const LibraryAddResultPolicyState(
      values: {
        comicAddHideOwnedOptionId: true,
        comicAddHideVariantsOptionId: true,
      },
    );
    final visible = comicAddResultPolicy.filterCoreResults(
      items: [owned, variant, regular],
      state: state,
      ownedCatalogItemIds: {'comic-owned'},
    );
    final visibleProviders = comicAddResultPolicy.filterProviderResults(
      candidates: const [
        ProviderCandidate(
          provider: 'gcd',
          providerItemId: 'regular',
          title: 'Regular Comic',
          kind: 'comic',
          candidateType: 'issue',
          issueNumber: '1',
        ),
        ProviderCandidate(
          provider: 'gcd',
          providerItemId: 'variant',
          title: 'Variant Comic',
          kind: 'comic',
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
          kind: 'comic',
          candidateType: 'series',
        ),
      ),
      isTrue,
    );
  });
}
