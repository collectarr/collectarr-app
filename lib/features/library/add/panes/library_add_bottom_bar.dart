import 'package:collectarr_app/features/library/ui/primitives/library_collection_status_field.dart';
import 'library_add_status_button.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'library_add_pane_dependencies.dart';

class LibraryAddBottomBar extends StatelessWidget {
  const LibraryAddBottomBar({
    super.key,
    required this.request,
  });

  final LibraryAddBottomBarRequest request;

  Color get accent => request.accent;
  CatalogSearchCandidate? get selectedItem => request.selectedItem;
  LibraryAddTarget get addTarget => request.addTarget;
  int get addCount => request.addCount;
  bool get hasCheckedSelection => request.hasCheckedSelection;
  bool get isAdding => request.isAdding;
  VoidCallback? get onAdd => request.onAdd;

  @override
  Widget build(BuildContext context) {
    return _buildResponsiveMenu(context);
  }

  Widget _buildResponsiveMenu(BuildContext context) {
    final palette = appPalette(context);
    final hasSelection = hasCheckedSelection || selectedItem != null;
    final effectiveCount = addCount > 0 ? addCount : (hasSelection ? 1 : 0);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panel,
        border: Border(top: BorderSide(color: palette.divider)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          kLibraryDialogFooterHorizontalPadding,
          kLibraryDialogFooterVerticalPadding,
          kLibraryDialogFooterHorizontalPadding,
          kLibraryDialogFooterVerticalPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                LibraryAddResultBadge(
                    effectiveCount > 0
                        ? '$effectiveCount selected'
                        : '0 selected',
                    accent: accent),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: LibraryAddStatusButton(
                collectionStatus: addTarget == LibraryAddTarget.wishlist
                    ? LibraryCollectionStatusScope.wishList
                    : addTarget == LibraryAddTarget.track
                        ? LibraryCollectionStatusScope.notInCollection
                        : libraryCollectionStatusFromValue(
                            request.collectionStatus),
                isBusy: isAdding,
                onPrefillSettings: request.onPrefillSettings,
                onAdd: onAdd,
                onStatusChanged: request.onCollectionStatusChanged == null
                    ? null
                    : (status) => request.onCollectionStatusChanged!(
                        libraryCollectionStatusValue(status)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
