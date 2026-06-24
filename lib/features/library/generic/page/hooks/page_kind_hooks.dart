part of '../../page.dart';

extension _PageKindHooks on GenericLibraryPageState {
  LibraryMediaAdapter get _adapter =>
      collectarrMediaAdapters.byKind(widget.type.workspace.kind) ??
      plannedMediaAdapter(widget.type);

  bool get _supportsMusicTrackSearch =>
      widget.type.workspace.kind == CatalogMediaKind.music;

  LibrarySearchTarget get _effectiveSearchTarget =>
      _supportsMusicTrackSearch ? _searchTarget : LibrarySearchTarget.all;

  LibraryViewPreferenceStore get _viewPrefs =>
      LibraryViewPreferenceStore(widget.type.workspace.kind);
}
