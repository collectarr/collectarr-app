import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';

sealed class ShelfPresentationEntry {
  const ShelfPresentationEntry({
    required this.id,
    required this.label,
  });

  final String id;
  final String label;
}

final class ItemShelfEntry extends ShelfPresentationEntry {
  ItemShelfEntry({required this.item})
      : super(
          id: item.entry.id,
          label: item.entry.resolvedTitle,
        );

  final LibraryProjectionItem item;
}

final class GroupShelfEntry extends ShelfPresentationEntry {
  GroupShelfEntry({
    required this.groupMode,
    required this.bucket,
    required this.presentation,
    required this.items,
    required this.representativeItem,
  }) : super(
      id: 'group:${libraryGroupModeStorageValue(groupMode)}:$bucket',
          label: bucket,
        );

  final String groupMode;
  final String bucket;
  final LibraryGroupPresentation presentation;
  final List<LibraryProjectionItem> items;
  final LibraryProjectionItem representativeItem;

  int get count => items.length;

  int get ownedCount =>
      items.where((item) => item.entry.isOwned).length;
}

final class FolderShelfEntry extends ShelfPresentationEntry {
  FolderShelfEntry({required this.group})
      : super(
          id: group.id,
          label: group.label,
        );

  factory FolderShelfEntry.fromGroup(GroupShelfEntry group) =>
      FolderShelfEntry(group: group);

  final GroupShelfEntry group;

  String get groupMode => group.groupMode;
  String get bucket => group.bucket;
  LibraryGroupPresentation get presentation => group.presentation;
  List<LibraryProjectionItem> get items => group.items;
  LibraryProjectionItem get representativeItem => group.representativeItem;
  int get count => group.count;
  int get ownedCount => group.ownedCount;
}
