import 'package:collectarr_app/ui/adaptive/platform_layout.dart';
import 'package:flutter/widgets.dart';

/// From this width a tablet shows folders, items and details side by side,
/// as in the reference; below it the app has a phone's single pane.
const kLibraryTabletPanesMinWidth = 1000.0;

/// Whether the native app shows its three tablet panes. The reference's Force
/// Phone Layout keeps a large screen on the single phone pane.
bool libraryUsesTabletPanes(BuildContext context,
        {required bool forcePhoneLayout}) =>
    appPresentationPlatform.isNativeMobile &&
    !forcePhoneLayout &&
    MediaQuery.sizeOf(context).width >= kLibraryTabletPanesMinWidth;
