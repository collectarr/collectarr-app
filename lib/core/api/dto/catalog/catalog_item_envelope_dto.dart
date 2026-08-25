import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:flutter/foundation.dart';

@immutable
final class CatalogItemEnvelopeDto {
  const CatalogItemEnvelopeDto({
    required this.ref,
    required this.kind,
    required this.common,
    required this.payload,
  });

  final CatalogEntityRef ref;
  final CatalogMediaKind kind;
  final CatalogCommonDto common;
  final Map<String, dynamic> payload;

  String get id => ref.id;
  Map<String, dynamic> get kindPayload => payload;

  factory CatalogItemEnvelopeDto.fromJson(Map<String, dynamic> json) {
    final commonJson = _mapValue(json['common']) ?? json;
    final payloadJson = _mapValue(json['payload']);
    final rawKind = (json['kind'] ?? json['media_kind'])?.toString();
    final resolvedKind = catalogMediaKindFromApiValue(rawKind);
    final id =
        (json['id'] ?? json['ref_id'] ?? _mapValue(json['ref'])?['id'] ?? '')
            .toString();
    final ref = CatalogEntityRef(
      kind: resolvedKind.apiValue,
      entityType: CatalogEntityType.work,
      id: id,
    );
    final common = CatalogCommonDto.fromJson(commonJson);
    final rawPayload = payloadJson ?? Map<String, dynamic>.from(json)
      ..removeWhere((key, _) => _commonKeys.contains(key));
    return CatalogItemEnvelopeDto(
      ref: ref,
      kind: resolvedKind,
      common: common,
      payload: Map<String, dynamic>.unmodifiable(rawPayload),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ref': ref.toJson(),
      'kind': kind.apiValue,
      'common': common.toJson(),
      'payload': payload,
    };
  }

  CatalogItemDto decodeCatalogItem() {
    return CatalogItemDto.fromEnvelope(this);
  }

  static Map<String, dynamic>? _mapValue(Object? value) {
    return value is Map ? Map<String, dynamic>.from(value) : null;
  }
}

const _commonKeys = <String>{
  'id',
  'ref_id',
  'ref',
  'kind',
  'media_kind',
  'common',
  'payload',
  'title',
  'display_title',
  'localized_title',
  'original_title',
  'title_extension',
  'search_aliases',
  'aliases',
  'sort_key',
  'synopsis',
  'overview',
  'description',
  'cover_image_url',
  'cover_url',
  'poster_url',
  'thumbnail_image_url',
  'thumbnail_url',
  'cover_thumbnail_url',
  'cover_image_data',
  'release_date',
  'first_air_date',
  'release_year',
  'trailer_urls',
  'trailers',
  'external_links',
  'editions',
};
