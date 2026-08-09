import 'package:collectarr_app/features/library/add/controllers/library_add_preview_controller.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_search_controller.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_selection_state.dart';
import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_target.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
final class LibraryAddSessionState {
  const LibraryAddSessionState({
    required this.mode,
    required this.target,
    required this.search,
    required this.selection,
    required this.preview,
    required this.commonDraft,
    required this.manualDraft,
    required this.submitState,
  });

  final LibraryAddDialogMode mode;
  final LibraryAddTarget target;
  final LibraryAddSearchState search;
  final LibraryAddSelectionState selection;
  final LibraryAddPreviewState preview;
  final LibraryAddCommonDraft commonDraft;
  final LibraryAddKindDraft manualDraft;
  final AsyncValue<void> submitState;

  LibraryAddSessionState copyWith({
    LibraryAddDialogMode? mode,
    LibraryAddTarget? target,
    LibraryAddSearchState? search,
    LibraryAddSelectionState? selection,
    LibraryAddPreviewState? preview,
    LibraryAddCommonDraft? commonDraft,
    LibraryAddKindDraft? manualDraft,
    AsyncValue<void>? submitState,
  }) {
    return LibraryAddSessionState(
      mode: mode ?? this.mode,
      target: target ?? this.target,
      search: search ?? this.search,
      selection: selection ?? this.selection,
      preview: preview ?? this.preview,
      commonDraft: commonDraft ?? this.commonDraft,
      manualDraft: manualDraft ?? this.manualDraft,
      submitState: submitState ?? this.submitState,
    );
  }
}
