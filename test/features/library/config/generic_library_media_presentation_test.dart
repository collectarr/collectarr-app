import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/generic_library_media_presentation.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('series bucketing with genericLibraryBucketLabelBuilder', () {
    test('groups by seriesTitle when available', () {
      final entry = LibraryWorkspaceEntry(
        id: 'comic-1',
        mediaType: 'comic',
        title: 'Batman: The Dark Knight #1',
        series: const CatalogSeriesDetails(
          seriesId: 'batman-dark-knight',
          seriesTitle: 'Batman: The Dark Knight',
        ),
        updatedAt: DateTime.now(),
      );

      final bucket = genericLibraryBucketLabelBuilder(
        LibraryBucketingContext(
          source: ShelfEntry(itemId: 'comic-1', catalogItem: null),
          entry: entry,
          groupMode: LibraryGroupMode.series,
        ),
      );

      expect(bucket, 'Batman: The Dark Knight');
    });

    test('uses unknown series when seriesTitle is missing', () {
      final entry = LibraryWorkspaceEntry(
        id: 'comic-2',
        mediaType: 'comic',
        title: 'Batman #50',
        series: null, // v1 item without series
        updatedAt: DateTime.now(),
      );

      final bucket = genericLibraryBucketLabelBuilder(
        LibraryBucketingContext(
          source: ShelfEntry(itemId: 'comic-2', catalogItem: null),
          entry: entry,
          groupMode: LibraryGroupMode.series,
        ),
      );

      expect(bucket, 'Unknown series');
    });

    test('uses unknown series when seriesTitle is empty', () {
      final entry = LibraryWorkspaceEntry(
        id: 'comic-3',
        mediaType: 'comic',
        title: 'Wonder Woman #1',
        series: const CatalogSeriesDetails(
          seriesId: 'ww-v1',
          seriesTitle: '', // Empty seriesTitle
        ),
        updatedAt: DateTime.now(),
      );

      final bucket = genericLibraryBucketLabelBuilder(
        LibraryBucketingContext(
          source: ShelfEntry(itemId: 'comic-3', catalogItem: null),
          entry: entry,
          groupMode: LibraryGroupMode.series,
        ),
      );

      expect(bucket, 'Unknown series');
    });

    test('uses unknown series when both seriesTitle and title are empty', () {
      final entry = LibraryWorkspaceEntry(
        id: 'comic-4',
        mediaType: 'comic',
        title: '',
        series: const CatalogSeriesDetails(
          seriesId: 'unknown-id',
          seriesTitle: '',
        ),
        updatedAt: DateTime.now(),
      );

      final bucket = genericLibraryBucketLabelBuilder(
        LibraryBucketingContext(
          source: ShelfEntry(itemId: 'comic-4', catalogItem: null),
          entry: entry,
          groupMode: LibraryGroupMode.series,
        ),
      );

      expect(bucket, 'Unknown series');
    });

    test('issue: duplicate series buckets when different series have same title',
        () {
      // This test demonstrates the reported issue:
      // Two items with different seriesIds but both titled "Batman"
      // should NOT be grouped into the same bucket if they have different series information

      // v0 item with series.seriesTitle
      final v0Item = LibraryWorkspaceEntry(
        id: 'batman-v0',
        mediaType: 'comic',
        title: 'Batman #1',
        displayTitle: 'Batman',
        series: const CatalogSeriesDetails(
          seriesId: 'batman-dark-knight-id',
          seriesTitle: 'Batman',
        ),
        updatedAt: DateTime.now(),
      );

      // v1 item WITHOUT series info, with title "Batman"
      // This falls back to resolvedTitle which would be "Batman"
      final v1Item = LibraryWorkspaceEntry(
        id: 'batman-v1',
        mediaType: 'comic',
        title: 'Batman #1',
        displayTitle: 'Batman',
        series: null,
        updatedAt: DateTime.now(),
      );

      final v0Bucket = genericLibraryBucketLabelBuilder(
        LibraryBucketingContext(
          source: ShelfEntry(itemId: 'batman-v0', catalogItem: null),
          entry: v0Item,
          groupMode: LibraryGroupMode.series,
        ),
      );

      final v1Bucket = genericLibraryBucketLabelBuilder(
        LibraryBucketingContext(
          source: ShelfEntry(itemId: 'batman-v1', catalogItem: null),
          entry: v1Item,
          groupMode: LibraryGroupMode.series,
        ),
      );

      expect(v0Bucket, 'Batman');
      expect(v1Bucket, 'Unknown series');
      expect(v0Bucket, isNot(v1Bucket));

      // This prevents duplicate series sections in the UI
    });

    test(
        'items with same seriesTitle share the same series bucket under the contract',
        () {

      // Series A: Batman, ID batman-123
      final item1 = LibraryWorkspaceEntry(
        id: 'batman-123-1',
        mediaType: 'comic',
        title: 'Batman #1',
        series: const CatalogSeriesDetails(
          seriesId: 'batman-123',
          seriesTitle: 'Batman',
        ),
        updatedAt: DateTime.now(),
      );

      // Series B: Batman, ID batman-456 (different series object, same title)
      final item2 = LibraryWorkspaceEntry(
        id: 'batman-456-1',
        mediaType: 'comic',
        title: 'Batman #1',
        series: const CatalogSeriesDetails(
          seriesId: 'batman-456',
          seriesTitle: 'Batman',
        ),
        updatedAt: DateTime.now(),
      );

      final bucket1 = genericLibraryBucketLabelBuilder(
        LibraryBucketingContext(
          source: ShelfEntry(itemId: 'batman-123-1', catalogItem: null),
          entry: item1,
          groupMode: LibraryGroupMode.series,
        ),
      );

      final bucket2 = genericLibraryBucketLabelBuilder(
        LibraryBucketingContext(
          source: ShelfEntry(itemId: 'batman-456-1', catalogItem: null),
          entry: item2,
          groupMode: LibraryGroupMode.series,
        ),
      );

      expect(bucket1, 'Batman');
      expect(bucket2, 'Batman');
    });
  });
}
