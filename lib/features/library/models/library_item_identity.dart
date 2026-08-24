import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:flutter/foundation.dart';

@immutable
class LibraryItemIdentity {
  const LibraryItemIdentity({
    required this.id,
    required this.mediaKind,
    this.externalIds = const <String, String>{},
    this.providerProvenance,
  });

  final String id;
  final CatalogMediaKind mediaKind;
  final Map<String, String> externalIds;
  final String? providerProvenance;

  String get kind => mediaKind.apiValue;

  LibraryItemIdentity copyWith({
    String? id,
    CatalogMediaKind? mediaKind,
    Map<String, String>? externalIds,
    String? providerProvenance,
  }) {
    return LibraryItemIdentity(
      id: id ?? this.id,
      mediaKind: mediaKind ?? this.mediaKind,
      externalIds: externalIds ?? this.externalIds,
      providerProvenance: providerProvenance ?? this.providerProvenance,
    );
  }
}
