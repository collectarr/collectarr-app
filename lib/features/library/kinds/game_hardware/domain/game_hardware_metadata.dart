import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:flutter/foundation.dart';

@immutable
final class GameHardwareCatalogLink implements JsonEncodable {
  const GameHardwareCatalogLink(
      {required this.url,
      this.title,
      this.description,
      this.kind = 'external'});
  final String url;
  final String? title;
  final String? description;
  final String kind;
  bool get isExternalLink => kind == 'external';
  bool get isTrailerLink => kind == 'trailer';
  factory GameHardwareCatalogLink.fromJson(Map<String, dynamic> json,
          {String? kind}) =>
      GameHardwareCatalogLink(
          url: json['url'] as String,
          title: json['title'] as String?,
          description: json['description'] as String?,
          kind: kind ?? json['kind'] as String? ?? 'external');
  @override
  Map<String, dynamic> toJson() => {
        'url': url,
        if (title != null) 'title': title,
        if (description != null) 'description': description
      };
}

@immutable
final class GameHardwareCatalogMetadata implements JsonEncodable {
  const GameHardwareCatalogMetadata(
      {required this.title,
      this.sortKey,
      this.barcode,
      this.seriesTitle,
      this.description,
      this.coverImageUrl,
      this.platform,
      this.hardwareType,
      this.releaseDateParts,
      this.links = const []});
  final String title;
  final String? sortKey;
  final String? barcode;
  final String? seriesTitle;
  final String? description;
  final String? coverImageUrl;
  final String? platform;
  final String? hardwareType;
  final PartialDate? releaseDateParts;
  final List<GameHardwareCatalogLink> links;
  CatalogMediaKind get mediaKind => CatalogMediaKind.gameHardware;
  DateTime? get releaseDate => releaseDateParts?.asDateTime;
  String? get thumbnailImageUrl => coverImageUrl;
  Map<String, dynamic> toSyncPayload() => toJson();
  @override
  Map<String, dynamic> toJson() => {
        'title': title,
        if (sortKey != null) 'sort_key': sortKey,
        if (barcode != null) 'barcode': barcode,
        if (seriesTitle != null) 'series_title': seriesTitle,
        if (description != null) 'description': description,
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
        if (platform != null) 'platform': platform,
        if (hardwareType != null) 'hardware_type': hardwareType,
        if (releaseDateParts != null)
          'release_date_parts': releaseDateParts!.toJson(),
        if (links.any((link) => link.isExternalLink))
          'external_links': [
            for (final link in links.where((link) => link.isExternalLink))
              link.toJson()
          ],
        if (links.any((link) => link.isTrailerLink))
          'trailer_urls': [
            for (final link in links.where((link) => link.isTrailerLink))
              link.toJson()
          ],
      };
  factory GameHardwareCatalogMetadata.fromJson(Map<String, dynamic> json) =>
      GameHardwareCatalogMetadata(
        title: json['title'] as String? ?? '',
        sortKey: json['sort_key'] as String?,
        barcode: json['barcode'] as String?,
        seriesTitle: json['series_title'] as String?,
        description: json['description'] as String?,
        coverImageUrl: json['cover_image_url'] as String?,
        platform: json['platform'] as String?,
        hardwareType: json['hardware_type'] as String?,
        releaseDateParts: PartialDate.tryParse(json['release_date_parts']),
        links: [
          for (final value in json['external_links'] as List? ?? const [])
            GameHardwareCatalogLink.fromJson(
                Map<String, dynamic>.from(value as Map),
                kind: 'external'),
          for (final value in json['trailer_urls'] as List? ?? const [])
            GameHardwareCatalogLink.fromJson(
                Map<String, dynamic>.from(value as Map),
                kind: 'trailer'),
        ],
      );
}
