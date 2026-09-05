import 'package:collectarr_app/core/models/catalog_media_kind.dart';

/// Serialized provider metadata at the Admin proposal boundary.
typedef LibraryAdminProposalPayload = Map<String, dynamic>;

typedef LibraryAdminProposalFieldReader = String Function(
  LibraryAdminProposalPayload payload,
);

typedef LibraryAdminProposalFieldWriter = void Function(
  LibraryAdminProposalPayload payload,
  String rawValue,
);

/// Structural description of one kind-owned admin proposal field.
///
/// The payload is a provider boundary representation. A kind owns the key,
/// display semantics, and codec; the Admin feature only owns the editor host.
class LibraryAdminProposalField {
  const LibraryAdminProposalField({
    required this.key,
    required this.label,
    required this.read,
    required this.write,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final String key;
  final String label;
  final int minLines;
  final int maxLines;
  final LibraryAdminProposalFieldReader read;
  final LibraryAdminProposalFieldWriter write;
}

/// Semantic admin contribution supplied by one library kind.
///
/// Admin may render the fields structurally, but it must not interpret their
/// payload keys or decide which kind-specific fields are applicable.
abstract interface class LibraryAdminContributor {
  CatalogMediaKind get kind;

  List<LibraryAdminProposalField> get proposalFields;
}

String readAdminProposalText(
  LibraryAdminProposalPayload payload,
  String key,
) =>
    payload[key]?.toString() ?? '';

void writeAdminProposalText(
  LibraryAdminProposalPayload payload,
  String key,
  String rawValue,
) {
  final value = rawValue.trim();
  if (value.isEmpty) {
    payload.remove(key);
  } else {
    payload[key] = value;
  }
}

String readAdminProposalStringList(
  LibraryAdminProposalPayload payload,
  String key,
) {
  final value = payload[key];
  if (value is! List) {
    return '';
  }
  return value
      .map((entry) => entry.toString().trim())
      .where((entry) => entry.isNotEmpty)
      .join(', ');
}

void writeAdminProposalStringList(
  LibraryAdminProposalPayload payload,
  String key,
  String rawValue,
) {
  final values = rawValue
      .split(',')
      .map((entry) => entry.trim())
      .where((entry) => entry.isNotEmpty)
      .toList(growable: false);
  if (values.isEmpty) {
    payload.remove(key);
  } else {
    payload[key] = values;
  }
}
