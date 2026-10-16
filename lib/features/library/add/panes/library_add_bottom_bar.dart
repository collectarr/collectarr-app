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
    return Container(
      color: palette.isDark ? const Color(0xff383838) : palette.panelRaised,
      padding: const EdgeInsets.all(7),
      child: Row(
        children: [
          if (hasCheckedSelection)
            Text(
              '$addCount selected',
              key: const ValueKey('library-add-selected-count'),
              style: TextStyle(color: palette.textPrimary, fontSize: 14),
            ),
          const Spacer(),
          LibraryAddStatusButton(
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
        ],
      ),
    );
  }
}
