import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/library/config/owned_details_draft.dart';
import 'package:collectarr_app/features/library/config/owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/config/owned_item_update_payload.dart';
import 'package:flutter/foundation.dart';

export 'package:collectarr_app/features/library/config/owned_details_draft.dart';
export 'package:collectarr_app/features/library/config/owned_item_create_payload.dart';
export 'package:collectarr_app/features/library/config/owned_item_update_payload.dart';

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
class OwnedItemTrackingDraft {
  const OwnedItemTrackingDraft({
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

/// Command to add an owned item to collection.
@immutable
final class AddOwnedItemCommand {
  const AddOwnedItemCommand({
    required this.catalogRef,
    required this.typedPayload,
    this.anchor,
    this.tracking,
  });

  final CatalogEntityRef catalogRef;
  final OwnedItemCreatePayload typedPayload;
  final PersonalItemAnchor? anchor;
  final OwnedItemTrackingDraft? tracking;
}

/// Structural request accepted by collection mutation orchestration.
abstract interface class OwnedItemUpdateRequest {
  String get ownedItemId;
}

/// Typed command to update an existing owned item in collection.
@immutable
final class UpdateOwnedItemCommand implements OwnedItemUpdateRequest {
  const UpdateOwnedItemCommand({
    required this.ownedItemId,
    required this.payload,
  });

  @override
  final String ownedItemId;
  final OwnedItemUpdatePayload payload;
}

/// Structural tri-state update command used to build a kind-owned payload.
@immutable
final class OwnedItemPatchCommand<TDetails extends OwnedDetailsDraft>
    implements OwnedItemUpdateRequest {
  const OwnedItemPatchCommand({
    required this.ownedItemId,
    this.anchor = const Patch.unchanged(),
    this.quantity = const Patch.unchanged(),
    this.condition = const Patch.unchanged(),
    this.grade = const Patch.unchanged(),
    this.purchaseDate = const Patch.unchanged(),
    this.pricePaidCents = const Patch.unchanged(),
    this.currency = const Patch.unchanged(),
    this.personalNotes = const Patch.unchanged(),
    this.locationId = const Patch.unchanged(),
    this.purchaseStore = const Patch.unchanged(),
    this.collectionStatus = const Patch.unchanged(),
    this.isDigital = const Patch.unchanged(),
    this.tags = const Patch.unchanged(),
    this.soldAt = const Patch.unchanged(),
    this.sellPriceCents = const Patch.unchanged(),
    this.soldTo = const Patch.unchanged(),
    this.marketValueCents = const Patch.unchanged(),
    this.indexNumber = const Patch.unchanged(),
    this.details = const Patch.unchanged(),
  });

  @override
  final String ownedItemId;
  final Patch<PersonalItemAnchor?> anchor;
  final Patch<int> quantity;
  final Patch<String?> condition;
  final Patch<String?> grade;
  final Patch<DateTime?> purchaseDate;
  final Patch<int?> pricePaidCents;
  final Patch<String?> currency;
  final Patch<String?> personalNotes;
  final Patch<String?> locationId;
  final Patch<String?> purchaseStore;
  final Patch<String?> collectionStatus;
  final Patch<bool?> isDigital;
  final Patch<String?> tags;
  final Patch<DateTime?> soldAt;
  final Patch<int?> sellPriceCents;
  final Patch<String?> soldTo;
  final Patch<int?> marketValueCents;
  final Patch<int?> indexNumber;
  final Patch<TDetails> details;
}
