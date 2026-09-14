import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/collection/mutations/tracking_mutations.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_state.dart';
import 'package:collectarr_app/features/providers/adapters/tmdb/tmdb_tracking_import_contribution.dart';
import 'package:collectarr_app/features/providers/domain/models/mutation_origin.dart';

/// TV-owned contribution for importing a synthetic season tracking entry.
///
/// The collection feature supplies generic lifecycle/persistence mechanics;
/// TV supplies the season coordinate that is stored by its tracking codec.
final class TvTrackingImportContribution
    implements TmdbTrackingImportContribution {
  const TvTrackingImportContribution();

  @override
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
    bool allowEmpty = false,
    MutationOrigin origin = MutationOrigin.user,
  }) {
    return trackingMutations.addLocalOnlyTrackingState(
      seasonItem.catalogRef,
      sourceType: sourceType,
      status: status,
      rating: rating,
      startedAt: startedAt,
      finishedAt: finishedAt,
      progressCurrent: progressCurrent,
      progressTotal: progressTotal,
      timesCompleted: timesCompleted,
      kindPatch: TvTrackingCoordinatesPatch(
        seasonNumber: seasonNumber,
        setSeasonNumber: true,
      ),
      allowEmpty: allowEmpty,
      origin: origin,
    );
  }
}
