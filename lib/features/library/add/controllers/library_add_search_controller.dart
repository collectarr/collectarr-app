part of '../library_add_dialog.dart';

class _LibraryAddSearchController {
  _LibraryAddSearchController(this.state);

  final _LibraryAddDialogState state;

  Future<void> search() => state._search();

  void onQueryChanged(String value) => state._onQueryChanged(value);

  void selectSuggestion(LibraryMetadataItem item) =>
      state._selectSuggestion(item);

  void dismissSuggestions() => state._dismissSuggestions();

  Future<void> scanCover() => state._scanCover();

  Future<void> lookupBarcode() => state._lookupBarcode();

  Future<void> ensureSelectedResultLoaded(String itemId) =>
      state._ensureSelectedResultLoaded(itemId);

  Future<void> ensureBundleReleasesLoaded(String itemId) =>
      state._ensureBundleReleasesLoaded(itemId);

  Future<void> ensureProviderPreviewLoaded(String candidateId) =>
      state._ensureProviderPreviewLoaded(candidateId);

  Future<void> ensureBundleReleaseDetailLoaded(String bundleReleaseId) =>
      state._ensureBundleReleaseDetailLoaded(bundleReleaseId);
}
