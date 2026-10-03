import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';

/// Schema-v1 Entry payload waiting to cross into kind-entry persistence.
///
/// The payload is opaque to generic Collection code. The owning persistence
/// dispatcher decodes it using [ref.kind] and returns a structural mutation
/// result.
final class EntryImportTransport {
  const EntryImportTransport({
    required this.ref,
    required this.payload,
  });

  final LibraryEntryRef ref;
  final JsonMap payload;
}
