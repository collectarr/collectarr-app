import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/detail/library_detail_page.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/ui/adaptive/window_class.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Opens item detail presentation adaptively:
/// - On compact/mobile viewports: Pushes a dedicated full-screen page route.
/// - On medium/expanded viewports: Shows a modal or embedded presentation.
Future<void> showAdaptiveItemDetail({
  required BuildContext context,
  required LibraryKindRuntime type,
  required LibraryProjectionRuntime item,
  required OwnedItem? ownedItem,
  required Color accent,
  required VoidCallback? onAddOwned,
  required VoidCallback? onRemoveOwned,
  required VoidCallback? onAddWishlist,
  required VoidCallback? onRemoveWishlist,
  required void Function(OwnedItem? ownedItem)? onEdit,
  ValueChanged<String>? onFilterByValue,
}) {
  final windowClass = AppWindowClass.of(context);
  final title = item.source.catalogItem?.title ?? type.identity.singularLabel;
  final kind = LibraryAccentScope.of(context).kind;

  if (windowClass.isCompact) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (pageContext) => LibraryAccentScope(
          kind: kind,
          accent: accent,
          animationsEnabled: true,
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back',
                onPressed: () => Navigator.of(pageContext).pop(),
              ),
              actions: [
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Edit item',
                    onPressed: () => onEdit(ownedItem),
                  ),
              ],
            ),
            body: LibraryDetailPage(
              type: type,
              item: item,
              ownedItem: ownedItem,
              accent: accent,
              onAddOwned: onAddOwned,
              onRemoveOwned: onRemoveOwned,
              onAddWishlist: onAddWishlist,
              onRemoveWishlist: onRemoveWishlist,
              onEdit: onEdit,
              onFilterByValue: onFilterByValue,
            ),
          ),
        ),
      ),
    );
  } else {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: appPalette(context).surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => LibraryAccentScope(
        kind: kind,
        accent: accent,
        animationsEnabled: true,
        child: SizedBox(
          height: MediaQuery.of(sheetContext).size.height * 0.85,
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(sheetContext).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: LibraryDetailPage(
                  type: type,
                  item: item,
                  ownedItem: ownedItem,
                  accent: accent,
                  onAddOwned: onAddOwned,
                  onRemoveOwned: onRemoveOwned,
                  onAddWishlist: onAddWishlist,
                  onRemoveWishlist: onRemoveWishlist,
                  onEdit: onEdit,
                  onFilterByValue: onFilterByValue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
