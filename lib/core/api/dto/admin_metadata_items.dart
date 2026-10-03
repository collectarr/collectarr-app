part of 'admin_metadata.dart';

class AdminMetadataItem {
  const AdminMetadataItem({
    required this.id,
    required this.kind,
    this.canonicalFieldValues = const <String, dynamic>{},
  });

  final String id;
  final String kind;

  /// Root Catalog Item fields from the Admin transport response.
  ///
  /// The map stays opaque here; kind contributors interpret their own fields.
  final Map<String, dynamic> canonicalFieldValues;

  String get title => canonicalFieldValues['title'] as String? ?? '';

  String? get itemNumber => _optionalText(canonicalFieldValues['item_number']);

  String get displayTitle {
    final number = itemNumber;
    return number == null ? title : '$title #$number';
  }

  String? get coverImageUrl =>
      _optionalText(canonicalFieldValues['cover_image_url']);

  String? get thumbnailImageUrl =>
      _optionalText(canonicalFieldValues['thumbnail_image_url']);

  String? get displayCoverUrl => thumbnailImageUrl ?? coverImageUrl;

  String? get displayPhysicalFormat =>
      _optionalText(canonicalFieldValues['physical_format_label']) ??
      _optionalText(canonicalFieldValues['physical_format']);

  factory AdminMetadataItem.fromJson(Map<String, dynamic> json) {
    return AdminMetadataItem(
      id: json['id']?.toString() ?? '',
      kind: json['kind'] as String? ?? '',
      canonicalFieldValues: {
        for (final entry in json.entries)
          if (entry.key != 'id' &&
              entry.key != 'kind' &&
              entry.key != 'revision')
            entry.key: entry.value,
      },
    );
  }
}

String? _optionalText(Object? value) {
  if (value is! String) return null;
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

DateTime? _parseDateTime(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value)?.toUtc();
}

String _shortModelId(String id) => id.length <= 8 ? id : id.substring(0, 8);
