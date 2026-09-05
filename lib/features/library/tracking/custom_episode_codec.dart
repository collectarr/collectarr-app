import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/custom_episode.dart';

/// Kind-owned persistence and hierarchy behavior for custom episodes.
///
/// The collection feature only aggregates the projections returned by these
/// codecs. Episode coordinates stay inside the owning TV or Anime adapter.
abstract interface class CustomEpisodeCodec {
  String get kind;

  Future<List<CustomEpisode>> listActive(
    LocalDatabase db, {
    String? itemId,
  });

  Future<CustomEpisode?> findById(LocalDatabase db, String id);

  Future<void> upsert(LocalDatabase db, CustomEpisode episode);

  /// Serializes a custom episode for the provider sync boundary.
  Map<String, dynamic> toSyncPayload(CustomEpisode episode);

  /// Reconstructs a custom episode received from the provider sync boundary.
  CustomEpisode fromSyncPayload({
    required Map<String, dynamic> payload,
    required String id,
    required DateTime updatedAt,
    DateTime? deletedAt,
  });

  int compare(CustomEpisode left, CustomEpisode right);

  int groupKey(CustomEpisode episode);
}
