import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

/// Façade that routes search-plane actions back into [_LibraryAddDialogState]
/// via stored callbacks. No reference to the private state class is required.
class LibraryAddSearchController {
  LibraryAddSearchController({
    required Future<void> Function() search,
    required void Function(String) onQueryChanged,
    required void Function(LibraryMetadataItem) selectSuggestion,
    required void Function() dismissSuggestions,
    required Future<void> Function() scanCover,
    required Future<void> Function() lookupBarcode,
    required Future<void> Function(String) ensureSelectedResultLoaded,
    required Future<void> Function(String) ensureBundleReleasesLoaded,
    required Future<void> Function(String) ensureProviderPreviewLoaded,
    required Future<void> Function(String) ensureBundleReleaseDetailLoaded,
  })  : _fnSearch = search,
        _fnQueryChanged = onQueryChanged,
        _fnSelectSuggestion = selectSuggestion,
        _fnDismissSuggestions = dismissSuggestions,
        _fnScanCover = scanCover,
        _fnLookupBarcode = lookupBarcode,
        _fnEnsureSelectedResultLoaded = ensureSelectedResultLoaded,
        _fnEnsureBundleReleasesLoaded = ensureBundleReleasesLoaded,
        _fnEnsureProviderPreviewLoaded = ensureProviderPreviewLoaded,
        _fnEnsureBundleReleaseDetailLoaded = ensureBundleReleaseDetailLoaded;

  final Future<void> Function() _fnSearch;
  final void Function(String) _fnQueryChanged;
  final void Function(LibraryMetadataItem) _fnSelectSuggestion;
  final void Function() _fnDismissSuggestions;
  final Future<void> Function() _fnScanCover;
  final Future<void> Function() _fnLookupBarcode;
  final Future<void> Function(String) _fnEnsureSelectedResultLoaded;
  final Future<void> Function(String) _fnEnsureBundleReleasesLoaded;
  final Future<void> Function(String) _fnEnsureProviderPreviewLoaded;
  final Future<void> Function(String) _fnEnsureBundleReleaseDetailLoaded;

  Future<void> search() => _fnSearch();

  void onQueryChanged(String value) => _fnQueryChanged(value);

  void selectSuggestion(LibraryMetadataItem item) =>
      _fnSelectSuggestion(item);

  void dismissSuggestions() => _fnDismissSuggestions();

  Future<void> scanCover() => _fnScanCover();

  Future<void> lookupBarcode() => _fnLookupBarcode();

  Future<void> ensureSelectedResultLoaded(String itemId) =>
      _fnEnsureSelectedResultLoaded(itemId);

  Future<void> ensureBundleReleasesLoaded(String itemId) =>
      _fnEnsureBundleReleasesLoaded(itemId);

  Future<void> ensureProviderPreviewLoaded(String candidateId) =>
      _fnEnsureProviderPreviewLoaded(candidateId);

  Future<void> ensureBundleReleaseDetailLoaded(String bundleReleaseId) =>
      _fnEnsureBundleReleaseDetailLoaded(bundleReleaseId);
}

