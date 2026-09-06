import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/collection/mutations/tracking_mutations.dart';
import 'package:collectarr_app/features/providers/domain/models/mutation_origin.dart';

/// TV-owned contribution for importing a synthetic season tracking entry.
///
/// The collection feature supplies generic lifecycle/persistence mechanics;
/// TV supplies the season coordinate that is stored by its tracking codec.
final class TvTrackingImportContribution {
  const TvTrackingImportContribution();

  Future<void> addLocalOnlySeasonEntry(
    TrackingMutations trackingMutations,
    CatalogItem seasonItem, {
    required int? seasonNumber,
    TrackingSourceType? sourceType,
    MediaTrackingStatus? status = MediaTrackingStatus.planned,
    int? rating,
    DateTime? startedAt,
    DateTime? finishedAt,
    int? progressCurrent,
    int? progressTotal,
    int? timesCompleted,
    bool allowEmpty = false,
    MutationOrigin origin = MutationOrigin.user,
  }) {
    return trackingMutations.addLocalOnlyTrackingEntry(
      seasonItem,
      anchorType: 'season',
      sourceType: sourceType,
      status: status,
      rating: rating,
      startedAt: startedAt,
      finishedAt: finishedAt,
      progressCurrent: progressCurrent,
      progressTotal: progressTotal,
      timesCompleted: timesCompleted,
      customizeEntry: (entry) => entry.copyWith(
        seasonNumber: seasonNumber,
      ),
      allowEmpty: allowEmpty,
      origin: origin,
    );
  }
}
