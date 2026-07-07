import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';

class LibraryLayoutSnapshot {
  const LibraryLayoutSnapshot({
    required this.sidebarWidth,
    required this.inspectorWidth,
    required this.detailsHeight,
    required this.toolbarHeight,
    required this.coverSize,
    required this.gridColumnCount,
    required this.isSidebarVisible,
    required this.detailsLayout,
  });

  final double sidebarWidth;
  final double inspectorWidth;
  final double detailsHeight;
  final double toolbarHeight;
  final double coverSize;
  final int gridColumnCount;
  final bool isSidebarVisible;
  final LibraryDetailsLayout detailsLayout;
}

extension LibraryLayoutSnapshotViewState on LibraryWorkspaceViewState {
  LibraryWorkspaceViewState withLayoutSnapshot(LibraryLayoutSnapshot snapshot) {
    return copyWith(
      sidebarWidth: snapshot.sidebarWidth,
      detailsWidth: snapshot.inspectorWidth,
      detailsHeight: snapshot.detailsHeight,
      coverSize: snapshot.coverSize,
      isSidebarVisible: snapshot.isSidebarVisible,
      detailsLayout: snapshot.detailsLayout,
    );
  }
}
