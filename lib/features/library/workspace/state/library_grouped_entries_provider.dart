import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'library_workspace_key.dart';
import 'library_filter_state.dart';
import 'library_filters_provider.dart';
import 'library_display_provider.dart';

/// A single group bucket: the label that identifies the group and the
/// entries that belong to it.
class LibraryGroupBucket {
  const LibraryGroupBucket({
    required this.key,
    required this.label,
    required this.entries,
  });

  /// The raw bucket key produced by the group definition (e.g. a series title
  /// or the first letter of the title). Stable as a map key / scroll anchor.
  final String key;

  /// Human-readable label shown in section headers.
  final String label;

  final List<LibraryWorkspaceEntry> entries;

  int get count => entries.length;
  bool get isEmpty => entries.isEmpty;
}

/// Derives the grouped display list for the given workspace scope.
///
/// - Groups entries according to [LibraryFilterState.groupId].
/// - Falls back to a single "All" bucket when no group is active or the group
///   definition is not found.
/// - Known groups are sorted lexicographically; "Unknown" appended at end.
/// - Re-emits whenever [libraryDisplayListProvider] re-emits (data or filter
///   change).
final libraryGroupedEntriesProvider = StreamProvider.autoDispose
    .family<List<LibraryGroupBucket>, LibraryWorkspaceKey>((ref, key) {
  final controller = StreamController<List<LibraryGroupBucket>>();

  void emit(List<LibraryWorkspaceEntry> entries) {
    final filters = ref.read(libraryFiltersProvider(key));
    final module = libraryKindModuleForKind(key.kind);
    final groupId = filters.groupId;

    if (groupId == null) {
      controller.add([
        LibraryGroupBucket(key: '_all', label: 'All', entries: entries),
      ]);
      return;
    }

    final groupDef = module.fields.groupDefinitionForId(groupId);
    if (groupDef == null) {
      controller.add([
        LibraryGroupBucket(key: '_all', label: 'All', entries: entries),
      ]);
      return;
    }

    // Group entries by the bucket key returned by the group definition.
    final bucketMap = <String, List<LibraryWorkspaceEntry>>{};
    for (final entry in entries) {
      final raw = groupDef.getValue(entry);
      final bucketKey = _bucketKeyFor(raw);
      bucketMap.putIfAbsent(bucketKey, () => []).add(entry);
    }

    const unknownKey = '';
    final sortedKeys = bucketMap.keys
        .where((k) => k != unknownKey)
        .toList(growable: false)
      ..sort();

    final buckets = <LibraryGroupBucket>[
      for (final k in sortedKeys)
        LibraryGroupBucket(key: k, label: k, entries: bucketMap[k]!),
      if (bucketMap.containsKey(unknownKey))
        LibraryGroupBucket(
            key: unknownKey,
            label: 'Unknown',
            entries: bucketMap[unknownKey]!),
    ];

    controller.add(buckets);
  }

  // Emit when the display list changes.
  final listenerEntries = ref.listen<AsyncValue<List<LibraryWorkspaceEntry>>>(
    libraryDisplayListProvider(key),
    (_, next) {
      next.whenData(emit);
    },
    fireImmediately: true,
  );

  // Also re-emit when groupId changes (filter state change alone doesn't
  // change the entry list, but changes how entries are grouped).
  final listenerGroup = ref.listen<LibraryFilterState>(
    libraryFiltersProvider(key),
    (previous, next) {
      if (previous?.groupId != next.groupId) {
        final current = ref.read(libraryDisplayListProvider(key));
        current.whenData(emit);
      }
    },
  );

  ref.onDispose(() {
    listenerEntries.close();
    listenerGroup.close();
    controller.close();
  });

  return controller.stream;
});

String _bucketKeyFor(Object? raw) {
  if (raw == null) return '';
  if (raw is String) return raw.trim().isEmpty ? '' : raw.trim();
  return raw.toString();
}
