import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle_ref.dart';

/// Schema-v1 tracking values carried from a kind-owned CSV profile to the
/// tracking persistence boundary.
///
/// This is deliberately an operation value, not a tracking domain model.
/// The owning persistence codec reconstructs its concrete lifecycle type.
final class TrackingLifecycleImport {
  const TrackingLifecycleImport({
    required this.entryId,
    required this.catalogRef,
    required this.ownedRef,
    required this.now,
    this.rating,
    this.status,
    this.startedAt,
    this.finishedAt,
  });

  final String entryId;
  final CatalogEntityRef catalogRef;
  final OwnedItemRef ownedRef;
  final DateTime now;
  final int? rating;
  final String? status;
  final DateTime? startedAt;
  final DateTime? finishedAt;
}

/// Structural result emitted after an imported lifecycle is persisted.
///
/// Sync receives the serialized payload at its transport boundary; no
/// generic Collection caller receives the concrete tracking aggregate.
final class TrackingLifecycleImportResult {
  const TrackingLifecycleImportResult({
    required this.ref,
    required this.catalogRef,
    required this.payload,
  });

  final TrackingLifecycleRef ref;
  final CatalogEntityRef catalogRef;
  final JsonMap payload;
}
