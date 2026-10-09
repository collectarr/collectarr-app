part of '../generic_library_page.dart';

extension _PageKindHooks on GenericLibraryPageState {
  LibraryWorkspaceViewProfile get _viewProfile =>
      libraryViewProfileForKind(widget.type.kind);

  LibrarySearchTarget get _effectiveSearchTarget =>
      librarySearchTargetOptionsForKind(widget.type.kind).isEmpty
          ? LibrarySearchTarget.all
          : _searchControllerOps.state.target;

  LibraryViewPreferenceStore get _viewPrefs =>
      LibraryViewPreferenceStore(widget.type.kind);

  List<String> get _scopeAvailableGroupModes {
    return [
      for (final groupId
          in libraryKindWorkspaceForKind(widget.type.kind).availableGroupIds)
        groupId.value,
    ];
  }

  List<String> get _scopeAvailableSortColumns {
    return [
      for (final sortId in libraryKindWorkspaceForKind(widget.type.kind)
          .fields
          .sorts
          .map((definition) => definition.id))
        sortId.value,
    ];
  }
}
