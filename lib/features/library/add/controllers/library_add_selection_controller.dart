import 'package:collectarr_app/core/models/bundle_release.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_selection_state.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_result_policy.dart';
import 'package:collectarr_app/features/library/add/models/library_add_reference_type.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

class LibraryAddSelectionController {
  LibraryAddSelectionController({LibraryAddSelectionState? state})
      : state = state ?? const LibraryAddSelectionState();

  LibraryAddSelectionState state;

  String? get selectedResultId => state.selectedResultId;
  set selectedResultId(String? value) => state = state.copyWith(
      selectedResultId: value, clearSelectedResultId: value == null);

  String? get selectedProviderCandidateId => state.selectedProviderCandidateId;
  set selectedProviderCandidateId(String? value) => state = state.copyWith(
      selectedProviderCandidateId: value,
      clearSelectedProviderCandidateId: value == null);

  String? get selectedBundleReleaseId => state.selectedBundleReleaseId;
  set selectedBundleReleaseId(String? value) => state = state.copyWith(
      selectedBundleReleaseId: value,
      clearSelectedBundleReleaseId: value == null);

  String? get selectedReferenceEditionId => state.selectedReferenceEditionId;
  set selectedReferenceEditionId(String? value) => state = state.copyWith(
      selectedReferenceEditionId: value,
      clearSelectedReferenceEditionId: value == null);

  String? get selectedReferenceVariantId => state.selectedReferenceVariantId;
  set selectedReferenceVariantId(String? value) => state = state.copyWith(
      selectedReferenceVariantId: value,
      clearSelectedReferenceVariantId: value == null);

  Set<String> get checkedResultIds => state.checkedResultIds;
  Set<String> get checkedProviderIds => state.checkedProviderIds;

  LibraryAddResultPolicyState get resultPolicyState => state.resultPolicyState;

  LibraryAddReferenceType get referenceType => state.referenceType;
  set referenceType(LibraryAddReferenceType value) =>
      state = state.copyWith(referenceType: value);

  bool get showCoreResults => state.showCoreResults;
  set showCoreResults(bool value) =>
      state = state.copyWith(showCoreResults: value);

  bool get showProviderResults => state.showProviderResults;
  set showProviderResults(bool value) =>
      state = state.copyWith(showProviderResults: value);

  void setResultPolicyState(LibraryAddResultPolicyState value) {
    state = state.copyWith(resultPolicyState: value);
  }

  void setResultPolicyOption(String id, bool value) {
    setResultPolicyState(state.resultPolicyState.withValue(id, value));
  }

  void toggleCheckedResult(String id) {
    final updated = Set<String>.from(state.checkedResultIds);
    if (!updated.remove(id)) {
      updated.add(id);
    }
    state = state.copyWith(checkedResultIds: updated);
  }

  void toggleCheckedProvider(String id) {
    final updated = Set<String>.from(state.checkedProviderIds);
    if (!updated.remove(id)) {
      updated.add(id);
    }
    state = state.copyWith(checkedProviderIds: updated);
  }

  void resetReferenceSelection() {
    state = state.copyWith(
      clearSelectedBundleReleaseId: true,
      clearSelectedReferenceEditionId: true,
      clearSelectedReferenceVariantId: true,
      referenceType: LibraryAddReferenceType.media,
    );
  }

  void selectCoreResult(String id) {
    state = state.copyWith(
      selectedResultId: id,
      clearSelectedProviderCandidateId: true,
      clearSelectedBundleReleaseId: true,
      clearSelectedReferenceEditionId: true,
      clearSelectedReferenceVariantId: true,
      referenceType: LibraryAddReferenceType.media,
    );
  }

  void selectProviderCandidate(String id) {
    state = state.copyWith(
      selectedProviderCandidateId: id,
      clearSelectedResultId: true,
      clearSelectedBundleReleaseId: true,
      clearSelectedReferenceEditionId: true,
      clearSelectedReferenceVariantId: true,
      referenceType: LibraryAddReferenceType.media,
    );
  }

  void handleReferenceTypeChanged({
    required LibraryAddReferenceType value,
    required List<BundleReleaseSummary> bundleReleases,
  }) {
    String? firstBundleId;
    if (value == LibraryAddReferenceType.bundleRelease) {
      firstBundleId = state.selectedBundleReleaseId ??
          (bundleReleases.isNotEmpty ? bundleReleases.first.id : null);
    }
    state = state.copyWith(
      referenceType: value,
      selectedBundleReleaseId: firstBundleId,
      clearSelectedBundleReleaseId:
          value != LibraryAddReferenceType.bundleRelease,
      clearSelectedReferenceEditionId: value != LibraryAddReferenceType.edition,
      clearSelectedReferenceVariantId: value != LibraryAddReferenceType.edition,
    );
  }

  void handleReferenceEditionSelected(
      CatalogItem? item, String? editionId) {
    if (item == null) return;
    state = state.copyWith(
      selectedReferenceEditionId: editionId,
      clearSelectedReferenceEditionId: editionId == null,
      clearSelectedReferenceVariantId: true,
    );
  }

  void handleReferenceVariantSelected(String? variantId) {
    state = state.copyWith(
      selectedReferenceVariantId: variantId,
      clearSelectedReferenceVariantId: variantId == null,
    );
  }

  void handleBundleReleaseSelected(String bundleReleaseId) {
    state = state.copyWith(
      selectedBundleReleaseId: bundleReleaseId,
    );
  }

  void pruneSelectionsForVisibility({
    required Set<String> visibleResultIds,
    required Set<String> visibleProviderIds,
  }) {
    final checkedResults = Set<String>.from(state.checkedResultIds)
      ..removeWhere((id) => !visibleResultIds.contains(id));
    final checkedProviders = Set<String>.from(state.checkedProviderIds)
      ..removeWhere((id) => !visibleProviderIds.contains(id));

    state = state.copyWith(
      clearSelectedResultId: state.selectedResultId != null &&
          !visibleResultIds.contains(state.selectedResultId),
      clearSelectedProviderCandidateId:
          state.selectedProviderCandidateId != null &&
              !visibleProviderIds.contains(state.selectedProviderCandidateId),
      checkedResultIds: checkedResults,
      checkedProviderIds: checkedProviders,
    );
  }
}
