/// Structural behavior contract for a kind-owned Owned update payload.
///
/// The payload owns the interpretation of its complete Owned patch and only
/// crosses a common storage boundary at the persistence edge.
/// Structural marker for a kind-owned update payload.
///
/// The common application boundary transports this marker only until the
/// generated registry dispatches by [OwnedItemRef]. The concrete payload then
/// remains responsible for its own `canApplyTo` and `applyTo` operations.
/// Keeping those operations off this contract prevents a common `Object`
/// domain API from reappearing in Collection and Edit.
abstract interface class OwnedItemUpdatePayload {}
