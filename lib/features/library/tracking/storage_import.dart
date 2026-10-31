import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/tracking_state_ref.dart';

/// Schema-v1 tracking values carried from a kind-entry CSV profile to the
/// tracking persistence boundary.
///
/// This is deliberately an operation value, not a tracking domain model.
/// The owning persistence codec reconstructs its concrete lifecycle type.
final class TrackingStorageImport {
  const TrackingStorageImport({
    required this.entryId,
    required this.libraryEntryRef,
    required this.now,
    this.rating,
    this.status,
    this.startedAt,
    this.finishedAt,
  });

  final String entryId;
  final LibraryEntryRef libraryEntryRef;
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
final class TrackingStorageImportResult {
  const TrackingStorageImportResult({
    required this.ref,
    required this.payload,
  });

  final TrackingStateRef ref;
  final JsonMap payload;
}
