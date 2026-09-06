import 'package:collectarr_app/core/api/dto/catalog/catalog_common_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_disc_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_edition_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_envelope_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_track_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:flutter/foundation.dart';

export 'package:collectarr_app/core/api/dto/catalog/catalog_common_dto.dart';
export 'package:collectarr_app/core/api/dto/catalog/catalog_disc_dto.dart';
export 'package:collectarr_app/core/api/dto/catalog/catalog_edition_dto.dart';
export 'package:collectarr_app/core/api/dto/catalog/catalog_item_envelope_dto.dart';
export 'package:collectarr_app/core/api/dto/catalog/catalog_publishing_details_dto.dart';
export 'package:collectarr_app/core/api/dto/catalog/catalog_series_details_dto.dart';
export 'package:collectarr_app/core/api/dto/catalog/catalog_track_dto.dart';
export 'package:collectarr_app/core/api/dto/catalog/catalog_variant_dto.dart';
export 'package:collectarr_app/core/models/catalog_media_kind.dart';

class GameCatalogDetails {
  const GameCatalogDetails({this.platforms = const []});
  final List<String> platforms;
  bool get hasData => platforms.isNotEmpty;
  Map<String, dynamic> toJson() => {'platforms': platforms};
}

class VideoCatalogDetails {
  const VideoCatalogDetails({
    this.runtimeMinutes,
    this.color,
    this.nrDiscs,
    this.screenRatio,
    this.audioTracks,
    this.subtitles,
    this.layers,
  });
  final int? runtimeMinutes;
  final String? color;
  final int? nrDiscs;
  final String? screenRatio;
  final String? audioTracks;
  final String? subtitles;
  final String? layers;

  bool get hasData =>
      runtimeMinutes != null ||
      (color != null && color!.isNotEmpty) ||
      nrDiscs != null ||
      (screenRatio != null && screenRatio!.isNotEmpty) ||
      (audioTracks != null && audioTracks!.isNotEmpty) ||
      (subtitles != null && subtitles!.isNotEmpty) ||
      (layers != null && layers!.isNotEmpty);

  Map<String, dynamic> toJson() => {
        if (runtimeMinutes != null) 'runtime_minutes': runtimeMinutes,
        if (color != null) 'color': color,
        if (nrDiscs != null) 'nr_discs': nrDiscs,
        if (screenRatio != null) 'screen_ratio': screenRatio,
        if (audioTracks != null) 'audio_tracks': audioTracks,
        if (subtitles != null) 'subtitles': subtitles,
        if (layers != null) 'layers': layers,
      };
}

class MusicCatalogDetails {
  const MusicCatalogDetails({
    this.trackCount,
    this.tracks = const [],
    this.discs = const [],
    this.catalogNumber,
    this.releaseStatus,
  });
  final int? trackCount;
  final List<CatalogTrackDto> tracks;
  final List<CatalogDiscDto> discs;
  final String? catalogNumber;
  final String? releaseStatus;

  bool get hasData =>
      trackCount != null ||
      tracks.isNotEmpty ||
      discs.isNotEmpty ||
      (catalogNumber != null && catalogNumber!.isNotEmpty) ||
      (releaseStatus != null && releaseStatus!.isNotEmpty);

  Map<String, dynamic> toJson() => {
        if (trackCount != null) 'track_count': trackCount,
        if (tracks.isNotEmpty) 'tracks': tracks.map((e) => e.toJson()).toList(),
        if (discs.isNotEmpty) 'discs': discs.map((e) => e.toJson()).toList(),
        if (catalogNumber != null) 'catalog_number': catalogNumber,
        if (releaseStatus != null) 'release_status': releaseStatus,
      };
}

@immutable
final class CatalogItemDto {
  factory CatalogItemDto({
    required LibraryItemIdentity identity,
    required dynamic kindMetadata,
  }) =>
      CatalogItemDto._raw(
        id: identity.id,
        mediaKind: identity.mediaKind,
        payload: const <String, dynamic>{},
        kindMetadata: kindMetadata,
      );

