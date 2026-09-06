import 'package:collectarr_app/features/library/add/library_add_ranking.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:flutter_test/flutter_test.dart';

const _publisherFilterId = LibraryAddFilterId('test.publisher');
const _yearFilterId = LibraryAddFilterId('test.year');
const _issueFilterId = LibraryAddFilterId('test.issue');

final _ranking = buildLibraryAddSearchRanking(
  fields: [
    LibraryAddSearchRankField(
      id: _publisherFilterId,
      exactWeight: 60,
      containsWeight: 24,
      metadataValues: (item) => [item.payload['publisher']],
      providerValues: (candidate) => [candidate.publisher],
    ),
    LibraryAddSearchRankField(
      id: _yearFilterId,
      exactWeight: 55,
      containsWeight: 20,
      metadataValues: (item) => [item.releaseYear],
      providerValues: (candidate) => [candidate.series?.volumeStartYear],
    ),
    LibraryAddSearchRankField(
      id: _issueFilterId,
      exactWeight: 75,
      containsWeight: 36,
      metadataValues: (item) => [item.payload['item_number']],
      providerValues: (candidate) => [candidate.issueNumber],
    ),
  ],
);

LibraryAddSearchContext _context({
  String query = '',
  Map<LibraryAddFilterId, Object?> advancedFilters = const {},
}) {
  return LibraryAddSearchContext(
    query: query,
    advancedFilters: advancedFilters,
  );
}

void main() {
  group('LibraryAddSearchContext', () {
    test('reports no input when query and filters are empty', () {
      expect(_context().hasAnyInput, isFalse);
    });

    test('reports input when query or an opaque filter is set', () {
      expect(_context(query: 'spider-man').hasAnyInput, isTrue);
      expect(
        _context(advancedFilters: {_yearFilterId: '2020'}).hasAnyInput,
        isTrue,
      );
    });
  });

  group('LibraryAddSearchRanking', () {
    test('returns original list when fewer than 2 items', () {
      final items = [_item(title: 'Only One')];
      final result = _ranking.rankMetadata(
        items,
        _context(query: 'Saga'),
      );
      expect(result, hasLength(1));
      expect(result.first.title, 'Only One');
    });

    test('returns original list when no search input exists', () {
      final items = [_item(title: 'A'), _item(title: 'B')];
      final result = _ranking.rankMetadata(items, _context());
      expect(result.first.title, 'A');
    });

    test('ranks exact title match above partial match', () {
      final items = [
        _item(title: 'Amazing Spider-Man'),
        _item(title: 'Spider-Man'),
      ];
      final result = _ranking.rankMetadata(
        items,
        _context(query: 'Spider-Man'),
      );
      expect(result.first.title, 'Spider-Man');
    });

    test('ranks matching publisher higher', () {
      final items = [
        _item(title: 'Batman', publisher: 'IDW'),
        _item(title: 'Batman', publisher: 'DC Comics'),
      ];
      final result = _ranking.rankMetadata(
        items,
        _context(
          query: 'Batman',
          advancedFilters: {_publisherFilterId: 'DC Comics'},
        ),
      );
      expect(result.first.payload['publisher'], 'DC Comics');
    });

    test('ranks matching year higher', () {
      final items = [
        _item(title: 'Saga', releaseYear: 2020),
        _item(title: 'Saga', releaseYear: 2012),
      ];
      final result = _ranking.rankMetadata(
        items,
        _context(
          query: 'Saga',
          advancedFilters: {_yearFilterId: '2012'},
        ),
      );
      expect(result.first.releaseYear, 2012);
    });

    test('ranks matching issue number higher', () {
      final items = [
        _item(title: 'Spawn', itemNumber: '5'),
        _item(title: 'Spawn', itemNumber: '1'),
      ];
      final result = _ranking.rankMetadata(
        items,
        _context(
          query: 'Spawn',
          advancedFilters: {_issueFilterId: '1'},
        ),
      );
      expect(result.first.payload['item_number'], '1');
    });

    test('ranks provider candidates using the same kind-owned fields', () {
      const candidates = [
        ProviderCandidate(
          provider: 'test',
          providerItemId: 'id-1',
          title: 'Batman',
          kind: 'comic',
          publisher: 'IDW',
        ),
        ProviderCandidate(
          provider: 'test',
          providerItemId: 'id-2',
          title: 'Batman',
          kind: 'comic',
          publisher: 'DC Comics',
        ),
      ];
      final result = _ranking.rankProvider(
        candidates,
        _context(
          query: 'Batman',
          advancedFilters: {_publisherFilterId: 'DC Comics'},
        ),
      );
      expect(result.first.publisher, 'DC Comics');
    });

    test('falls back to provider when the top Core match is not confident', () {
      final items = [_item(title: 'Batman', publisher: 'DC Comics')];
      final context = _context(
        query: 'Batman',
        advancedFilters: {_publisherFilterId: 'DC Comics'},
      );
      expect(
        _ranking.shouldSearchProviderForCoreResults(items, context),
        isFalse,
      );
    });
  });

  group('filterAndRankCatalogItems', () {
    test('removes items below minimum score', () {
      final items = [
        _item(title: 'Exact Match'),
        _item(title: 'Completely Different Title'),
      ];
      final result = filterAndRankCatalogItems(
        items,
        _ranking,
        _context(query: 'Exact Match'),
        minimumScore: 50,
      );
      expect(result, hasLength(1));
      expect(result.first.title, 'Exact Match');
    });

    test('returns empty when no items meet threshold', () {
      final result = filterAndRankCatalogItems(
        [_item(title: 'Unrelated')],
        _ranking,
        _context(query: 'Saga'),
        minimumScore: 200,
      );
      expect(result, isEmpty);
    });

    test('returns original items when no input is given', () {
      final result = filterAndRankCatalogItems(
        [_item(title: 'A'), _item(title: 'B')],
        _ranking,
        _context(),
      );
      expect(result, hasLength(2));
    });
  });
}

CatalogItem _item({
  required String title,
  String? publisher,
  String? itemNumber,
  int? releaseYear,
}) {
  return testCatalogItemFromJson({
    'id': 'test-${title.hashCode}',
    'kind': 'comic',
    'title': title,
    if (publisher != null) 'publisher': publisher,
    if (itemNumber != null) 'item_number': itemNumber,
    if (releaseYear != null) 'release_year': releaseYear,
  });
}
