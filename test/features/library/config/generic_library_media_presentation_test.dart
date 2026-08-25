import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/generic_library_media_presentation.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/config/generic_library_workspace_projector.dart';

LibraryProjectionRuntime _makeItem(String id,
    {String? seriesTitle, String? title}) {
  final cat = CatalogItemDto(
    id: id,
    kind: 'comic',
    title: title ?? 'Batman #1',
    series: seriesTitle != null
        ? CatalogSeriesDetailsDto(
            seriesId: '$id-series', seriesTitle: seriesTitle)
        : null,
  );
  final source = ShelfEntry(itemId: id, catalogItem: cat);
  final node = LibraryTitleNodeRef(titleItemId: id);
  final dto = const GenericWorkspaceProjector().projectTitle(
    source: source,
    node: node,
  );
  return LibraryProjectionItem(source: source, node: node, dto: dto);
}

void main() {
  group('series bucketing with genericLibraryBucketLabelBuilder', () {
    test('groups by seriesTitle when available', () {
      final item = _makeItem('comic-1',
          seriesTitle: 'Batman: The Dark Knight',
          title: 'Batman: The Dark Knight #1');

      final bucket = genericLibraryBucketLabelBuilder(
        LibraryBucketingContext(
          source: item.source,
          item: item,
          groupMode: 'series',
        ),
      );

      expect(bucket, 'Batman: The Dark Knight');
    });

    test('uses unknown series when seriesTitle is missing', () {
      final item = _makeItem('comic-2', seriesTitle: null, title: 'Batman #50');

      final bucket = genericLibraryBucketLabelBuilder(
        LibraryBucketingContext(
          source: item.source,
          item: item,
          groupMode: 'series',
        ),
      );

      expect(bucket, 'Unknown series');
    });

    test('uses unknown series when seriesTitle is empty', () {
      final item =
          _makeItem('comic-3', seriesTitle: '', title: 'Wonder Woman #1');

      final bucket = genericLibraryBucketLabelBuilder(
        LibraryBucketingContext(
          source: item.source,
          item: item,
          groupMode: 'series',
        ),
      );

      expect(bucket, 'Unknown series');
    });

    test('uses unknown series when both seriesTitle and title are empty', () {
      final item = _makeItem('comic-4', seriesTitle: '', title: '');

      final bucket = genericLibraryBucketLabelBuilder(
        LibraryBucketingContext(
          source: item.source,
          item: item,
          groupMode: 'series',
        ),
      );

      expect(bucket, 'Unknown series');
    });

    test(
        'issue: duplicate series buckets when different series have same title',
        () {
      final v0Item =
          _makeItem('batman-v0', seriesTitle: 'Batman', title: 'Batman #1');
      final v1Item =
          _makeItem('batman-v1', seriesTitle: null, title: 'Batman #1');

      final v0Bucket = genericLibraryBucketLabelBuilder(
        LibraryBucketingContext(
          source: v0Item.source,
          item: v0Item,
          groupMode: 'series',
        ),
      );

      final v1Bucket = genericLibraryBucketLabelBuilder(
        LibraryBucketingContext(
          source: v1Item.source,
          item: v1Item,
          groupMode: 'series',
        ),
      );

      expect(v0Bucket, 'Batman');
      expect(v1Bucket, 'Unknown series');
      expect(v0Bucket, isNot(v1Bucket));
    });

    test(
        'items with same seriesTitle share the same series bucket under the contract',
        () {
      final item1 =
          _makeItem('batman-123-1', seriesTitle: 'Batman', title: 'Batman #1');
      final item2 =
          _makeItem('batman-456-1', seriesTitle: 'Batman', title: 'Batman #1');

      final bucket1 = genericLibraryBucketLabelBuilder(
        LibraryBucketingContext(
          source: item1.source,
          item: item1,
          groupMode: 'series',
        ),
      );

      final bucket2 = genericLibraryBucketLabelBuilder(
        LibraryBucketingContext(
          source: item2.source,
          item: item2,
          groupMode: 'series',
        ),
      );

      expect(bucket1, 'Batman');
      expect(bucket2, 'Batman');
    });
  });
}
