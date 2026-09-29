import 'package:collectarr_app/features/library/add/models/library_add_reference_type.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_result_policy.dart';
import 'package:flutter/foundation.dart';

@immutable
class LibraryAddSelectionState {
  const LibraryAddSelectionState({
    this.selectedResultId,
    this.selectedBundleReleaseId,
    this.selectedReferenceEditionId,
    this.selectedReferenceVariantId,
    this.checkedResultIds = const {},
    this.referenceType = LibraryAddReferenceType.media,
    this.resultPolicyState = const LibraryAddResultPolicyState(),
  });

  final String? selectedResultId;
  final String? selectedBundleReleaseId;
  final String? selectedReferenceEditionId;
  final String? selectedReferenceVariantId;
  final Set<String> checkedResultIds;
  final LibraryAddReferenceType referenceType;
  final LibraryAddResultPolicyState resultPolicyState;

  String? get selectedId => selectedResultId;

  LibraryAddSelectionState copyWith({
    String? selectedId,
    String? selectedResultId,
    bool clearSelectedResultId = false,
    String? selectedBundleReleaseId,
    bool clearSelectedBundleReleaseId = false,
    String? selectedReferenceEditionId,
    bool clearSelectedReferenceEditionId = false,
    String? selectedReferenceVariantId,
    bool clearSelectedReferenceVariantId = false,
    Set<String>? checkedResultIds,
    LibraryAddReferenceType? referenceType,
    LibraryAddResultPolicyState? resultPolicyState,
  }) {
    return LibraryAddSelectionState(
      selectedResultId: clearSelectedResultId
          ? null
          : (selectedId ?? selectedResultId ?? this.selectedResultId),
      selectedBundleReleaseId: clearSelectedBundleReleaseId
          ? null
          : (selectedBundleReleaseId ?? this.selectedBundleReleaseId),
      selectedReferenceEditionId: clearSelectedReferenceEditionId
          ? null
          : (selectedReferenceEditionId ?? this.selectedReferenceEditionId),
      selectedReferenceVariantId: clearSelectedReferenceVariantId
          ? null
          : (selectedReferenceVariantId ?? this.selectedReferenceVariantId),
      checkedResultIds: checkedResultIds ?? this.checkedResultIds,
      referenceType: referenceType ?? this.referenceType,
      resultPolicyState: resultPolicyState ?? this.resultPolicyState,
    );
  }
}
