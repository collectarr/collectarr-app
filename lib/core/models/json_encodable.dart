/// Minimal serialization contract shared by models that cross a JSON
/// boundary. It carries no domain ownership or field semantics.
abstract interface class JsonEncodable {
  Map<String, dynamic> toJson();
}
