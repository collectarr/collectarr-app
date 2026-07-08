import 'package:collectarr_app/features/library/add/models/library_add_target.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';

/// Façade that routes preview/ingest actions back into [_LibraryAddDialogState]
/// via stored callbacks. No reference to the private state class is required.
class LibraryAddPreviewController {
  LibraryAddPreviewController({
    required Future<void> Function(ProviderCandidate, LibraryAddTarget)
        addProviderCandidate,
    required Future<void> Function(ProviderCandidate) proposeCandidate,
    required Future<void> Function(ProviderCandidate) queueProviderIngest,
  })  : _fnAddProviderCandidate = addProviderCandidate,
        _fnProposeCandidate = proposeCandidate,
        _fnQueueProviderIngest = queueProviderIngest;

  final Future<void> Function(ProviderCandidate, LibraryAddTarget)
      _fnAddProviderCandidate;
  final Future<void> Function(ProviderCandidate) _fnProposeCandidate;
  final Future<void> Function(ProviderCandidate) _fnQueueProviderIngest;

  Future<void> addProviderCandidate(
    ProviderCandidate candidate,
    LibraryAddTarget target,
  ) =>
      _fnAddProviderCandidate(candidate, target);

  Future<void> proposeCandidate(ProviderCandidate candidate) =>
      _fnProposeCandidate(candidate);

  Future<void> queueProviderIngest(ProviderCandidate candidate) =>
      _fnQueueProviderIngest(candidate);
}
