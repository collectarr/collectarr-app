part of '../library_add_dialog.dart';

class _LibraryAddSelectionController {
  _LibraryAddSelectionController(this.state);

  final _LibraryAddDialogState state;

  void resetReferenceSelection() => state._resetReferenceSelection();

  void clearSelectionCaches() => state._clearSelectionCaches();

  void selectCoreResult(String id) => state._selectCoreResult(id);

  void selectProviderCandidate(String id) =>
      state._selectProviderCandidate(id);

  void handleReferenceTypeChanged(
    LibraryMetadataItem? selectedResult,
    LibraryAddReferenceType value,
  ) =>
      state._handleReferenceTypeChanged(selectedResult, value);

  void handleReferenceEditionSelected(
    LibraryMetadataItem? item,
    String editionId,
  ) =>
      state._handleReferenceEditionSelected(item, editionId);

  void handleReferenceVariantSelected(String variantId) =>
      state._handleReferenceVariantSelected(variantId);

  void handleBundleReleaseSelected(String bundleReleaseId) =>
      state._handleBundleReleaseSelected(bundleReleaseId);
}

