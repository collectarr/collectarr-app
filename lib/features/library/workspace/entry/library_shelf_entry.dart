import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';

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
          id: 'group:${groupMode.name}:$bucket',
          label: bucket,
        );

  final LibraryGroupMode groupMode;
  final String bucket;
  final LibraryGroupPresentation presentation;
  final List<LibraryProjectionItem> items;
  final LibraryProjectionItem representativeItem;

  int get count => items.length;

  int get ownedCount =>
      items.where((item) => item.entry.isOwned).length;
}
