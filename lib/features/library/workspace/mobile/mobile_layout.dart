import 'package:collectarr_app/features/library/workspace/config/view_enums.dart';
import 'package:collectarr_app/features/library/workspace/entry/view_state.dart';
import 'package:collectarr_app/ui/adaptive/platform_layout.dart';
import 'package:flutter/widgets.dart';

/// From this smallest side a device is a tablet, in either orientation, as in
/// the reference; below it the app has a phone's single pane.
const kLibraryTabletPanesMinShortestSide = 720.0;

/// Whether the native app shows its three tablet panes. The reference's Force
/// Phone Layout keeps a large screen on the single phone pane.
bool libraryUsesTabletPanes(BuildContext context,
        {required bool forcePhoneLayout}) =>
    appPresentationPlatform.isNativeMobile &&
    !forcePhoneLayout &&
    MediaQuery.sizeOf(context).shortestSide >=
        kLibraryTabletPanesMinShortestSide;

/// A tablet's panes: in landscape folders, items and details side by side; in
/// portrait folders beside the items above the details. They start at the
/// reference's proportions until a divider is dragged, which stores a size
/// other than the kind's default.
class LibraryTabletPanes {
  factory LibraryTabletPanes.of(
    Size size, {
    required LibraryWorkspaceViewState viewState,
    required LibraryWorkspaceViewProfile profile,
  }) {
    final landscape = size.width > size.height;
    return LibraryTabletPanes._(
      detailsLayout:
          landscape ? LibraryDetailsLayout.right : LibraryDetailsLayout.bottom,
      sidebarWidth: viewState.sidebarWidth == profile.defaultSidebarWidth
          ? size.width * (landscape ? .23 : .33)
          : viewState.sidebarWidth,
      detailsWidth: viewState.detailsWidth == profile.defaultDetailsWidth
          ? size.width * .44
          : viewState.detailsWidth,
      detailsHeight: viewState.detailsHeight == profile.defaultDetailsHeight
          ? size.height * .5
          : viewState.detailsHeight,
    );
  }

  const LibraryTabletPanes._({
    required this.detailsLayout,
    required this.sidebarWidth,
    required this.detailsWidth,
    required this.detailsHeight,
  });

  final LibraryDetailsLayout detailsLayout;
  final double sidebarWidth;
  final double detailsWidth;
  final double detailsHeight;
}
