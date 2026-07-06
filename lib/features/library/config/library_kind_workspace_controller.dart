import 'package:collectarr_app/features/library/config/library_kind_browser_delegate.dart';

class LibraryKindWorkspaceController extends LibraryReleaseFolderBrowserDelegate {
  LibraryKindWorkspaceController({super.initialReleaseFolderTitleItemId});

  void closeAllKindDrilldowns() {
    closeReleaseFolder();
    closeVideoShelfDrilldown();
  }
}
