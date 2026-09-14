/// JSON object shape used only at explicit serialization boundaries.
typedef JsonMap = Map<String, dynamic>;

/// Minimal serialization contract shared by models that cross a JSON
/// boundary. It carries no domain ownership or field semantics.
abstract interface class JsonEncodable {
  JsonMap toJson();
}
