import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/collection_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/library/config/collection_item_create_payload.dart';
import 'package:collectarr_app/features/library/config/collection_item_update_payload.dart';
import 'package:flutter/foundation.dart';

export 'package:collectarr_app/core/models/json_encodable.dart';
export 'package:collectarr_app/features/library/config/collection_item_create_payload.dart';
export 'package:collectarr_app/features/library/config/collection_item_update_payload.dart';

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

/// Tracking state transported alongside an ownership command.
///
/// Tracking is persisted by [TrackingMutations], never as part of the
/// collection-owned payload. The command keeps this small structural shape so
/// add flows can commit ownership and then synchronize the typed tracking row.
@immutable
class CollectionItemTrackingDraft {
  const CollectionItemTrackingDraft({
    this.status,
    this.rating,
    this.startedAt,
    this.finishedAt,
    this.notes,
  });

  final MediaTrackingStatus? status;
  final int? rating;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final String? notes;
}

/// Command to add a collection item to collection.
@immutable
final class AddCollectionItemCommand {
  const AddCollectionItemCommand({
    required this.catalogRef,
    required this.typedPayload,
    this.tracking,
  });

  final CatalogEntityRef catalogRef;
  final CollectionItemCreatePayload typedPayload;

  final CollectionItemTrackingDraft? tracking;
}

/// Structural request accepted by collection mutation orchestration.
abstract interface class CollectionItemUpdateRequest {
  CollectionItemRef get collectionItemRef;
}

/// Typed command to update an existing collection item in collection.
@immutable
final class UpdateCollectionItemCommand implements CollectionItemUpdateRequest {
  const UpdateCollectionItemCommand({
    required this.collectionItemRef,
    required this.payload,
  });

  @override
  final CollectionItemRef collectionItemRef;
  final CollectionItemUpdatePayload payload;
}
