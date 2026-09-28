import 'dart:convert';

import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';

const _writeSchemaNames = <CatalogMediaKind, String>{
  CatalogMediaKind.anime: 'AnimeCatalogDetailsV1',
  CatalogMediaKind.boardgame: 'BoardGameCatalogDetailsV1',
  CatalogMediaKind.book: 'BookCatalogDetailsV1',
  CatalogMediaKind.comic: 'ComicCatalogDetailsV1',
  CatalogMediaKind.game: 'GameCatalogDetailsV1',
  CatalogMediaKind.manga: 'MangaCatalogDetailsV1',
  CatalogMediaKind.movie: 'MovieCatalogDetailsV1-Input',
  CatalogMediaKind.music: 'MusicCatalogWriteDetailsV1',
  CatalogMediaKind.tv: 'TVCatalogDetailsV1',
};

/// Schema definitions from the App-pinned Catalog Item v1 contract.
///
/// UI forms, workspace projections, and exports use this same definition so
/// a contract field cannot silently disappear from one of those surfaces.
final Map<String, dynamic> catalogItemV1SchemaDefinitions =
    (jsonDecode(catalogItemV1ContractSchemaJson)
        as Map<String, dynamic>)[r'$defs'] as Map<String, dynamic>;

Map<String, dynamic> catalogItemV1WriteSchemaForKind(
  CatalogMediaKind kind,
) {
  final name = _writeSchemaNames[kind];
  final schema = name == null ? null : catalogItemV1SchemaDefinitions[name];
  if (schema is! Map<String, dynamic>) {
    throw StateError('Missing Catalog Item v1 write schema for $kind.');
  }
  return schema;
}
