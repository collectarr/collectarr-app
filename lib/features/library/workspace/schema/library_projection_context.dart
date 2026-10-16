import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';

/// How sort keys are chosen, from the Settings > Sorting preferences.
final class LibrarySortingOptions {
  const LibrarySortingOptions({
    this.useSortTitles = true,
    this.useSortNames = true,
  });

  /// Order titles by their sort title ("Wall, The") rather than as written.
  final bool useSortTitles;

  /// Order people and artists by their sort name ("Adams, Bryan").
  final bool useSortNames;

  @override
  bool operator ==(Object other) =>
      other is LibrarySortingOptions &&
      other.useSortTitles == useSortTitles &&
      other.useSortNames == useSortNames;

  @override
  int get hashCode => Object.hash(useSortTitles, useSortNames);
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
