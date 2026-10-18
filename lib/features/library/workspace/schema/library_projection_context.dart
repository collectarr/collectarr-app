import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';

/// How sort keys are chosen, from the Settings > Sorting preferences.
final class LibrarySortingOptions {
  const LibrarySortingOptions({
    this.useSortTitles = true,
    this.useSortNames = true,
    this.pickListSortNames = const {},
  });

  /// Order titles by their sort title ("Wall, The") rather than as written.
  final bool useSortTitles;

  /// Order people and artists by their sort name ("Adams, Bryan").
  final bool useSortNames;

  /// Sort Names set in Manage Pick Lists, by list name and then by normalized
  /// value. Folders of a pick-list field are ordered by them.
  final Map<String, Map<String, String>> pickListSortNames;

  @override
  bool operator ==(Object other) =>
      other is LibrarySortingOptions &&
      other.useSortTitles == useSortTitles &&
      other.useSortNames == useSortNames &&
      _nestedMapEquals(other.pickListSortNames, pickListSortNames);

  @override
  int get hashCode => Object.hash(
        useSortTitles,
        useSortNames,
        Object.hashAllUnordered([
          for (final list in pickListSortNames.entries)
            Object.hash(
              list.key,
              Object.hashAllUnordered([
                for (final value in list.value.entries)
                  Object.hash(value.key, value.value),
              ]),
            ),
        ]),
      );
}

bool _nestedMapEquals(
  Map<String, Map<String, String>> left,
  Map<String, Map<String, String>> right,
) {
  if (identical(left, right)) return true;
  if (left.length != right.length) return false;
  for (final entry in left.entries) {
    final other = right[entry.key];
    if (other == null || other.length != entry.value.length) return false;
    for (final value in entry.value.entries) {
      if (other[value.key] != value.value) return false;
    }
  }
  return true;
}

/// Context exposing the workspace row's two owners and kind-specific DTO.
final class LibraryProjectionContext<TDto extends LibraryWorkspaceDto> {
  const LibraryProjectionContext({
    required this.item,
    required this.personal,
    required this.dto,
    this.sorting = const LibrarySortingOptions(),
  });

  final WorkspaceItem item;
  final PersonalOverlay personal;
  final TDto dto;
  final LibrarySortingOptions sorting;

  DateTime get updatedAt {
    final entryUpdatedAt = item.entrySummary?.updatedAt;
    final personalUpdatedAt = personal.updatedAt;
    if (entryUpdatedAt == null || !entryUpdatedAt.isAfter(personalUpdatedAt)) {
      return personalUpdatedAt;
    }
    return entryUpdatedAt;
  }

  DateTime? get addedAt =>
      item.entrySummary?.createdAt ?? personal.wishlist?.createdAt;
}
