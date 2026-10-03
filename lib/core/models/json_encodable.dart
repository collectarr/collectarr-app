/// JSON object shape used only at explicit serialization boundaries.
typedef JsonMap = Map<String, dynamic>;

/// Minimal serialization contract shared by models that cross a JSON
/// boundary. It carries no domain entries or field semantics.
abstract interface class JsonEncodable {
  JsonMap toJson();
}

/// Applies a typed document's kind-owned field edits at its JSON boundary.
///
/// Explicit null values are retained so nullable fields can be cleared when
/// the document is decoded again by its owning kind model.
JsonMap applyJsonFieldPatch(
  JsonEncodable document,
  Map<String, Object?> fields,
) =>
    <String, dynamic>{...document.toJson(), ...fields};
