import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/watch_session_ref.dart';

final class WatchSessionCreateRequest {
  const WatchSessionCreateRequest({
    required this.id,
    required this.targetRef,
    required this.updatedAt,
    this.trackingEntryId,
    this.sourceType,
    this.watchedAt,
    this.seenWhere,
    this.rating,
    this.notes,
  });

  final String id;
  final CatalogEntityRef targetRef;
  final String? trackingEntryId;
  final Object? sourceType;
  final DateTime? watchedAt;
  final String? seenWhere;
  final int? rating;
  final String? notes;
  final DateTime updatedAt;
}

/// Kind-owned persistence contract for watch-session projections.
///
/// The shared host knows only lifecycle fields needed to aggregate and order
/// sessions. Episode coordinates and table mappings remain in the owner.
abstract interface class WatchSessionCodec {
  CatalogMediaKind get kind;

  /// Creates the kind-owned session for a structural target reference.
  /// Hierarchy coordinates, when applicable, are decoded by the owning kind.
  WatchSession create(WatchSessionCreateRequest request);

  /// Returns whether a session belongs to the supplied kind-owned catalog
  /// scope. Hierarchy matching is semantic and therefore stays in the kind
  /// codec instead of the mixed Collection host.
  bool matchesCatalogScope(WatchSession session, CatalogEntityRef scope);

  Future<List<WatchSession>> listActive(
    LocalDatabase db, {
    CatalogEntityRef? catalogRef,
  });

  Future<WatchSession?> findByRef(LocalDatabase db, WatchSessionRef ref);

  Future<void> upsert(LocalDatabase db, WatchSession session);

  /// Serializes a watch session for the provider sync boundary.
  ///
  /// The host supplies lifecycle and transport plumbing; the owning kind
  /// decides whether the payload contains hierarchy coordinates.
  JsonMap toSyncPayload(WatchSession session);

  /// Reconstructs a session received from the provider sync boundary.
  WatchSession fromSyncPayload({
    required JsonMap payload,
    required String id,
    required DateTime updatedAt,
    DateTime? deletedAt,
  });
}
