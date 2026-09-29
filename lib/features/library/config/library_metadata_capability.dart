import 'package:flutter/widgets.dart';
import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/dto/metadata_search_query.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_source.dart';
import 'package:dio/dio.dart';

typedef LibraryMetadataCatalogSearchBuilder =
    Future<List<Map<String, dynamic>>> Function({
  required ApiClient api,
  required MetadataSearchQuery query,
  CancelToken? cancelToken,
});

typedef LibraryMetadataSearchQueryBuilder = MetadataSearchQuery Function({
  required LibraryWorkspaceSource source,
  required String title,
});

typedef LibraryMetadataCatalogDecoder = JsonEncodable Function(
  JsonMap payload,
);

typedef MetadataCompareBuilder = List<Widget> Function(
  BuildContext context, {
  required Map<String, dynamic> localPayload,
  required Map<String, dynamic> serverPayload,
  required Color accent,
});

/// Defines how a kind searches and decodes canonical catalog metadata.
class LibraryMetadataCapability {
  const LibraryMetadataCapability({
    required this.catalogMetadataDecoder,
    this.supportsServerCompare = false,
    this.compareBuilder,
    this.searchQueryBuilder,
    this.catalogSearchBuilder,
    this.catalogSearchResultsAreDetailed = false,
  });

  final LibraryMetadataCatalogDecoder catalogMetadataDecoder;
  final bool supportsServerCompare;
  final MetadataCompareBuilder? compareBuilder;
  final LibraryMetadataSearchQueryBuilder? searchQueryBuilder;
  final LibraryMetadataCatalogSearchBuilder? catalogSearchBuilder;
  final bool catalogSearchResultsAreDetailed;

  MetadataSearchQuery searchQueryFor({
    required LibraryWorkspaceSource source,
    required String title,
  }) {
    return searchQueryBuilder?.call(source: source, title: title) ??
        MetadataSearchQuery(query: title, limit: 5);
  }
}
