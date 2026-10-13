import 'package:collectarr_app/features/library/inspector/library_duplicate_items.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_context.dart';

/// Deduplicates overlapping matches and always protects each group's oldest
/// entry. Explicitly kept groups protect all their entries, including overlaps.
List<LibraryWorkspaceContext> planDuplicateRemovals(
  List<LibraryDuplicateGroup> groups, {
  Set<String> keptGroupKeys = const {},
}) {
  final protected = <String>{};
  final candidates = <String, LibraryWorkspaceContext>{};
  for (final group in groups) {
    final entries = group.entries.where((entry) => entry.isEntry).toList()
      ..sort((a, b) {
        final left = a.addedAt;
        final right = b.addedAt;
        if (left != right) {
          if (left == null) return 1;
          if (right == null) return -1;
          final dateOrder = left.compareTo(right);
          if (dateOrder != 0) return dateOrder;
        }
        return a.libraryEntryRef!.key.compareTo(b.libraryEntryRef!.key);
      });
    if (entries.isEmpty) continue;
    protected.add(entries.first.libraryEntryRef!.key);
    if (keptGroupKeys.contains(group.key)) {
      protected.addAll(entries.map((entry) => entry.libraryEntryRef!.key));
    } else {
      for (final entry in entries.skip(1)) {
        candidates[entry.libraryEntryRef!.key] = entry;
      }
    }
  }
  return [
    for (final candidate in candidates.entries)
      if (!protected.contains(candidate.key)) candidate.value,
  ];
}
