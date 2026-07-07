import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';

class LibraryLayoutSnapshot {
  const LibraryLayoutSnapshot({
    required this.sidebarWidth,
    required this.inspectorWidth,
    required this.detailsHeight,
    required this.coverSize,
    required this.isSidebarVisible,
    required this.detailsLayout,
  });

  final double sidebarWidth;
  final double inspectorWidth;
  final double detailsHeight;
  final double coverSize;
  final bool isSidebarVisible;
  final LibraryDetailsLayout detailsLayout;

  @override
  bool operator ==(Object other) {
    return other is LibraryLayoutSnapshot &&
        other.sidebarWidth == sidebarWidth &&
        other.inspectorWidth == inspectorWidth &&
        other.detailsHeight == detailsHeight &&
        other.coverSize == coverSize &&
        other.isSidebarVisible == isSidebarVisible &&
        other.detailsLayout == detailsLayout;
  }

  @override
  int get hashCode => Object.hash(
        sidebarWidth,
        inspectorWidth,
        detailsHeight,
        coverSize,
        isSidebarVisible,
        detailsLayout,
      );
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
