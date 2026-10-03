import 'package:collectarr_app/core/api/dto/catalog/catalog_item_envelope_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_edition_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_link_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:flutter/foundation.dart';

export 'package:collectarr_app/core/api/dto/catalog/catalog_disc_dto.dart';
export 'package:collectarr_app/core/api/dto/catalog/catalog_edition_dto.dart';
export 'package:collectarr_app/core/api/dto/catalog/game_catalog_details_dto.dart';
export 'package:collectarr_app/core/api/dto/catalog/catalog_item_envelope_dto.dart';
export 'package:collectarr_app/core/api/dto/catalog/catalog_link_dto.dart';
export 'package:collectarr_app/core/api/dto/catalog/catalog_publishing_details_dto.dart';
export 'package:collectarr_app/core/api/dto/catalog/catalog_series_details_dto.dart';
export 'package:collectarr_app/core/api/dto/catalog/catalog_track_dto.dart';
export 'package:collectarr_app/core/api/dto/catalog/catalog_variant_dto.dart';
export 'package:collectarr_app/core/api/dto/catalog/video_catalog_details_dto.dart';
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

  // These are read-only workspace conveniences derived from the flat payload.
  // They are never serialized separately: Core and the local cache retain
  // every canonical value only in kindData, and kind-entry codecs remain the
  // source for semantic behavior.
  String get title => _string(kindData['title']) ?? '';
  String? get displayTitle => _string(kindData['display_title']);
  String? get localizedTitle => _string(kindData['localized_title']);
  String? get originalTitle => _string(kindData['original_title']);
  String? get titleExtension => _string(kindData['title_extension']);
  List<String>? get searchAliases => _stringList(kindData['search_aliases']);
  String? get sortKey =>
      _string(kindData['sort_key'] ?? kindData['sort_title']);
  String? get synopsis => _string(
        kindData['synopsis'] ?? kindData['description'],
      );
  String? get coverImageUrl => _string(kindData['cover_image_url']);
  String? get thumbnailImageUrl => _string(kindData['thumbnail_image_url']);
  String? get coverImageData => _string(kindData['cover_image_data']);
  PartialDate? get releaseDateParts => PartialDate.tryParse(
        kindData['release_date_parts'] ?? kindData['release_date'],
      );
  DateTime? get releaseDate => releaseDateParts?.asDateTime;
  int? get releaseYear =>
      (kindData['release_year'] as num?)?.toInt() ?? releaseDateParts?.year;
  String? get itemNumber =>
      _string(kindData['item_number'] ?? kindData['issue_number']);
  String? get variant => _string(kindData['variant_name']);
  String? get publisher => _string(kindData['publisher']);
  String? get barcode => _string(kindData['barcode']);
  String? get identifierCode => barcode;
  String? get physicalFormat => _string(kindData['physical_format']);
  String? get physicalFormatLabel => _string(kindData['physical_format_label']);
  String? get editionTitle => _string(kindData['edition_title']);
  List<TrailerLinkDto> get trailerUrls => [
        ..._linkList(kindData['trailer_urls']),
        ..._linkList(kindData['external_links'], defaultKind: 'external'),
      ];
  List<CatalogEditionDto> get editions =>
      _mapList(kindData['editions']).map(CatalogEditionDto.fromJson).toList();

  CatalogEntityRef get catalogRef => CatalogEntityRef(
        kind: mediaKind,
        entityType: CatalogEntityTypeId.catalogItem,
        id: id,
      );

  CatalogEntityRef catalogRefForTarget(CatalogEntityRef? targetRef) {
    if (targetRef == null) return catalogRef;
    return targetRef.copyWith(
      kind: mediaKind,
      rootId: targetRef.rootId ?? (targetRef.id == id ? null : id),
    );
  }

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

  /// Applies editor values directly to the flattened kind-entry data map.
  ///
  /// This convenience is used by the current kind editors while their typed
  /// draft adapters are being consolidated. It never creates a shared/common
  /// metadata object or writes these fields outside kindData.
  CatalogItemDto copyWith({
    LibraryItemIdentity? identity,
    String? title,
    Object? displayTitle = _unset,
    Object? localizedTitle = _unset,
    Object? originalTitle = _unset,
    Object? titleExtension = _unset,
    Object? searchAliases = _unset,
    Object? sortKey = _unset,
    Object? synopsis = _unset,
    Object? coverImageUrl = _unset,
    Object? thumbnailImageUrl = _unset,
    Object? coverImageData = _unset,
    Object? releaseDate = _unset,
    Object? releaseDateParts = _unset,
    Object? releaseYear = _unset,
    List<CatalogEditionDto>? editions,
    List<TrailerLinkDto>? trailerUrls,
    Object? physicalFormat = _unset,
    Object? physicalFormatLabel = _unset,
    Object? editionTitle = _unset,
  }) {
    final data = <String, dynamic>{
      ...kindData,
      if (title != null) 'title': title,
      if (!identical(displayTitle, _unset)) 'display_title': displayTitle,
      if (!identical(localizedTitle, _unset)) 'localized_title': localizedTitle,
      if (!identical(originalTitle, _unset)) 'original_title': originalTitle,
      if (!identical(titleExtension, _unset)) 'title_extension': titleExtension,
      if (!identical(searchAliases, _unset)) 'search_aliases': searchAliases,
      if (!identical(sortKey, _unset)) 'sort_key': sortKey,
      if (!identical(synopsis, _unset)) 'synopsis': synopsis,
      if (!identical(coverImageUrl, _unset)) 'cover_image_url': coverImageUrl,
      if (!identical(thumbnailImageUrl, _unset))
        'thumbnail_image_url': thumbnailImageUrl,
      if (!identical(coverImageData, _unset))
        'cover_image_data': coverImageData,
      if (!identical(releaseDate, _unset))
        'release_date': (releaseDate as DateTime?)?.toIso8601String(),
      if (!identical(releaseDateParts, _unset))
        'release_date_parts': (releaseDateParts as PartialDate?)?.toJson(),
      if (!identical(releaseYear, _unset)) 'release_year': releaseYear,
      if (editions != null)
        'editions': [for (final edition in editions) edition.toJson()],
      if (trailerUrls != null)
        'trailer_urls': [for (final link in trailerUrls) link.toJson()],
      if (!identical(physicalFormat, _unset)) 'physical_format': physicalFormat,
      if (!identical(physicalFormatLabel, _unset))
        'physical_format_label': physicalFormatLabel,
      if (!identical(editionTitle, _unset)) 'edition_title': editionTitle,
    };
    final updatedIdentity = identity ?? this.identity;
    return CatalogItemDto.raw(
      id: updatedIdentity.id,
      mediaKind: updatedIdentity.mediaKind,
      kindData: data,
      origin: origin,
    );
  }

  CatalogItemDto withKindData(JsonEncodable kindData) {
    return CatalogItemDto.raw(
      id: id,
      mediaKind: mediaKind,
      origin: origin,
      kindData: {
        ...this.kindData,
        ...kindData.toJson(),
      },
    );
  }

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

const _unset = Object();

String? _string(Object? value) {
  final result = value?.toString().trim();
  return result == null || result.isEmpty ? null : result;
}

List<String>? _stringList(Object? value) =>
    value is List ? value.whereType<String>().toList(growable: false) : null;

List<Map<String, dynamic>> _mapList(Object? value) => value is List
    ? value
        .whereType<Map<dynamic, dynamic>>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList()
    : const <Map<String, dynamic>>[];

List<TrailerLinkDto> _linkList(
  Object? value, {
  String? defaultKind,
}) =>
    [
      for (final link in _mapList(value))
        TrailerLinkDto.fromJson({
          ...link,
          if (link['kind'] == null &&
              link['type'] == null &&
              defaultKind != null)
            'kind': defaultKind,
        }),
    ];
