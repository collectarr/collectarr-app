import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:flutter/foundation.dart';

/// The relationship between a concrete Music release and its box set.
///
/// A box set is represented as an opaque catalog reference. Music owns the
/// meaning of the relationship; generic catalog code only transports it.
@immutable
final class MusicBoxSetMembership {
  const MusicBoxSetMembership({
    required this.boxSetRef,
    this.sequenceNumber,
  });

  final CatalogEntityRef boxSetRef;
  final int? sequenceNumber;

  Map<String, dynamic> toJson() => {
        'box_set_ref': boxSetRef.toJson(),
        if (sequenceNumber != null) 'sequence_number': sequenceNumber,
      };

  factory MusicBoxSetMembership.fromJson(Map<String, dynamic> json) {
    final rawRef = json['box_set_ref'] ??
        json['ref'] ??
        (json.containsKey('id') ? json : null);
    if (rawRef == null) {
      throw const FormatException('Music box-set membership has no reference');
    }
    final boxSetRef = switch (rawRef) {
      String value when value.trim().isNotEmpty => CatalogEntityRef(
          kind: CatalogMediaKind.music,
          entityType: const CatalogEntityTypeId('box_set'),
          id: value.trim(),
        ),
      Map<Object?, Object?> value => CatalogEntityRef.fromJson({
          'kind': value['kind'] ?? CatalogMediaKind.music.apiValue,
          'entity_type': value['entity_type'] ?? 'box_set',
          'id': value['id'] ?? '',
          if (value['root_id'] != null) 'root_id': value['root_id'],
          if (value['parent_id'] != null) 'parent_id': value['parent_id'],
        }),
      _ => throw const FormatException(
          'Music box-set membership has an invalid reference'),
    };
    if (boxSetRef.id.trim().isEmpty || !boxSetRef.isKnown) {
      throw const FormatException(
          'Music box-set membership has an invalid reference');
    }
    return MusicBoxSetMembership(
      boxSetRef: boxSetRef,
      sequenceNumber: _int(json['sequence_number'] ?? json['position']),
    );
  }
}

int? _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '');
}
