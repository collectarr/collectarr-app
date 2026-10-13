import 'package:collectarr_app/core/models/json_encodable.dart';

/// Structural behavior contract for a kind-entry Entry create payload.
///
/// The payload implementation owns every personal field and translates
/// it at the persistence boundary.
/// Generic collection code can invoke the behavior without reading any kind
/// field or inspecting the concrete payload.
abstract interface class LibraryEntryCreatePayload {
  JsonEncodable get detailsDraft;
  bool? get isDigital;
}
