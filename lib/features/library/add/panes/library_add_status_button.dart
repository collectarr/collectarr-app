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
  });

  final LibraryCollectionStatusScope collectionStatus;
  final VoidCallback? onAdd;
  final ValueChanged<LibraryCollectionStatusScope>? onStatusChanged;
  final bool isBusy;

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
    const blue = Color(0xFF5BB0DA);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Flexible(
          child: SizedBox(
              height: 34,
              child: FilledButton.icon(
                onPressed: isBusy ? null : onAdd,
                style: FilledButton.styleFrom(
                  backgroundColor: blue,
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
        tooltip: 'Choose collection status',
        enabled: !isBusy && onStatusChanged != null,
        onSelected: onStatusChanged,
        menuPadding: const EdgeInsets.symmetric(vertical: 6),
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF444444)
            : palette.panelRaised,
        surfaceTintColor: Colors.transparent,
        constraints: const BoxConstraints(minWidth: 200, maxWidth: 240),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3),
            side: BorderSide(color: palette.divider)),
        itemBuilder: libraryCollectionStatusMenuItems,
        child: Container(
          width: 30,
          height: 34,
          decoration: const BoxDecoration(
            color: Color(0xFF24658B),
            borderRadius: BorderRadius.horizontal(right: Radius.circular(3)),
          ),
          child: Icon(Icons.arrow_drop_down,
              color: isBusy ? Colors.white54 : Colors.white, size: 24),
        ),
      ),
    ]);
  }
}
