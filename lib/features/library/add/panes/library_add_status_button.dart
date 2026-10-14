import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_collection_status_field.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
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
    final palette = appPalette(context);
    final accent = LibraryAccentScope.accentOf(context);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Flexible(
          child: SizedBox(
              height: 34,
              child: FilledButton.icon(
                onPressed: isBusy ? null : onAdd,
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.horizontal(left: Radius.circular(3))),
                  textStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                icon: isBusy
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.add, size: 20),
                label: Text(_label, overflow: TextOverflow.ellipsis),
              ))),
      PopupMenuButton<LibraryCollectionStatusScope>(
        popUpAnimationStyle: AnimationStyle.noAnimation,
        position: PopupMenuPosition.under,
        tooltip: 'Choose collection status',
        enabled: !isBusy && onStatusChanged != null,
        onSelected: onStatusChanged,
        menuPadding: EdgeInsets.zero,
        color: palette.panelRaised,
        surfaceTintColor: Colors.transparent,
        constraints: const BoxConstraints(minWidth: 190, maxWidth: 240),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(color: palette.divider)),
        itemBuilder: (context) => [
          ...libraryCollectionStatusEditMenuItems(context,
              rowHeight: 31, verticalPadding: 4),
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
          width: 30,
          height: 34,
          decoration: BoxDecoration(
            color: accent,
            borderRadius:
                const BorderRadius.horizontal(right: Radius.circular(3)),
          ),
          child: Icon(Icons.arrow_drop_down,
              color: isBusy ? Colors.white54 : Colors.white, size: 24),
        ),
      ),
    ]);
  }
}
