import 'package:collectarr_app/core/models/bundle_release.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_selection_state.dart';
import 'package:collectarr_app/features/library/add/models/library_add_reference_type.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

class LibraryAddSelectionController {
  LibraryAddSelectionController({LibraryAddSelectionState? state})
      : state = state ?? LibraryAddSelectionState();

  final LibraryAddSelectionState state;

  String? get selectedResultId => state.selectedResultId;
  set selectedResultId(String? value) => state.selectedResultId = value;

  String? get selectedProviderCandidateId => state.selectedProviderCandidateId;
  set selectedProviderCandidateId(String? value) =>
      state.selectedProviderCandidateId = value;

  String? get selectedBundleReleaseId => state.selectedBundleReleaseId;
  set selectedBundleReleaseId(String? value) =>
      state.selectedBundleReleaseId = value;

  String? get selectedReferenceEditionId => state.selectedReferenceEditionId;
  set selectedReferenceEditionId(String? value) =>
      state.selectedReferenceEditionId = value;

  String? get selectedReferenceVariantId => state.selectedReferenceVariantId;
  set selectedReferenceVariantId(String? value) =>
      state.selectedReferenceVariantId = value;

  Set<String> get checkedResultIds => state.checkedResultIds;
  Set<String> get checkedProviderIds => state.checkedProviderIds;

  LibraryAddReferenceType get referenceType => state.referenceType;
  set referenceType(LibraryAddReferenceType value) =>
      state.referenceType = value;

  bool get showCoreResults => state.showCoreResults;
  set showCoreResults(bool value) => state.showCoreResults = value;

  bool get showProviderResults => state.showProviderResults;
  set showProviderResults(bool value) => state.showProviderResults = value;

  bool get showMediaResults => state.showMediaResults;
  set showMediaResults(bool value) => state.showMediaResults = value;

  bool get showSeasonResults => state.showSeasonResults;
  set showSeasonResults(bool value) => state.showSeasonResults = value;

  bool get showReleaseResults => state.showReleaseResults;
  set showReleaseResults(bool value) => state.showReleaseResults = value;

  bool get hideComicOwnedResults => state.hideComicOwnedResults;
  set hideComicOwnedResults(bool value) => state.hideComicOwnedResults = value;

  bool get hideComicVariantResults => state.hideComicVariantResults;
  set hideComicVariantResults(bool value) =>
      state.hideComicVariantResults = value;

  bool get compactComicIssues => state.compactComicIssues;
  set compactComicIssues(bool value) => state.compactComicIssues = value;

  void resetReferenceSelection() {
    selectedBundleReleaseId = null;
    selectedReferenceEditionId = null;
    selectedReferenceVariantId = null;
    referenceType = LibraryAddReferenceType.media;
  }

  void selectCoreResult(String id) {
    selectedResultId = id;
    selectedProviderCandidateId = null;
    resetReferenceSelection();
  }

  void selectProviderCandidate(String id) {
    selectedProviderCandidateId = id;
    selectedResultId = null;
    resetReferenceSelection();
  }

  void handleReferenceTypeChanged({
    required LibraryAddReferenceType value,
    required List<BundleReleaseSummary> bundleReleases,
  }) {
    referenceType = value;
    if (value != LibraryAddReferenceType.bundleRelease) {
      selectedBundleReleaseId = null;
    } else {
      selectedBundleReleaseId ??=
          bundleReleases.isNotEmpty ? bundleReleases.first.id : null;
    }
    if (value != LibraryAddReferenceType.edition) {
      selectedReferenceEditionId = null;
      selectedReferenceVariantId = null;
    }
  }

  void handleReferenceEditionSelected(
      LibraryMetadataItem? item, String? editionId) {
    if (item == null) {
      return;
    }
    selectedReferenceEditionId = editionId;
    selectedReferenceVariantId = null;
  }

  void handleReferenceVariantSelected(String? variantId) {
    selectedReferenceVariantId = variantId;
  }

  void handleBundleReleaseSelected(String bundleReleaseId) {
    selectedBundleReleaseId = bundleReleaseId;
  }

  void pruneSelectionsForVisibility({
    required Set<String> visibleResultIds,
    required Set<String> visibleProviderIds,
  }) {
    if (selectedResultId != null &&
        !visibleResultIds.contains(selectedResultId)) {
      selectedResultId = null;
    }
    if (selectedProviderCandidateId != null &&
        !visibleProviderIds.contains(selectedProviderCandidateId)) {
      selectedProviderCandidateId = null;
    }
    checkedResultIds.removeWhere((id) => !visibleResultIds.contains(id));
    checkedProviderIds.removeWhere((id) => !visibleProviderIds.contains(id));
  }
}
