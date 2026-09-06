import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('exact core match suppresses provider fallback', () {
    final shouldFallback = libraryKindRuntimeForKind(CatalogMediaKind.comic)
        .add
        .search
        .ranking
        .shouldSearchProviderForCoreResults(
      [
        testCatalogItemFromJson({
          'id': 'comic-423',
          'kind': 'comic',
          'title': 'Batman',
          'item_number': '423',
          'publisher': 'DC',
          'release_year': 1988,
          'series': {
            'series_title': 'Batman',
            'volume_start_year': 1988,
          },
        }),
      ],
      LibraryAddSearchContext(
        query: 'Batman',
        advancedFilters: {
          LibraryAddFilterId('comic.series'): 'Batman',
          LibraryAddFilterId('comic.issue'): '423',
          LibraryAddFilterId('comic.publisher'): 'DC',
          LibraryAddFilterId('comic.year'): '1988',
        },
      ),
    );

    expect(shouldFallback, isFalse);
  });

  test('weak core top match keeps provider fallback enabled', () {
    final shouldFallback = libraryKindRuntimeForKind(CatalogMediaKind.movie)
        .add
        .search
        .ranking
        .shouldSearchProviderForCoreResults(
      [
        testCatalogItemFromJson({
          'id': 'movie-1',
          'kind': 'movie',
          'title': 'Blade Runner 2049',
          'publisher': 'Warner Bros.',
          'release_year': 2017,
        }),
      ],
      LibraryAddSearchContext(query: 'Blade Runner'),
    );

    expect(shouldFallback, isTrue);
  });

  test('empty core results still trigger provider fallback', () {
    expect(
      libraryKindRuntimeForKind(CatalogMediaKind.anime)
          .add
          .search
          .ranking
          .shouldSearchProviderForCoreResults(
        const [],
        LibraryAddSearchContext(query: 'Naruto'),
      ),
      isTrue,
    );
  });
}
