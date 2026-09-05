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

LibraryAdminProposalField adminTextProposalField({
  required String key,
  required String label,
  int minLines = 1,
  int maxLines = 1,
}) {
  return LibraryAdminProposalField(
    key: key,
    label: label,
    minLines: minLines,
    maxLines: maxLines,
    read: (payload) => readAdminProposalText(payload, key),
    write: (payload, rawValue) =>
        writeAdminProposalText(payload, key, rawValue),
  );
}

LibraryAdminProposalField adminStringListProposalField({
  required String key,
  required String label,
}) {
  return LibraryAdminProposalField(
    key: key,
    label: label,
    read: (payload) => readAdminProposalStringList(payload, key),
    write: (payload, rawValue) =>
        writeAdminProposalStringList(payload, key, rawValue),
  );
}

String readAdminProposalExternalLinks(
  LibraryAdminProposalPayload payload,
  String key,
) {
  final value = payload[key];
  if (value is! List) {
    return '';
  }
  return [
    for (final row in value)
      if (row is Map && row['url']?.toString().trim().isNotEmpty == true)
        [
          row['label']?.toString() ?? '',
          row['url']?.toString() ?? '',
          row['kind']?.toString() ?? '',
          row['description']?.toString() ?? '',
        ].join(' | '),
  ].join('\n');
}

void writeAdminProposalExternalLinks(
  LibraryAdminProposalPayload payload,
  String key,
  String rawValue,
) {
  final rows = <Map<String, dynamic>>[];
  final lines = rawValue.split('\n');
  for (var index = 0; index < lines.length; index++) {
    final line = lines[index].trim();
    if (line.isEmpty) {
      continue;
    }
    final columns =
        line.split('|').map((value) => value.trim()).toList(growable: false);
    final label = columns.length > 1 ? columns.first : '';
    final url = columns.length > 1 ? columns[1] : columns.first;
    final kind = columns.length > 2 ? columns[2] : '';
    final description = columns.length > 3 ? columns[3] : '';
    if (url.isEmpty) {
      throw FormatException(
        'External links line ${index + 1} is invalid: URL is required',
      );
    }
    final uri = Uri.tryParse(url);
    final scheme = uri?.scheme.toLowerCase();
    final isWebUrl = uri != null &&
        uri.hasScheme &&
        (scheme == 'http' || scheme == 'https') &&
        uri.host.isNotEmpty;
    if (!isWebUrl) {
      throw FormatException(
        'External links line ${index + 1} has invalid URL "$url" (use full http/https URL)',
      );
    }
    rows.add({
      if (label.isNotEmpty) 'label': label,
      'url': url,
      if (kind.isNotEmpty) 'kind': kind,
      if (description.isNotEmpty) 'description': description,
    });
  }
  if (rows.isEmpty) {
    payload.remove(key);
  } else {
    payload[key] = rows;
  }
}

LibraryAdminProposalField adminExternalLinksProposalField() {
  const key = 'external_links';
  return LibraryAdminProposalField(
    key: key,
    label: 'External links (label | url | kind | description)',
    minLines: 2,
    maxLines: 4,
    read: (payload) => readAdminProposalExternalLinks(payload, key),
    write: (payload, rawValue) =>
        writeAdminProposalExternalLinks(payload, key, rawValue),
  );
}
