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
        _selectedBundleReleaseId = _selectedBundleReleaseId ??
            (bundles.isNotEmpty ? bundles.first.id : null);
      }
      if (value != LibraryAddReferenceType.edition) {
        _selectedReferenceEditionId = null;
        _selectedReferenceVariantId = null;
      }
    });
    final bundleReleaseId = _selectedBundleReleaseId;
    if (value == LibraryAddReferenceType.bundleRelease &&
        bundleReleaseId != null) {
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

  String _canonicalVideoSearchKind(String kind) =>
      catalogMediaKindFromValue(kind).apiValue;

  bool get _isVideoKind => widget.type.capabilities.supportsVideoKindFilters;

  bool get _showsVideoKindFilters =>
      _isVideoKind && widget.type.addChrome.videoKindFilterOptions.isNotEmpty;

  List<String> get _allVideoSearchKinds {
    final configured = widget.type.addChrome.videoKindFilterOptions
        .map((option) => _canonicalVideoSearchKind(option.kind))
        .toSet()
        .toList();
    return configured.isEmpty
        ? [_canonicalVideoSearchKind(widget.type.workspace.kind.apiValue)]
        : configured;
  }

  bool get _isMovieDesktopChrome => widget.type.capabilities.wideDialog;

  bool _isCoreReleaseResult(LibraryMetadataItem item) {
    final itemNumber = item.itemNumber?.trim();
    final editionTitle = item.editionTitle?.trim();
    final physicalFormat = item.physicalFormat?.trim();
    final physicalFormatLabel = item.physicalFormatLabel?.trim();
    final barcode = item.barcode?.trim();
    final variant = item.variant?.trim();
    return (itemNumber != null && itemNumber.isNotEmpty) ||
        (editionTitle != null && editionTitle.isNotEmpty) ||
        (physicalFormat != null && physicalFormat.isNotEmpty) ||
        (physicalFormatLabel != null && physicalFormatLabel.isNotEmpty) ||
        (barcode != null && barcode.isNotEmpty) ||
        (variant != null && variant.isNotEmpty);
  }

  bool _isProviderReleaseResult(ProviderCandidate candidate) =>
      !_isSeriesCandidate(candidate);

  bool _matchesEntityScopeForCore(LibraryMetadataItem item) {
    if (_showMediaResults && _showReleaseResults) {
      return true;
    }
    final isRelease = _isCoreReleaseResult(item);
    return isRelease ? _showReleaseResults : _showMediaResults;
  }

  bool _matchesEntityScopeForProvider(ProviderCandidate candidate) {
    if (_showMediaResults && _showReleaseResults) {
      return true;
    }
    final isRelease = _isProviderReleaseResult(candidate);
    return isRelease ? _showReleaseResults : _showMediaResults;
  }

  List<LibraryMetadataItem> _visibleCoreResults() {
    if (!_showCoreResults) {
      return const <LibraryMetadataItem>[];
    }
    return _results.where((item) {
      if (!_matchesEntityScopeForCore(item)) {
        return false;
      }
      if (widget.type.workspace.kind.apiValue != 'comic') {
        return true;
      }
      if (_hideComicOwnedResults && _isOwnedCatalogItem(item.id)) {
        return false;
      }
      if (_hideComicVariantResults && _isComicVariantResult(item)) {
        return false;
      }
      return true;
    }).toList(growable: false);
  }

  List<ProviderCandidate> _visibleProviderResults() {
    if (!_showProviderResults) {
      return const <ProviderCandidate>[];
    }
    return _providerResults.where((candidate) {
      if (!_matchesEntityScopeForProvider(candidate)) {
        return false;
      }
      if (widget.type.workspace.kind.apiValue != 'comic') {
        return true;
      }
      return !_hideComicVariantResults || !candidate.isVariant;
    }).toList(growable: false);
  }

  bool _isOwnedCatalogItem(String id) =>
      ref.read(collectionByCatalogItemProvider).containsKey(id);

  bool _isComicVariantResult(LibraryMetadataItem item) {
    final variantText = item.variant?.trim();
    return variantText != null && variantText.isNotEmpty;
  }

  void _pruneSelectionsForVisibility({
    required List<LibraryMetadataItem> visibleResults,
    required List<ProviderCandidate> visibleProviderResults,
  }) {
    final visibleResultIds = visibleResults.map((item) => item.id).toSet();
    final visibleProviderIds =
        visibleProviderResults.map((item) => item.localCatalogId).toSet();
    if (_selectedResultId != null &&
        !visibleResultIds.contains(_selectedResultId)) {
      _selectedResultId = null;
    }
    if (_selectedProviderCandidateId != null &&
        !visibleProviderIds.contains(_selectedProviderCandidateId)) {
      _selectedProviderCandidateId = null;
    }
    _checkedResultIds.removeWhere((id) => !visibleResultIds.contains(id));
    _checkedProviderIds.removeWhere((id) => !visibleProviderIds.contains(id));
  }
}
