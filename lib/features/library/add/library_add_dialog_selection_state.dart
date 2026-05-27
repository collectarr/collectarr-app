// ignore_for_file: invalid_use_of_protected_member

part of 'library_add_dialog.dart';

extension _LibraryAddDialogSelectionState on _LibraryAddDialogState {
  List<BundleReleaseSummary> _bundleReleasesForItem(LibraryMetadataItem? item) {
    if (item == null) {
      return const <BundleReleaseSummary>[];
    }
    return _bundleReleasesByItemId[item.id] ?? const <BundleReleaseSummary>[];
  }

  void _resetReferenceSelection() {
    _selectedBundleReleaseId = null;
    _selectedReferenceEditionId = null;
    _selectedReferenceVariantId = null;
    _referenceType = LibraryAddReferenceType.media;
  }

  void _clearSelectionCaches() {
    _hydratedResults.clear();
    _bundleReleasesByItemId.clear();
    _bundleReleaseDetailsById.clear();
    _pendingHydratedResultIds.clear();
    _pendingBundleReleaseItemIds.clear();
    _pendingBundleReleaseDetailIds.clear();
  }

  void _selectCoreResult(String id) {
    setState(() {
      _selectedResultId = id;
      _selectedProviderCandidateId = null;
      _resetReferenceSelection();
    });
    unawaited(_ensureSelectedResultLoaded(id));
    unawaited(_ensureBundleReleasesLoaded(id));
  }

  void _selectProviderCandidate(String id) {
    setState(() {
      _selectedProviderCandidateId = id;
      _selectedResultId = null;
      _resetReferenceSelection();
    });
    unawaited(_ensureProviderPreviewLoaded(id));
  }

  void _handleReferenceTypeChanged(
    LibraryMetadataItem? selectedResult,
    LibraryAddReferenceType value,
  ) {
    if (_addTarget == LibraryAddTarget.track) {
      return;
    }
    final bundles = _bundleReleasesForItem(selectedResult);
    setState(() {
      _referenceType = value;
      if (value != LibraryAddReferenceType.bundleRelease) {
        _selectedBundleReleaseId = null;
      } else {
        _selectedBundleReleaseId =
            _selectedBundleReleaseId ?? (bundles.isNotEmpty ? bundles.first.id : null);
      }
      if (value != LibraryAddReferenceType.edition) {
        _selectedReferenceEditionId = null;
        _selectedReferenceVariantId = null;
      }
    });
    final bundleReleaseId = _selectedBundleReleaseId;
    if (value == LibraryAddReferenceType.bundleRelease && bundleReleaseId != null) {
      unawaited(_ensureBundleReleaseDetailLoaded(bundleReleaseId));
    }
  }

  void _handleReferenceEditionSelected(
    LibraryMetadataItem? item,
    String editionId,
  ) {
    if (item == null) {
      return;
    }
    final selectedEdition = _previewEditionForItem(item, editionId);
    setState(() {
      _selectedReferenceEditionId = selectedEdition?.id;
      _selectedReferenceVariantId = null;
    });
  }

  void _handleReferenceVariantSelected(String variantId) {
    setState(() {
      _selectedReferenceVariantId = _emptyToNull(variantId);
    });
  }

  void _handleBundleReleaseSelected(String bundleReleaseId) {
    setState(() {
      _selectedBundleReleaseId = bundleReleaseId;
    });
    unawaited(_ensureBundleReleaseDetailLoaded(bundleReleaseId));
  }
}