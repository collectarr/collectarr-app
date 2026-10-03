import 'package:collectarr_app/core/api/dto/catalog/catalog_item_envelope_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:flutter/foundation.dart';

export 'package:collectarr_app/core/api/dto/catalog/catalog_item_envelope_dto.dart';
export 'package:collectarr_app/core/api/dto/catalog/catalog_link_dto.dart';
export 'package:collectarr_app/core/models/catalog_media_kind.dart';

enum CatalogItemOrigin {
  core,
  privateLocal,
}

@immutable
final class CatalogItemDto {
  factory CatalogItemDto({
    required LibraryItemIdentity identity,
    required JsonEncodable kindData,
    CatalogItemOrigin origin = CatalogItemOrigin.core,
  }) =>
      CatalogItemDto.raw(
        id: identity.id,
        mediaKind: identity.mediaKind,
        kindData: kindData.toJson(),
        origin: origin,
      );

  factory CatalogItemDto.raw({
    required String id,
    required CatalogMediaKind mediaKind,
    Map<String, dynamic> kindData = const <String, dynamic>{},
    CatalogItemOrigin origin = CatalogItemOrigin.core,
  }) {
    return CatalogItemDto._raw(
      id: id,
      mediaKind: mediaKind,
      kindData: Map<String, dynamic>.unmodifiable(
        _withoutEnvelopeFields(kindData),
      ),
      origin: origin,
    );
  }

  const CatalogItemDto._raw({
    required this.id,
    required this.mediaKind,
    required Map<String, dynamic> kindData,
    required this.origin,
  }) : _kindData = kindData;

  final String id;
  final CatalogMediaKind mediaKind;

  /// Local storage provenance. This value is never part of the Core contract.
  final CatalogItemOrigin origin;
  final Map<String, dynamic> _kindData;

  /// The flattened fields entry by this item's kind, without routing data.
  ///
  /// This map is only a transport boundary. Semantic reads and writes belong
  /// to the kind's typed model and mapper.
  Map<String, dynamic> get kindData => _kindData;

  /// The flattened Core item at the HTTP and kind-mapper boundary.
  Map<String, dynamic> get payload => {
        ...kindData,
        'id': id,
        'kind': mediaKind.apiValue,
      };

  LibraryItemIdentity get identity =>
      LibraryItemIdentity(id: id, mediaKind: mediaKind);

  String get kind => mediaKind.apiValue;

  CatalogItemRef get catalogItemRef => CatalogItemRef(kind: mediaKind, id: id);

  CatalogEntityRef get catalogRef => CatalogEntityRef(
        kind: mediaKind,
        entityType: CatalogEntityTypeId.catalogItem,
        id: id,
      );

  factory CatalogItemDto.fromEnvelope(CatalogItemEnvelopeDto envelope) {
    return CatalogItemDto.raw(
      id: envelope.id,
      mediaKind: envelope.kind,
      kindData: envelope.kindData,
    );
  }

  factory CatalogItemDto.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('kind_data')) {
      return CatalogItemDto.fromEnvelope(
        CatalogItemEnvelopeDto.fromJson(json),
      );
    }
    const unsupportedEnvelopeFields = {
      'ref',
      'ref_id',
      'media_kind',
      'entity_type',
      'root_id',
      'parent_id',
      'common',
      'payload',
    };
    final unsupported = json.keys.where(
      unsupportedEnvelopeFields.contains,
    );
    if (unsupported.isNotEmpty) {
      throw FormatException(
        'Catalog Item v1 payload contains unsupported fields: '
        '${unsupported.join(', ')}.',
      );
    }
    final rawId = json['id'];
    final rawKind = json['kind'];
    if (rawId is! String || rawId.trim().isEmpty || rawKind is! String) {
      throw const FormatException(
        'Flat Catalog Item payload requires kind and id.',
      );
    }
    final mediaKind = catalogMediaKindFromApiValue(rawKind);
    if (mediaKind.isUnknown) {
      throw FormatException('Catalog Item v1 has unsupported kind: $rawKind.');
    }
    return CatalogItemDto.raw(
      id: rawId,
      mediaKind: mediaKind,
      kindData: json,
    );
  }

  /// Emits the flat Core payload with its identity alongside kind-entry data.
  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind,
        ...kindData,
      };

  CatalogItemEnvelopeDto toEnvelope() => CatalogItemEnvelopeDto(
        ref: catalogItemRef,
        kindData: kindData,
      );

  /// Replaces the complete kind document while retaining the transport identity.
  CatalogItemDto replacingKindData(JsonEncodable kindData) =>
      CatalogItemDto.raw(
        id: id,
        mediaKind: mediaKind,
        origin: origin,
        kindData: kindData.toJson(),
      );

  CatalogItemDto withOrigin(CatalogItemOrigin origin) => CatalogItemDto.raw(
        id: id,
        mediaKind: mediaKind,
        kindData: kindData,
        origin: origin,
      );
}

Map<String, dynamic> _withoutEnvelopeFields(Map<String, dynamic> value) => {
      for (final entry in value.entries)
        if (!_transportFields.contains(entry.key)) entry.key: entry.value,
    };

const _transportFields = <String>{
  'id',
  'kind',
  'snapshot_version',
};

