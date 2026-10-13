import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:flutter/foundation.dart';

@immutable
final class CatalogItemEnvelopeDto {
  factory CatalogItemEnvelopeDto({
    required CatalogItemRef ref,
    required Map<String, dynamic> kindData,
  }) {
    return CatalogItemEnvelopeDto._raw(
      ref: ref,
      kindData: Map<String, dynamic>.unmodifiable(
        Map<String, dynamic>.from(kindData),
      ),
    );
  }

  const CatalogItemEnvelopeDto._raw({
    required this.ref,
    required this.kindData,
  });

  final CatalogItemRef ref;
  final Map<String, dynamic> kindData;

  CatalogMediaKind get kind => ref.kind;
  String get id => ref.id;

  factory CatalogItemEnvelopeDto.fromJson(Map<String, dynamic> json) {
    const allowedKeys = {'id', 'kind', 'kind_data'};
    final unexpected = json.keys.where((key) => !allowedKeys.contains(key));
    if (unexpected.isNotEmpty) {
      throw FormatException(
        'Catalog Item v1 envelope contains unsupported fields: '
        '${unexpected.join(', ')}.',
      );
    }
    final rawRef = <String, Object?>{
      'kind': json['kind'],
      'id': json['id'],
    };
    final ref = CatalogItemRef.fromJson(rawRef);
    final nestedKindData = _mapValue(json['kind_data']);
    if (nestedKindData == null) {
      throw const FormatException(
        'Catalog Item v1 envelope requires kind_data.',
      );
    }
    if (nestedKindData.containsKey('id') ||
        nestedKindData.containsKey('kind')) {
      throw const FormatException(
        'Catalog Item identity belongs beside kind_data, not inside it.',
      );
    }
    return CatalogItemEnvelopeDto._raw(
      ref: ref,
      kindData: Map<String, dynamic>.unmodifiable(
        Map<String, dynamic>.from(nestedKindData),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.apiValue,
        'kind_data': kindData,
      };

  CatalogItemDto decodeCatalogItem() => CatalogItemDto.fromEnvelope(this);

  static Map<String, dynamic>? _mapValue(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : null;
}
