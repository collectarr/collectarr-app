import 'package:collectarr_app/core/api/dto/catalog/catalog_common_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:flutter/foundation.dart';

@immutable
final class CatalogItemEnvelopeDto {
  const CatalogItemEnvelopeDto({
    required this.ref,
    required this.kind,
    required this.common,
    required this.kindPayload,
  });

  final CatalogEntityRef ref;
  final CatalogMediaKind kind;
  final CatalogCommonDto common;
  final Map<String, dynamic> kindPayload;

  factory CatalogItemEnvelopeDto.fromJson(Map<String, dynamic> json) {
    final rawKind = (json['kind'] ?? json['media_kind'])?.toString();
    final resolvedKind = catalogMediaKindFromApiValue(rawKind);
    final id = (json['id'] ?? json['ref_id'] ?? '').toString();
    final ref = CatalogEntityRef(
      kind: resolvedKind.apiValue,
      entityType: CatalogEntityType.work,
      id: id,
    );
    final common = CatalogCommonDto.fromJson(json);
    return CatalogItemEnvelopeDto(
      ref: ref,
      kind: resolvedKind,
      common: common,
      kindPayload: Map<String, dynamic>.unmodifiable(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': ref.id,
      'kind': kind.apiValue,
      ...common.toJson(),
      ...kindPayload,
    };
  }
}
