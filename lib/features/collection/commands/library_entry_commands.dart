import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/library/config/library_entry_create_payload.dart';
import 'package:collectarr_app/features/library/config/library_entry_update_payload.dart';
import 'package:flutter/foundation.dart';

export 'package:collectarr_app/core/models/json_encodable.dart';
export 'package:collectarr_app/features/library/config/library_entry_create_payload.dart';
export 'package:collectarr_app/features/library/config/library_entry_update_payload.dart';

/// Represents a tri-state patch operation: unchanged, set new value, or clear value.
@immutable
sealed class Patch<T> {
  const Patch();

  const factory Patch.unchanged() = Unchanged<T>;
  const factory Patch.set(T value) = SetValue<T>;
  const factory Patch.clear() = ClearValue<T>;

  R when<R>({
    required R Function() unchanged,
    required R Function(T value) set,
    required R Function() clear,
  }) {
    return switch (this) {
      Unchanged<T>() => unchanged(),
      SetValue<T>(:final value) => set(value),
      ClearValue<T>() => clear(),
    };
  }

  T? valueOrNull() => switch (this) {
        SetValue<T>(:final value) => value,
        _ => null,
      };
}

class Unchanged<T> extends Patch<T> {
  const Unchanged();
}

class SetValue<T> extends Patch<T> {
  const SetValue(this.value);
  final T value;
}

class ClearValue<T> extends Patch<T> {
  const ClearValue();
}

/// Tracking state transported alongside an entries command.
///
/// Tracking is persisted by [TrackingMutations], never as part of the
/// collection-entry payload. The command keeps this small structural shape so
/// add flows can commit entries and then synchronize the typed tracking row.
@immutable
class LibraryEntryTrackingDraft {
  const LibraryEntryTrackingDraft({
    this.status,
    this.sourceType,
    this.rating,
    this.startedAt,
    this.finishedAt,
    this.notes,
    this.progressCurrent,
    this.progressTotal,
    this.timesCompleted,
  });

  final MediaTrackingStatus? status;
  final TrackingSourceType? sourceType;
  final int? rating;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final String? notes;
  final int? progressCurrent;
  final int? progressTotal;
  final int? timesCompleted;

  bool get hasValues =>
      status != null ||
      sourceType != null ||
      rating != null ||
      startedAt != null ||
      finishedAt != null ||
      (notes?.isNotEmpty ?? false) ||
      progressCurrent != null ||
      progressTotal != null ||
      timesCompleted != null;
}

/// Command to add a collection item to collection.
@immutable
final class AddLibraryEntryCommand {
  const AddLibraryEntryCommand({
    required this.catalogRef,
    required this.typedPayload,
    this.tracking,
  });

  final CatalogEntityRef catalogRef;
  final LibraryEntryCreatePayload typedPayload;

  final LibraryEntryTrackingDraft? tracking;
}

/// Structural request accepted by collection mutation orchestration.
abstract interface class LibraryEntryUpdateRequest {
  LibraryEntryRef get libraryEntryRef;
}

/// Typed command to update an existing collection item in collection.
@immutable
final class UpdateLibraryEntryCommand implements LibraryEntryUpdateRequest {
  const UpdateLibraryEntryCommand({
    required this.libraryEntryRef,
    required this.payload,
  });

  @override
  final LibraryEntryRef libraryEntryRef;
  final LibraryEntryUpdatePayload payload;
}
