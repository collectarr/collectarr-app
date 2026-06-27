import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/generic_library_media_presentation.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/registry/planned_media_adapters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('series bucketing with genericLibraryBucketLabelBuilder', () {
    test('groups by seriesTitle when available (v0 items)', () {
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

      // With seriesId present, bucket key includes ID for uniqueness
      expect(bucket, 'Batman: The Dark Knight|batman-dark-knight');
    });

    test('falls back to resolvedTitle when seriesTitle is null (v1 items)', () {
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

      expect(bucket, 'Batman #50');
    });

    test('falls back to resolvedTitle when seriesTitle is empty', () {
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

      // With seriesId but empty title, use id: prefix
      expect(bucket, 'id:ww-v1');
    });

    test('uses unknownLabel when both seriesTitle and title are empty', () {
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

      // With seriesId but no title, use id: prefix
      expect(bucket, 'id:unknown-id');
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

      // With the fix, v0 item includes seriesId making it unique
      expect(v0Bucket, 'Batman|batman-dark-knight-id');
      expect(v1Bucket, 'Batman');
      expect(v0Bucket, isNot(v1Bucket));

      // This prevents duplicate series sections in the UI
    });

    test(
        'items with same seriesTitle but different seriesIds should be in separate buckets',
        () {
      // Two different series with the same title should appear as separate buckets
      // when they have different seriesIds

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

      // Now they should have different bucket keys (with seriesId included)
      // to prevent duplicate series sections
      expect(bucket1, 'Batman|batman-123');
      expect(bucket2, 'Batman|batman-456');
      expect(bucket1, isNot(bucket2));
    });
  });
}
