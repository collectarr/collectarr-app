import 'package:collectarr_app/core/models/collection_item_projection.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';

/// Structural result of a kind-owned persistence mutation.
///
/// The concrete aggregate is created, validated, persisted and serialized by
/// the generated kind dispatcher. Collection orchestration receives only the
/// cross-kind reference and the opaque schema-v1 sync payload it must enqueue.
final class CollectionItemMutationResult {
  const CollectionItemMutationResult({
    required this.ref,
    required this.syncPayload,
    required this.isDeleted,
  });

  final CollectionItemRef ref;
  final JsonMap syncPayload;
  final bool isDeleted;
}
