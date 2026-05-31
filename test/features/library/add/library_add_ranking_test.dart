import 'package:collectarr_app/features/library/add/library_add_ranking.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LibraryAddLocalRerankHints', () {
    test('hasAnyHint returns false when all fields are empty', () {
      const hints = LibraryAddLocalRerankHints();
      expect(hints.hasAnyHint, isFalse);
    });

    test('hasAnyHint returns true when query is set', () {
      const hints = LibraryAddLocalRerankHints(query: 'spider-man');
      expect(hints.hasAnyHint, isTrue);
    });

    test('hasAnyHint returns true when year is set', () {
      const hints = LibraryAddLocalRerankHints(year: 2020);
      expect(hints.hasAnyHint, isTrue);
    });
  });

  group('rerankLibraryMetadataItems', () {
    test('returns original list when fewer than 2 items', () {
      final items = [_item(title: 'Only One')];
      const hints = LibraryAddLocalRerankHints(query: 'Saga');
      final result = rerankLibraryMetadataItems(items, hints);
      expect(result, hasLength(1));
      expect(result.first.title, 'Only One');
    });

    test('returns original list when no hints', () {
      final items = [_item(title: 'A'), _item(title: 'B')];
      const hints = LibraryAddLocalRerankHints();
      final result = rerankLibraryMetadataItems(items, hints);
      expect(result.first.title, 'A');
    });

    test('ranks exact title match above partial match', () {
      final items = [
        _item(title: 'Amazing Spider-Man'),
        _item(title: 'Spider-Man'),
      ];
      const hints = LibraryAddLocalRerankHints(query: 'Spider-Man');
      final result = rerankLibraryMetadataItems(items, hints);
      expect(result.first.title, 'Spider-Man');
    });

    test('ranks matching publisher higher', () {
      final items = [
        _item(title: 'Batman', publisher: 'IDW'),
        _item(title: 'Batman', publisher: 'DC Comics'),
      ];
      const hints = LibraryAddLocalRerankHints(
        query: 'Batman',
        publisher: 'DC Comics',
      );
      final result = rerankLibraryMetadataItems(items, hints);
      expect(result.first.publisher, 'DC Comics');
    });

    test('ranks matching year higher', () {
      final items = [
        _item(title: 'Saga', releaseYear: 2020),
        _item(title: 'Saga', releaseYear: 2012),
      ];
      const hints = LibraryAddLocalRerankHints(query: 'Saga', year: 2012);
      final result = rerankLibraryMetadataItems(items, hints);
      expect(result.first.releaseYear, 2012);
    });

    test('ranks matching issue number higher', () {
      final items = [
        _item(title: 'Spawn', itemNumber: '5'),
        _item(title: 'Spawn', itemNumber: '1'),
      ];
      const hints = LibraryAddLocalRerankHints(
        query: 'Spawn',
        issueNumber: '1',
      );
      final result = rerankLibraryMetadataItems(items, hints);
      expect(result.first.itemNumber, '1');
    });
  });

  group('filterAndRerankLibraryMetadataItems', () {
    test('removes items below minimum score', () {
      final items = [
        _item(title: 'Exact Match'),
        _item(title: 'Completely Different Title'),
      ];
      const hints = LibraryAddLocalRerankHints(query: 'Exact Match');
      final result = filterAndRerankLibraryMetadataItems(
        items,
        hints,
        minimumScore: 50,
      );
      expect(result, hasLength(1));
      expect(result.first.title, 'Exact Match');
    });

    test('returns empty when no items meet threshold', () {
      final items = [
        _item(title: 'Unrelated'),
      ];
      const hints = LibraryAddLocalRerankHints(query: 'Saga');
      final result = filterAndRerankLibraryMetadataItems(
        items,
        hints,
        minimumScore: 200,
      );
      expect(result, isEmpty);
    });

    test('returns original items when no hints given', () {
      final items = [_item(title: 'A'), _item(title: 'B')];
      const hints = LibraryAddLocalRerankHints();
      final result = filterAndRerankLibraryMetadataItems(items, hints);
      expect(result, hasLength(2));
    });
  });

  group('shouldSearchProviderForCoreResults', () {
    test('returns true when no items', () {
      final result = shouldSearchProviderForCoreResults(
        [],
        const LibraryAddLocalRerankHints(query: 'Batman'),
      );
      expect(result, isTrue);
    });

    test('returns false when top match is highly confident', () {
      final items = [_item(title: 'Batman', publisher: 'DC Comics')];
      const hints = LibraryAddLocalRerankHints(
        query: 'Batman',
        publisher: 'DC Comics',
      );
      final result = shouldSearchProviderForCoreResults(items, hints);
      expect(result, isFalse);
    });
  });
}

LibraryMetadataItem _item({
  required String title,
  String? publisher,
  String? itemNumber,
  int? releaseYear,
}) {
  return LibraryMetadataItem(
    id: 'test-${title.hashCode}',
    kind: 'comic',
    title: title,
    publisher: publisher,
    itemNumber: itemNumber,
    releaseYear: releaseYear,
    editions: const [],
  );
}
