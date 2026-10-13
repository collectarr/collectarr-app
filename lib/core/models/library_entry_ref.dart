import 'package:flutter/foundation.dart';

import 'catalog_media_kind.dart';

@immutable
class LibraryEntryId {
  const LibraryEntryId(this.value);

  final String value;

  static LibraryEntryId? fromRaw(String? raw) {
    final trimmed = raw?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return LibraryEntryId(trimmed);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryEntryId &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

/// Stable cross-kind identity for one personal collection entry.
///
/// The entry has its own ID. Its domain record may separately retain an
/// optional Catalog Item reference as provenance.
@immutable
final class LibraryEntryRef {
  const LibraryEntryRef({
    required this.kind,
    required this.id,
  });

  final CatalogMediaKind kind;
  final LibraryEntryId id;

  String get key => '${kind.apiValue}:${Uri.encodeComponent(id.value)}';

  factory LibraryEntryRef.fromKey(String key) {
    final parts = key.split(':');
    if (parts.length != 2 || parts.first.isEmpty || parts[1].isEmpty) {
      throw const FormatException(
        'LibraryEntryRef key must be <kind>:<id>',
      );
    }
    final kind = catalogMediaKindFromApiValue(parts.first);
    final id = Uri.decodeComponent(parts[1]);
    if (kind.isUnknown || id.trim().isEmpty) {
      throw const FormatException(
        'LibraryEntryRef key must contain a known kind and ID',
      );
    }
    return LibraryEntryRef(
      kind: kind,
      id: LibraryEntryId(id),
    );
  }

  Map<String, Object?> toJson() => {
        'kind': kind.apiValue,
        'id': id.value,
      };

  factory LibraryEntryRef.fromJson(Map<String, Object?> json) {
    final unexpected = json.keys.where((key) => key != 'kind' && key != 'id');
    if (unexpected.isNotEmpty) {
      throw FormatException(
        'LibraryEntryRef contains unsupported fields: ${unexpected.join(', ')}',
      );
    }
    final rawKind = json['kind'];
    final rawId = json['id'];
    if (rawKind is! String || rawId is! String || rawId.trim().isEmpty) {
      throw const FormatException(
        'LibraryEntryRef requires kind and id',
      );
    }
    final kind = catalogMediaKindFromApiValue(rawKind);
    if (kind.isUnknown) {
      throw FormatException('LibraryEntryRef requires a known kind: $rawKind');
    }
    return LibraryEntryRef(
      kind: kind,
      id: LibraryEntryId(rawId),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryEntryRef && kind == other.kind && id == other.id;

  @override
  int get hashCode => Object.hash(kind, id);
}

/// Decodes a cross-kind collection-entry reference at a transport boundary.
LibraryEntryRef? libraryEntryRefFromSerialized(Object? value) {
  if (value == null) return null;
  if (value is String) return LibraryEntryRef.fromKey(value);
  if (value is Map) {
    return LibraryEntryRef.fromJson(Map<String, Object?>.from(value));
  }
  throw FormatException('Invalid serialized LibraryEntryRef: $value');
}