  factory CatalogItemDto.raw({
    required String id,
    required CatalogMediaKind mediaKind,
    required CatalogCommonDto common,
    Map<String, dynamic> payload = const <String, dynamic>{},
    dynamic kindMetadata,
  }) {
    return CatalogItemDto._raw(
      id: id,
      mediaKind: mediaKind,
      payload: {
        ...common.toJson(),
        ...payload,
      },
      kindMetadata: kindMetadata,
    );
  }

  const CatalogItemDto._raw({
    required this.id,
    required this.mediaKind,
    required Map<String, dynamic> payload,
    dynamic kindMetadata,
  })  : _payload = payload,
        _kindMetadata = kindMetadata;

  final String id;
  final CatalogMediaKind mediaKind;
  final Map<String, dynamic> _payload;
  final dynamic _kindMetadata;

  Map<String, dynamic> get payload {
    final metadata = _kindMetadata;
    if (metadata is Map) {
      return Map<String, dynamic>.from(metadata);
    }
    if (metadata != null) {
      try {
        final raw = (metadata as dynamic).toSyncPayload();
        if (raw is Map) {
          return {
            ..._payload,
            ...Map<String, dynamic>.from(raw),
          };
        }
      } on Object {
        // Unsupported metadata falls back to the transport payload.
      }
    }
    return Map<String, dynamic>.from(_payload);
  }

  dynamic get kindMetadata => _kindMetadata ?? payload;

  LibraryItemIdentity get identity =>
      LibraryItemIdentity(id: id, mediaKind: mediaKind);

  CatalogCommonDto get common => CatalogCommonDto.fromJson(payload);

  String get kind => mediaKind.apiValue;

  String get title => common.title;
  String? get displayTitle => common.displayTitle;
  String? get localizedTitle => common.localizedTitle;
  String? get originalTitle => common.originalTitle;
  String? get titleExtension => common.titleExtension;
  List<String>? get searchAliases => common.searchAliases;
  String? get sortKey => common.sortKey;
  String? get synopsis => common.synopsis;
  String? get coverImageUrl => common.coverImageUrl;
  String? get thumbnailImageUrl => common.thumbnailImageUrl;
  String? get coverImageData => common.coverImageData;
  DateTime? get releaseDate => common.releaseDate;
  int? get releaseYear => common.releaseYear;
  List<TrailerLinkDto> get trailerUrls => common.trailerUrls;
  List<CatalogEditionDto> get editions => common.editions;

  String? get itemNumber => (payload['item_number'] ??
      (payload['publishing'] as Map?)?['issue_number']) as String?;
  String? get variant =>
      (payload['variant'] ?? (payload['publishing'] as Map?)?['variant'])
          as String?;
  String? get publisher => (payload['publisher'] ??
      (payload['publishing'] as Map?)?['original_publisher']) as String?;
  String? get barcode =>
      (payload['barcode'] ?? (payload['publishing'] as Map?)?['barcode'])
          as String?;
  String? get physicalFormat => (payload['physical_format'] ??
      (payload['publishing'] as Map?)?['physical_format']) as String?;
  String? get physicalFormatLabel => (payload['physical_format_label'] ??
      (payload['publishing'] as Map?)?['physical_format_label']) as String?;
  String? get editionTitle => (payload['edition_title'] ??
      (payload['publishing'] as Map?)?['edition_title']) as String?;

  String get resolvedDisplayTitle => common.resolvedDisplayTitle;
  String? get displayCoverUrl => common.displayCoverUrl;

  CatalogEntityRef get catalogRef => catalogRefForAnchor();

  CatalogEntityRef catalogRefForAnchor({
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
  }) {
    return catalogRefForPersonalAnchor(PersonalItemAnchor.fromRaw(
      anchorType: anchorType,
      editionId: editionId,
      variantId: variantId,
      bundleReleaseId: bundleReleaseId,
    ));
  }

