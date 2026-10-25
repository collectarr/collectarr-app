import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_collection_status_field.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/ui/app_dropdown_menu.dart';
import 'package:flutter/material.dart';

/// Main Add action with a separately selectable destination status.
class LibraryAddStatusButton extends StatelessWidget {
  const LibraryAddStatusButton({
    super.key,
    required this.collectionStatus,
    required this.onAdd,
    required this.onStatusChanged,
    this.isBusy = false,
    this.onPrefillSettings,
  });

  final LibraryCollectionStatusScope collectionStatus;
  final VoidCallback? onAdd;
  final ValueChanged<LibraryCollectionStatusScope>? onStatusChanged;
  final bool isBusy;
  final VoidCallback? onPrefillSettings;

  String get _label => switch (collectionStatus) {
        LibraryCollectionStatusScope.all ||
        LibraryCollectionStatusScope.inCollection =>
          'Add to Collection',
        LibraryCollectionStatusScope.forSale => 'Add as For Sale',
        LibraryCollectionStatusScope.wishList => 'Add to Wish List',
        LibraryCollectionStatusScope.onOrder => 'Add as On Order',
        LibraryCollectionStatusScope.sold => 'Add as Sold',
        LibraryCollectionStatusScope.notInCollection =>
          'Add as Not in Collection',
      };

  @override
  Widget build(BuildContext context) {
    final accent = collectionStatus.color;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Flexible(
          child: SizedBox(
              height: 40,
              child: FilledButton.icon(
                onPressed: isBusy ? null : onAdd,
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  disabledBackgroundColor: accent.withValues(alpha: 0.55),
                  disabledForegroundColor: Colors.white70,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.horizontal(left: Radius.circular(4))),
                  textStyle: TextStyle(
                      fontFamily: appFontFamily,
                      fontFamilyFallback: kAppFontFamilyFallback,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.25),
                ),
                icon: isBusy
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const SizedBox(
                        width: 20, child: Icon(AppIcons.add, size: 16)),
                label: Text(_label, overflow: TextOverflow.ellipsis),
              ))),
      PopupMenuButton<LibraryCollectionStatusScope>(
        popUpAnimationStyle: AnimationStyle.noAnimation,
        position: PopupMenuPosition.under,
        tooltip: 'Choose collection status',
        enabled: !isBusy && onStatusChanged != null,
        onSelected: onStatusChanged,
        menuPadding: EdgeInsets.zero,
        color: AppDropdownMenuStyle.of(context).background,
        surfaceTintColor: Colors.transparent,
        constraints: const BoxConstraints(minWidth: 190, maxWidth: 240),
        shape: AppDropdownMenuStyle.of(context).shape,
        itemBuilder: (context) => [
          ...libraryCollectionStatusEditMenuItems(context, rowHeight: 31),
          if (onPrefillSettings != null) ...[
            const PopupMenuDivider(height: 8),
            PopupMenuItem<LibraryCollectionStatusScope>(
              height: 30,
              onTap: () => Future<void>(onPrefillSettings!),
              child: const Text('Pre-fill Settings'),
            ),
          ],
        ],
        child: Container(
          width: 28,
          height: 40,
          decoration: BoxDecoration(
            color: accent,
            border: Border(
                left: BorderSide(color: Colors.black.withValues(alpha: 0.18))),
            borderRadius:
                const BorderRadius.horizontal(right: Radius.circular(4)),
          ),
          child: Icon(AppIcons.caretDown,
              color: isBusy ? Colors.white54 : Colors.white, size: 12),
        ),
      ),
    ]);
  }
}
