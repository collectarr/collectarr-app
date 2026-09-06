import 'package:collectarr_app/core/models/owned_item.dart';

/// Structural behavior contract for a kind-owned Owned update payload.
///
/// The payload owns the interpretation of its complete Owned patch and only
/// translates to the transitional common cache model at the persistence edge.
abstract interface class OwnedItemUpdatePayload {
  bool canApplyTo(OwnedItem existing);

  OwnedItem applyTo(
    OwnedItem existing, {
    required DateTime updatedAt,
    required String? fallbackOwnerUserId,
    required String? fallbackOwnerLabel,
  });
}
