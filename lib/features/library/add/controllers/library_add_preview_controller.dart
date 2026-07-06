part of '../library_add_dialog.dart';

class _LibraryAddPreviewController {
  _LibraryAddPreviewController(this.state);

  final _LibraryAddDialogState state;

  Future<void> addProviderCandidate(
    ProviderCandidate candidate,
    LibraryAddTarget target,
  ) =>
      state.addProviderCandidate(candidate, target);

  Future<void> proposeCandidate(ProviderCandidate candidate) =>
      state.proposeCandidate(candidate);

  Future<void> queueProviderIngest(ProviderCandidate candidate) =>
      state.queueProviderIngest(candidate);
}
