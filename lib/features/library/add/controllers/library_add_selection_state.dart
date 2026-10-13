import 'package:collectarr_app/features/library/add/contracts/library_add_result_policy.dart';
import 'package:flutter/foundation.dart';

@immutable
class LibraryAddSelectionState {
  const LibraryAddSelectionState({
    this.selectedResultId,
    this.checkedResultIds = const {},
    this.resultPolicyState = const LibraryAddResultPolicyState(),
  });

  final String? selectedResultId;
  final Set<String> checkedResultIds;
  final LibraryAddResultPolicyState resultPolicyState;

  String? get selectedId => selectedResultId;

  LibraryAddSelectionState copyWith({
    String? selectedId,
    String? selectedResultId,
    bool clearSelectedResultId = false,
    Set<String>? checkedResultIds,
    LibraryAddResultPolicyState? resultPolicyState,
  }) {
    return LibraryAddSelectionState(
      selectedResultId: clearSelectedResultId
          ? null
          : (selectedId ?? selectedResultId ?? this.selectedResultId),
      checkedResultIds: checkedResultIds ?? this.checkedResultIds,
      resultPolicyState: resultPolicyState ?? this.resultPolicyState,
    );
  }
}
