part of '../library_add_dialog.dart';

class _LibraryAddPreviewController {
  _LibraryAddPreviewController(this.state);

  final _LibraryAddDialogState state;

  Future<void> addProviderCandidate(
    ProviderCandidate candidate,
    LibraryAddTarget target,
  ) =>
      state._addProviderCandidate(candidate, target);

  Future<void> proposeCandidate(ProviderCandidate candidate) =>
      state._proposeCandidate(candidate);

  Future<void> queueProviderIngest(ProviderCandidate candidate) =>
      state._queueProviderIngest(candidate);
}
