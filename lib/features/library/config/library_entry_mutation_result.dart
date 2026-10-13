import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';

/// Structural result of a kind-entry persistence mutation.
///
/// The concrete aggregate is created, validated, persisted and serialized by
/// the generated kind dispatcher. Collection orchestration receives only the
/// cross-kind reference and the opaque schema-v1 sync payload it must enqueue.
final class LibraryEntryMutationResult {
  const LibraryEntryMutationResult({
    required this.ref,
    required this.syncPayload,
    required this.isDeleted,
  });

  final LibraryEntryRef ref;
  final JsonMap syncPayload;
  final bool isDeleted;
}
