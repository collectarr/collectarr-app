import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/library/config/library_facet_module.dart';
import 'package:collectarr_app/features/library/generic/library_facet_bucket_service.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_group_values.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final api = ApiClient(baseUrl: 'http://unused');

  Future<FacetBuckets> load(
    Set<String> ids,
    List<LibraryFacetRow> rows,
  ) =>
      const LibraryFacetBucketService().load(
        api: api,
        facets: LibraryFacetModule(
          loadRows: (
                  {required facetId, required itemIds, required api}) async =>
              rows,
        ),
        facetId: const DynamicLibraryFacetId('test.genre'),
        items: const [],
        itemIds: ids,
        signature: 'fixture',
        allBucketLabel: '[All Albums]',
      );

  test('missing facet values retain selectable None membership and counts',
      () async {
    final result = await load({
      'jazz',
      'rock',
      'empty'
    }, [
      const LibraryFacetRow(name: 'Jazz', itemIds: ['jazz', 'jazz']),
      const LibraryFacetRow(name: 'Rock', itemIds: ['rock']),
      const LibraryFacetRow(name: ' ', itemIds: ['empty']),
      const LibraryFacetRow(name: 'Outside', itemIds: ['not-in-shelf']),
    ]);
    expect(result.buckets.map((b) => b.title),
        ['[All Albums]', libraryEmptyGroupLabel, 'Jazz', 'Rock']);
    expect(result.buckets.map((b) => b.count), [3, 1, 1, 1]);
    expect(result.itemIdsByBucket[libraryEmptyGroupLabel], {'empty'});
  });

  test('multi-valued items are not empty and count once per matching bucket',
      () async {
    final result = await load({
      'mixed'
    }, [
      const LibraryFacetRow(name: 'CD', itemIds: ['mixed', 'mixed']),
      const LibraryFacetRow(name: 'Vinyl', itemIds: ['mixed']),
    ]);
    expect(result.itemIdsByBucket.keys, ['CD', 'Vinyl']);
    expect(result.buckets.map((b) => b.count), [1, 1, 1]);
  });

  test('all-empty and empty shelves produce accurate empty buckets', () async {
    final allEmpty = await load({'a', 'b'}, const []);
    expect(allEmpty.itemIdsByBucket[libraryEmptyGroupLabel], {'a', 'b'});
    expect(allEmpty.buckets.map((b) => b.count), [2, 2]);
    final emptyShelf = await load({}, const []);
    expect(emptyShelf.itemIdsByBucket, isEmpty);
    expect(emptyShelf.buckets.single.count, 0);
  });
}