  CatalogEntityRef catalogRefForPersonalAnchor(PersonalItemAnchor? anchor) {
    if (anchor == null || anchor.type == PersonalItemAnchorType.item) {
      return CatalogEntityRef(
        kind: kind,
        entityType: CatalogEntityType.work,
        id: id,
      );
    }
    switch (anchor.type) {
      case PersonalItemAnchorType.edition:
        return CatalogEntityRef(
          kind: kind,
          entityType: CatalogEntityType.edition,
          id: anchor.editionId ?? id,
        );
      case PersonalItemAnchorType.variant:
        return CatalogEntityRef(
          kind: kind,
          entityType: CatalogEntityType.release,
          id: anchor.variantId ?? anchor.editionId ?? id,
        );
      case PersonalItemAnchorType.bundleRelease:
        return CatalogEntityRef(
          kind: kind,
          entityType: CatalogEntityType.bundleRelease,
          id: anchor.bundleReleaseId ?? id,
        );
      default:
        return CatalogEntityRef(
          kind: kind,
          entityType: CatalogEntityType.work,
          id: id,
        );
    }
  }

  factory CatalogItemDto.fromEnvelope(CatalogItemEnvelopeDto envelope) {
    return CatalogItemDto.raw(
      id: envelope.id,
      mediaKind: envelope.kind,
      common: envelope.common,
      payload: envelope.payload,
    );
  }

  factory CatalogItemDto.fromJson(Map<String, dynamic> json) {
    final envelope = CatalogItemEnvelopeDto.fromJson(json);
    return CatalogItemDto.fromEnvelope(envelope);
  }

  Map<String, dynamic> toSyncPayload() {
    return {
      'snapshot_version': 1,
      'kind': kind,
      ...common.toJson(),
      ...payload,
    };
  }

  Map<String, dynamic> toJson() => toSyncPayload();

  CatalogItemEnvelopeDto toEnvelope() {
    return CatalogItemEnvelopeDto(
      ref: catalogRef,
      kind: mediaKind,
      common: common,
      payload: payload,
    );
  }

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
    Object? releaseYear = _unset,
    List<CatalogEditionDto>? editions,
    List<TrailerLinkDto>? trailerUrls,
    Object? physicalFormat = _unset,
    Object? physicalFormatLabel = _unset,
    dynamic kindMetadata,
  }) {
    final json = <String, dynamic>{
      ...payload,
      ...common.toJson(),
      'title': title ?? this.title,
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
      if (!identical(releaseYear, _unset)) 'release_year': releaseYear,
      if (editions != null)
        'editions': [for (final edition in editions) edition.toJson()],
      if (trailerUrls != null)
        'trailer_urls': [for (final link in trailerUrls) link.toJson()],
      if (!identical(physicalFormat, _unset)) 'physical_format': physicalFormat,
      if (!identical(physicalFormatLabel, _unset))
        'physical_format_label': physicalFormatLabel,
    };
    final updatedIdentity = identity ?? this.identity;
    final commonChanged = title != null ||
        !identical(displayTitle, _unset) ||
        !identical(localizedTitle, _unset) ||
        !identical(originalTitle, _unset) ||
        !identical(titleExtension, _unset) ||
        !identical(searchAliases, _unset) ||
        !identical(sortKey, _unset) ||
        !identical(synopsis, _unset) ||
        !identical(coverImageUrl, _unset) ||
        !identical(thumbnailImageUrl, _unset) ||
        !identical(coverImageData, _unset) ||
        !identical(releaseDate, _unset) ||
        !identical(releaseYear, _unset) ||
        editions != null ||
        trailerUrls != null ||
        !identical(physicalFormat, _unset) ||
        !identical(physicalFormatLabel, _unset);
    return CatalogItemDto._raw(
      id: updatedIdentity.id,
      mediaKind: updatedIdentity.mediaKind,
      payload: json,
      kindMetadata: kindMetadata ?? (commonChanged ? json : _kindMetadata),
    );
  }

  CatalogItemDto withKindMetadata(dynamic kindMetadata) {
    return CatalogItemDto._raw(
      id: id,
      mediaKind: mediaKind,
      payload: _payload,
      kindMetadata: kindMetadata,
    );
  }
}

typedef CatalogItem = CatalogItemDto;
typedef TrailerLink = TrailerLinkDto;

const _unset = Object();
