import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';

/// Opaque sync record produced by a kind-owned custom-episode codec.
///
/// The generic sync host may carry this value because it is already at the
/// schema-v1 serialization boundary. It must not decode it into a common
/// episode domain object.
final class CustomEpisodeSyncRecord {
  const CustomEpisodeSyncRecord({
    required this.payload,
    required this.isDeleted,
  });

  final JsonMap payload;
  final bool isDeleted;
}

/// Kind-owned persistence adapter for custom-episode sync only.
///
/// TV and Anime own their complete custom-episode aggregates and repositories.
/// This contract intentionally exposes only serialization-boundary operations
/// so generic sync never receives a common episode model.
abstract interface class CustomEpisodeSyncCodec {
  CatalogMediaKind get kind;

  Future<void> applySyncPayload(
    LocalDatabase db, {
    required JsonMap payload,
    required String id,
    required DateTime updatedAt,
    DateTime? deletedAt,
  });

  Future<CustomEpisodeSyncRecord?> readSyncRecord(
    LocalDatabase db,
    String id,
  );
}
