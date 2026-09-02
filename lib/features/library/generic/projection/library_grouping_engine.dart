import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_shelf_entry.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_bucket_sidebar.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final _issueNumberRegExp = RegExp(r'^\s*(\d+)');

int? _parseWholeNumber(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final match = _issueNumberRegExp.firstMatch(value);
  return match == null ? null : int.tryParse(match.group(1)!);
}

class LibraryGroupingEngine {
  const LibraryGroupingEngine({
    this.gapAnalyzer = const LibrarySequenceGapAnalyzer(),
  });

  final LibrarySequenceGapAnalyzer gapAnalyzer;

  String getGroupBucketForItem(
    LibraryProjectionItem item,
    LibraryKindRuntime type,
    LibraryGroupIdRuntime groupId,
  ) {
    final runtime = type;
    final groupDefinition = runtime.fields.findGroupDefinition(
      groupId,
    );
    if (groupDefinition != null) {
      final value = runtime.groupValue(item, groupDefinition.id);
      final normalizedValue = value?.toString().trim();
      if (normalizedValue != null && normalizedValue.isNotEmpty) {
        return normalizedValue;
      }
    }
    return type.presentation.bucketLabelBuilder(
      LibraryBucketingContext(
        source: item.source,
        item: item,
        groupId: groupId,
      ),
    );
  }

  List<LibraryBucket> buildBuckets(
    List<LibraryProjectionItem> items,
    LibraryKindRuntime type,
    LibraryGroupIdRuntime groupId, {
    LibraryProjectionIndex? index,
  }) {
    final runtime = type;
    final allBucketLabel = genericAllBucketLabel(type);
    final counts = <String, int>{allBucketLabel: items.length};
    final hasSequence = runtime.groupModeSupportsCompletion(groupId);
    final ownedCounts = hasSequence
        ? <String, int>{
            allBucketLabel: items.where((item) => item.source.isOwned).length,
          }
        : null;
    final coverUrls = <String, String?>{};
    final startYears = <String, int?>{};
    final bucketNumbers = hasSequence ? <String, Set<int>>{} : null;
    final ownedNumbers = hasSequence ? <String, Set<int>>{} : null;

    for (final item in items) {
      final bucket = index != null
          ? index.getGroupBucket(
              item,
              groupId,
              (it, mode) => getGroupBucketForItem(it, type, mode),
            )
          : getGroupBucketForItem(item, type, groupId);

      counts[bucket] = (counts[bucket] ?? 0) + 1;
      final number = hasSequence
          ? _parseWholeNumber(
              runtime.groupSequenceValueForEntry(item, groupId),
            )
          : null;
      if (number != null) {
        bucketNumbers!.putIfAbsent(bucket, () => <int>{}).add(number);
      }
      if (hasSequence && item.source.isOwned) {
        ownedCounts![bucket] = (ownedCounts[bucket] ?? 0) + 1;
        if (number != null) {
          ownedNumbers!.putIfAbsent(bucket, () => <int>{}).add(number);
        }
      }
      if (!coverUrls.containsKey(bucket)) {
        coverUrls[bucket] = item.dto.coverImageUrl;
      }
      final adapter = item.dto is WorkspaceDtoAdapter
          ? item.dto as WorkspaceDtoAdapter
          : null;
      final year = adapter?.releaseDate?.year ??
          item.source.catalogItem?.releaseDate?.year;
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
        LibraryBucket(
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
    LibraryKindRuntime type,
    LibraryGroupIdRuntime groupId, {
    LibraryGroupPresentation? presentationOverride,
    LibraryProjectionIndex? index,
  }) {
    final grouped = <String, List<LibraryProjectionItem>>{};
    final presentation = presentationOverride ??
        genericGroupPresentationForMode(groupId.value, type);

    for (final item in items) {
      final bucket = index != null
          ? index.getGroupBucket(
              item,
              groupId,
              (it, mode) => getGroupBucketForItem(it, type, mode),
            )
          : getGroupBucketForItem(item, type, groupId);
      (grouped[bucket] ??= []).add(item);
    }

    final sortedBuckets = grouped.keys.toList()..sort();
    return [
      for (final bucket in sortedBuckets)
        GroupShelfEntry(
          groupMode: groupId.value,
          bucket: bucket,
          presentation: presentation,
          items: List<LibraryProjectionItem>.unmodifiable(grouped[bucket]!),
          representativeItem: grouped[bucket]!.first,
        ),
    ];
  }
}
