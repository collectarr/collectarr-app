import 'package:collectarr_app/core/models/owned_item_projection.dart';

/// Structural result of a kind-owned persistence mutation.
///
/// The concrete aggregate is created, validated, persisted and serialized by
/// the generated kind dispatcher. Collection orchestration receives only the
/// cross-kind reference and the opaque schema-v1 sync payload it must enqueue.
final class OwnedItemMutationResult {
  const OwnedItemMutationResult({
    required this.ref,
    required this.syncPayload,
    required this.isDeleted,
  });

  final OwnedItemRef ref;
  final Map<String, dynamic> syncPayload;
  final bool isDeleted;
}
