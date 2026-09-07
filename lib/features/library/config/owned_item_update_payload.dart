/// Structural behavior contract for a kind-owned Owned update payload.
///
/// The payload owns the interpretation of its complete Owned patch and only
/// crosses a common storage boundary at the persistence edge.
abstract interface class OwnedItemUpdatePayload<T> {
  bool canApplyTo(T existing);

  T applyTo(
    T existing, {
    required DateTime updatedAt,
    required String? fallbackOwnerUserId,
    required String? fallbackOwnerLabel,
  });
}
