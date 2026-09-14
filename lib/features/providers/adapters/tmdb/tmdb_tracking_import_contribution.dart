import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/collection/mutations/tracking_mutations.dart';
import 'package:collectarr_app/features/providers/domain/models/mutation_origin.dart';

/// Structural hook for provider imports that produce kind-owned tracking
/// units. The provider owns the import protocol; the kind owns the tracking
/// coordinates and codec-specific mutation.
abstract interface class TmdbTrackingImportContribution {
  Future<void> addLocalOnlySeasonEntry(
    TrackingMutations trackingMutations,
    CatalogSearchCandidate seasonItem, {
    required int? seasonNumber,
    TrackingSourceType? sourceType,
    MediaTrackingStatus? status,
    int? rating,
    DateTime? startedAt,
    DateTime? finishedAt,
    int? progressCurrent,
    int? progressTotal,
    int? timesCompleted,
    bool allowEmpty,
    MutationOrigin origin,
  });
}

final _tmdbTrackingContributions =
    <CatalogMediaKind, TmdbTrackingImportContribution>{};

void registerTmdbTrackingImportContribution(
  CatalogMediaKind kind,
  TmdbTrackingImportContribution contribution,
) {
  final previous = _tmdbTrackingContributions[kind];
  if (previous != null && !identical(previous, contribution)) {
    throw StateError(
      'Duplicate TMDb tracking contribution for ${kind.apiValue}.',
    );
  }
  _tmdbTrackingContributions[kind] = contribution;
}

TmdbTrackingImportContribution? tmdbTrackingImportContributionForKind(
  CatalogMediaKind kind,
) {
  return _tmdbTrackingContributions[kind];
}
