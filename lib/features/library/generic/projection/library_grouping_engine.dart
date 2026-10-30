import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_group_values.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_shelf_entry.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_bucket_sidebar.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_projection_context.dart';
import 'package:collectarr_app/features/pick_lists/models/pick_list_value.dart';

final _sequenceNumberRegExp = RegExp(r'^\s*(\d+)');

int? _parseWholeNumber(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final match = _sequenceNumberRegExp.firstMatch(value);
  return match == null ? null : int.tryParse(match.group(1)!);
}

class LibraryGroupingEngine {
  const LibraryGroupingEngine({
    this.gapAnalyzer = const LibrarySequenceGapAnalyzer(),
  });

  final LibrarySequenceGapAnalyzer gapAnalyzer;

  /// Representative bucket for callers that need a single label.
  String getGroupBucketForItem(LibraryProjectionItem item,
          LibraryKindRegistration type, LibraryGroupIdRuntime groupId) =>
      getGroupBucketsForItem(item, type, groupId).first;

  List<String> getGroupBucketsForItem(LibraryProjectionItem item,
      LibraryKindRegistration type, LibraryGroupIdRuntime groupId) {
    final workspace = libraryKindWorkspaceForKind(type.kind);
    final definition =
        workspace.fieldsForTarget(item.target).findGroupDefinition(groupId);
    if (definition != null) {
      final values =
          libraryGroupBucketValues(workspace.groupValue(item, definition.id));
      return values.isEmpty ? const [libraryEmptyGroupLabel] : values;
    }
    final values = libraryGroupBucketValues(
        workspace.groupValueAcrossTargets(item, groupId.value));
    if (values.isNotEmpty) return values;
    if (groupId.semantic == LibraryGroupSemantic.value) {
      return const [libraryEmptyGroupLabel];
    }
    return [
      libraryPresentationForKind(type.kind).bucketLabelBuilder(
          LibraryBucketingContext(
              source: item.source, item: item, groupId: groupId))
    ];
  }

  List<String> bucketsForItem(LibraryProjectionItem item,
          LibraryKindRegistration type, LibraryGroupIdRuntime groupId,
          {LibraryProjectionIndex? index}) =>
      index?.getGroupBuckets(item, groupId,
          (item, id) => getGroupBucketsForItem(item, type, id)) ??
      getGroupBucketsForItem(item, type, groupId);

  List<LibraryBucket> buildBuckets(
    List<LibraryProjectionItem> items,
    LibraryKindRegistration type,
    LibraryGroupIdRuntime groupId, {
    LibraryProjectionIndex? index,
    LibrarySortingOptions sorting = const LibrarySortingOptions(),
  }) {
    final workspace = libraryKindWorkspaceForKind(type.kind);
    final allBucketLabel = genericAllBucketLabel(type);
    final vocabulary =
        (workspace.fieldsForGroupModeAcrossTargets(groupId.value) ??
                workspace.fields)
            .findGroupDefinition(groupId)
            ?.bucketVocabulary;
    final pickListSortNames = sorting.useSortNames && vocabulary != null
        ? sorting.pickListSortNames[vocabulary.value] ??
            const <String, String>{}
        : const <String, String>{};
    final itemSortNames = <String, String>{};
    final counts = <String, int>{allBucketLabel: items.length};
    final hasSequence = workspace.groupModeSupportsCompletion(groupId);
    final entryCounts = hasSequence
        ? <String, int>{
            allBucketLabel: items.where((item) => item.source.isEntry).length,
          }
        : null;
    final coverUrls = <String, String?>{};
    // A numbered folder shows its lowest number's cover, as the reference
    // shows a series' first issue, whatever the item order.
    final coverNumbers = <String, int>{};
    final startYears = <String, int?>{};
    final bucketNumbers = hasSequence ? <String, Set<int>>{} : null;
    final entryNumbers = hasSequence ? <String, Set<int>>{} : null;

    for (final item in items) {
      final sortNames = sorting.useSortNames
          ? workspace.groupBucketSortNamesForEntry(item, groupId)
          : const <String, String>{};
      for (final bucket in bucketsForItem(item, type, groupId, index: index)) {
        counts[bucket] = (counts[bucket] ?? 0) + 1;
        if (sortNames[bucket] case final sortName?
            when sortName.trim().isNotEmpty) {
          itemSortNames.putIfAbsent(bucket, () => sortName.trim());
        }
        final number = hasSequence
            ? _parseWholeNumber(
                workspace.groupSequenceValueForEntry(item, groupId),
              )
            : null;
        if (number != null) {
          bucketNumbers!.putIfAbsent(bucket, () => <int>{}).add(number);
        }
        if (hasSequence && item.source.isEntry) {
          entryCounts![bucket] = (entryCounts[bucket] ?? 0) + 1;
          if (number != null) {
            entryNumbers!.putIfAbsent(bucket, () => <int>{}).add(number);
          }
        }
        final imageUrl = item.dto.imageUrl;
        if (imageUrl != null && imageUrl.isNotEmpty) {
          final coverNumber = coverNumbers[bucket];
          if (coverUrls[bucket] == null ||
              (number != null &&
                  (coverNumber == null || number < coverNumber))) {
            coverUrls[bucket] = imageUrl;
            if (number != null) coverNumbers[bucket] = number;
          }
        } else {
          coverUrls.putIfAbsent(bucket, () => null);
        }
        final year = libraryCardPresentationForEntry(item).releaseDate?.year;
        if (year != null) {
          final existing = startYears[bucket];
          if (existing == null || year < existing) {
            startYears[bucket] = year;
          }
        }
      }
    }

    final gapNumbers = <String, List<int>>{};
    if (entryNumbers != null && bucketNumbers != null) {
      for (final entry in entryNumbers.entries) {
        final existing = bucketNumbers[entry.key];
        if (existing != null) {
          final missing = gapAnalyzer.calculateGapsForBucket(
            entryNumbers: entry.value,
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
          entryCount: entryCounts?[entry.key],
          missingNumbers: gapNumbers[entry.key] ?? const <int>[],
          sortKey: pickListSortNames[normalizePickListValue(entry.key)] ??
              itemSortNames[entry.key],
        ),
    ];

    buckets.sort((a, b) {
      if (a.title == allBucketLabel) {
        return -1;
      }
      if (b.title == allBucketLabel) {
        return 1;
      }
      return compareLibraryGroupBuckets(a.title, b.title,
          firstSortKey: a.sortKey, secondSortKey: b.sortKey);
    });

    return buckets;
  }

  List<GroupShelfEntry> buildGroupEntries(
    List<LibraryProjectionItem> items,
    LibraryKindRegistration type,
    LibraryGroupIdRuntime groupId, {
    LibraryGroupPresentation? presentationOverride,
    LibraryProjectionIndex? index,
  }) {
    final grouped = <String, List<LibraryProjectionItem>>{};
    final presentation = presentationOverride ??
        genericGroupPresentationForMode(groupId.value, type);

    for (final item in items) {
      for (final bucket in bucketsForItem(item, type, groupId, index: index)) {
        (grouped[bucket] ??= []).add(item);
      }
    }

    final sortedBuckets = grouped.keys.toList()
      ..sort(compareLibraryGroupBuckets);
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
