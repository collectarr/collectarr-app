import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_candidate.dart';

/// Provider candidate details used by the retired Add preview pipeline.
/// Kept within the provider boundary until the remaining adapters are removed.
final class ProviderCandidatePreview {
  const ProviderCandidatePreview({
    required this.candidate,
    required this.preview,
  });

  final ProviderSearchCandidate candidate;
  final AdminProviderPreview preview;
}
