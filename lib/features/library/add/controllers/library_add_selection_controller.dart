import 'package:collectarr_app/features/library/add/models/library_add_reference_type.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

/// Façade that routes selection actions back into [_LibraryAddDialogState]
/// via stored callbacks. No reference to the private state class is required.
class LibraryAddSelectionController {
  LibraryAddSelectionController({
    required void Function() resetReferenceSelection,
    required void Function() clearSelectionCaches,
    required void Function(String) selectCoreResult,
    required void Function(String) selectProviderCandidate,
    required void Function(LibraryMetadataItem?, LibraryAddReferenceType)
        handleReferenceTypeChanged,
    required void Function(LibraryMetadataItem?, String)
        handleReferenceEditionSelected,
    required void Function(String) handleReferenceVariantSelected,
    required void Function(String) handleBundleReleaseSelected,
  })  : _fnResetReferenceSelection = resetReferenceSelection,
        _fnClearSelectionCaches = clearSelectionCaches,
        _fnSelectCoreResult = selectCoreResult,
        _fnSelectProviderCandidate = selectProviderCandidate,
        _fnHandleReferenceTypeChanged = handleReferenceTypeChanged,
        _fnHandleReferenceEditionSelected = handleReferenceEditionSelected,
        _fnHandleReferenceVariantSelected = handleReferenceVariantSelected,
        _fnHandleBundleReleaseSelected = handleBundleReleaseSelected;

  final void Function() _fnResetReferenceSelection;
  final void Function() _fnClearSelectionCaches;
  final void Function(String) _fnSelectCoreResult;
  final void Function(String) _fnSelectProviderCandidate;
  final void Function(LibraryMetadataItem?, LibraryAddReferenceType)
      _fnHandleReferenceTypeChanged;
  final void Function(LibraryMetadataItem?, String)
      _fnHandleReferenceEditionSelected;
  final void Function(String) _fnHandleReferenceVariantSelected;
  final void Function(String) _fnHandleBundleReleaseSelected;

  void resetReferenceSelection() => _fnResetReferenceSelection();

  void clearSelectionCaches() => _fnClearSelectionCaches();

  void selectCoreResult(String id) => _fnSelectCoreResult(id);

  void selectProviderCandidate(String id) => _fnSelectProviderCandidate(id);

  void handleReferenceTypeChanged(
    LibraryMetadataItem? selectedResult,
    LibraryAddReferenceType value,
  ) =>
      _fnHandleReferenceTypeChanged(selectedResult, value);

  void handleReferenceEditionSelected(
    LibraryMetadataItem? item,
    String editionId,
  ) =>
      _fnHandleReferenceEditionSelected(item, editionId);

  void handleReferenceVariantSelected(String variantId) =>
      _fnHandleReferenceVariantSelected(variantId);

  void handleBundleReleaseSelected(String bundleReleaseId) =>
      _fnHandleBundleReleaseSelected(bundleReleaseId);
}

