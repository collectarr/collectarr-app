import 'package:flutter/widgets.dart';
import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/dto/catalog_search_page.dart';
import 'package:collectarr_app/core/api/dto/metadata_search_query.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_kind_transport_codec.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_context.dart';
import 'package:dio/dio.dart';

typedef LibraryMetadataCatalogSearchBuilder = Future<CatalogSearchPage>
    Function({
  required ApiClient api,
  required MetadataSearchQuery query,
  CancelToken? cancelToken,
});

typedef LibraryMetadataSearchQueryBuilder = MetadataSearchQuery Function({
  required LibraryWorkspaceContext source,
  required String title,
});

typedef LibraryMetadataCatalogDetailCandidateBuilder = CatalogSearchCandidate
    Function(
  JsonMap payload,
);

enum LibraryMetadataMatchScore { high, medium, low }

typedef LibraryMetadataMatchScorer = LibraryMetadataMatchScore Function(
    LibraryWorkspaceContext source, CatalogSearchCandidate candidate);

typedef MetadataCompareBuilder = List<Widget> Function(
  BuildContext context, {
  required Map<String, dynamic> localPayload,
  required Map<String, dynamic> serverPayload,
  required Color accent,
});

/// Defines how a kind searches and decodes canonical catalog metadata.
class LibraryMetadataCapability {
  const LibraryMetadataCapability({
    required this.catalogTransportCodec,
    this.supportsServerCompare = false,
    this.compareBuilder,
    this.searchQueryBuilder,
    this.catalogSearchBuilder,
    this.catalogSearchResultsAreDetailed = false,
    this.catalogDetailCandidateBuilder,
    this.matchScorer,
  });

  final CatalogKindTransportBoundary catalogTransportCodec;
  final bool supportsServerCompare;
  final MetadataCompareBuilder? compareBuilder;
  final LibraryMetadataSearchQueryBuilder? searchQueryBuilder;
  final LibraryMetadataCatalogSearchBuilder? catalogSearchBuilder;
  final bool catalogSearchResultsAreDetailed;
  final LibraryMetadataMatchScorer? matchScorer;
  final LibraryMetadataCatalogDetailCandidateBuilder?
      catalogDetailCandidateBuilder;

  MetadataSearchQuery searchQueryFor({
    required LibraryWorkspaceContext source,
    required String title,
  }) {
    return searchQueryBuilder?.call(source: source, title: title) ??
        MetadataSearchQuery(query: title, limit: 5);
  }
}
