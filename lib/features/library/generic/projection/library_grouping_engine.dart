import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_shelf_entry.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_series_sidebar.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final _issueNumberRegExp = RegExp(r'^\s*(\d+)');

int? _parseWholeNumber(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final match = _issueNumberRegExp.firstMatch(value);
  return match == null ? null : int.tryParse(match.group(1)!);
}

class LibraryGroupingEngine {
  const LibraryGroupingEngine({
    this.gapAnalyzer = const LibrarySeriesGapAnalyzer(),
  });

  final LibrarySeriesGapAnalyzer gapAnalyzer;

  String getGroupBucketForItem(
    LibraryProjectionItem item,
    LibraryTypeConfig type,
    String groupMode,
  ) {
    return type.presentation.bucketLabelBuilder(
      LibraryBucketingContext(
        source: item.source,
        item: item,
        groupMode: groupMode,
      ),
    );
  }

  List<LibrarySeriesBucket> buildBuckets(
    List<LibraryProjectionItem> items,
    LibraryTypeConfig type,
    String groupMode, {
    LibraryProjectionIndex? index,
  }) {
    final allBucketLabel = genericAllBucketLabel(type);
    final counts = <String, int>{allBucketLabel: items.length};
    final isSeries = groupMode == 'series';
    final ownedCounts = isSeries
        ? <String, int>{
            allBucketLabel: items.where((item) => item.source.isOwned).length,
          }
        : null;
    final coverUrls = <String, String?>{};
    final startYears = <String, int?>{};
    final bucketNumbers = isSeries ? <String, Set<int>>{} : null;
    final ownedNumbers = isSeries ? <String, Set<int>>{} : null;

    for (final item in items) {
      final bucket = index != null
          ? index.getGroupBucket(
              item,
              groupMode,
              (it, mode) => getGroupBucketForItem(it, type, mode),
            )
          : getGroupBucketForItem(item, type, groupMode);

      counts[bucket] = (counts[bucket] ?? 0) + 1;
      final adapter = item.dto is WorkspaceDtoAdapter ? item.dto as WorkspaceDtoAdapter : null;
      final itemNumber = adapter?.itemNumber;
      final number = isSeries ? _parseWholeNumber(itemNumber) : null;
      if (number != null) {
        bucketNumbers!.putIfAbsent(bucket, () => <int>{}).add(number);
      }
      if (isSeries && item.source.isOwned) {
        ownedCounts![bucket] = (ownedCounts[bucket] ?? 0) + 1;
        if (number != null) {
          ownedNumbers!.putIfAbsent(bucket, () => <int>{}).add(number);
        }
      }
      if (!coverUrls.containsKey(bucket)) {
        coverUrls[bucket] = item.dto.coverImageUrl;
      }
      final year = adapter?.releaseDate?.year ?? item.source.catalogItem?.releaseDate?.year;
      if (year != null) {
        final existing = startYears[bucket];
        if (existing == null || year < existing) {
          startYears[bucket] = year;
        }
      }
    }

    final gapNumbers = <String, List<int>>{};
    if (ownedNumbers != null && bucketNumbers != null) {
      for (final entry in ownedNumbers.entries) {
        final existing = bucketNumbers[entry.key];
        if (existing != null) {
          final missing = gapAnalyzer.calculateGapsForBucket(
            ownedNumbers: entry.value,
            bucketNumbers: existing,
          );
          if (missing.isNotEmpty) {
            gapNumbers[entry.key] = missing;
          }
        }
      }
    }

    final buckets = [
      for (final entry in counts.entries)
        LibrarySeriesBucket(
          title: entry.key,
          count: entry.value,
          coverUrl: coverUrls[entry.key],
          startYear: startYears[entry.key],
          ownedCount: ownedCounts?[entry.key],
          missingNumbers: gapNumbers[entry.key] ?? const <int>[],
        ),
    ];

    buckets.sort((a, b) {
      if (a.title == allBucketLabel) {
        return -1;
      }
      if (b.title == allBucketLabel) {
        return 1;
      }
      return a.title.compareTo(b.title);
    });

    return buckets;
  }

  List<GroupShelfEntry> buildGroupEntries(
    List<LibraryProjectionItem> items,
    LibraryTypeConfig type,
    String groupMode, {
    LibraryGroupPresentation? presentationOverride,
    LibraryProjectionIndex? index,
  }) {
    final grouped = <String, List<LibraryProjectionItem>>{};
    final presentation = presentationOverride ??
        genericGroupPresentationForMode(groupMode, type);

    for (final item in items) {
      final bucket = index != null
          ? index.getGroupBucket(
              item,
              groupMode,
              (it, mode) => getGroupBucketForItem(it, type, mode),
            )
          : getGroupBucketForItem(item, type, groupMode);
      (grouped[bucket] ??= []).add(item);
    }

    final sortedBuckets = grouped.keys.toList()..sort();
    return [
      for (final bucket in sortedBuckets)
        GroupShelfEntry(
          groupMode: groupMode,
          bucket: bucket,
          presentation: presentation,
          items: List<LibraryProjectionItem>.unmodifiable(grouped[bucket]!),
          representativeItem: grouped[bucket]!.first,
        ),
    ];
  }
}
