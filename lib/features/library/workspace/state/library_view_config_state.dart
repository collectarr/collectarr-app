import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';

/// Immutable state for workspace visual configuration (view mode, cover size,
/// details layout, sidebar visibility). Separate from [LibraryFilterState]
/// which owns sort/group/filter/column choices.
class LibraryViewConfigState {
  const LibraryViewConfigState({
    this.viewMode = LibraryViewMode.grid,
    this.detailsLayout = LibraryDetailsLayout.bottom,
    this.coverSize = 128.0,
    this.densityPreset = LibraryWorkspaceDensityPreset.compact,
    this.isSidebarVisible = true,
    this.sidebarWidth = 240.0,
    this.detailsWidth = 320.0,
    this.detailsHeight = 280.0,
    this.columnWidths = const {},
  });

  final LibraryViewMode viewMode;
  final LibraryDetailsLayout detailsLayout;
  final double coverSize;
  final LibraryWorkspaceDensityPreset densityPreset;
  final bool isSidebarVisible;
  final double sidebarWidth;
  final double detailsWidth;
  final double detailsHeight;
  /// Maps stable column ID → pixel width override. Empty = all defaults.
  final Map<String, double> columnWidths;

  LibraryViewConfigState copyWith({
    LibraryViewMode? viewMode,
    LibraryDetailsLayout? detailsLayout,
    double? coverSize,
    LibraryWorkspaceDensityPreset? densityPreset,
    bool? isSidebarVisible,
    double? sidebarWidth,
    double? detailsWidth,
    double? detailsHeight,
    Map<String, double>? columnWidths,
  }) {
    return LibraryViewConfigState(
      viewMode: viewMode ?? this.viewMode,
      detailsLayout: detailsLayout ?? this.detailsLayout,
      coverSize: coverSize ?? this.coverSize,
      densityPreset: densityPreset ?? this.densityPreset,
      isSidebarVisible: isSidebarVisible ?? this.isSidebarVisible,
      sidebarWidth: sidebarWidth ?? this.sidebarWidth,
      detailsWidth: detailsWidth ?? this.detailsWidth,
      detailsHeight: detailsHeight ?? this.detailsHeight,
      columnWidths: columnWidths ?? this.columnWidths,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryViewConfigState &&
          runtimeType == other.runtimeType &&
          viewMode == other.viewMode &&
          detailsLayout == other.detailsLayout &&
          coverSize == other.coverSize &&
          densityPreset == other.densityPreset &&
          isSidebarVisible == other.isSidebarVisible &&
          sidebarWidth == other.sidebarWidth &&
          detailsWidth == other.detailsWidth &&
          detailsHeight == other.detailsHeight &&
          _mapEquals(columnWidths, other.columnWidths);

  @override
  int get hashCode =>
      viewMode.hashCode ^
      detailsLayout.hashCode ^
      coverSize.hashCode ^
      densityPreset.hashCode ^
      isSidebarVisible.hashCode ^
      sidebarWidth.hashCode ^
      detailsWidth.hashCode ^
      detailsHeight.hashCode ^
      columnWidths.hashCode;
}

bool _mapEquals<K, V>(Map<K, V> a, Map<K, V> b) {
  if (a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key) || b[key] != a[key]) return false;
  }
  return true;
}
