import 'package:flutter/widgets.dart';
import 'package:collectarr_app/core/api/dto/metadata_search_query.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/config/library_metadata_provider_models.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_source.dart';

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

/// Encapsulates metadata provider configuration and behavior for a media kind.
class LibraryMetadataCapability {
  const LibraryMetadataCapability({
    required this.defaultProviderId,
    required this.providers,
    required this.catalogMetadataDecoder,
    this.supportsServerCompare = false,
    this.usesTreeProviderCandidates = false,
    this.compareBuilder,
    this.searchQueryBuilder,
  });

  final String defaultProviderId;
  final List<LibraryMetadataProviderOption> providers;
  final LibraryMetadataCatalogDecoder catalogMetadataDecoder;
  final bool supportsServerCompare;
  final bool usesTreeProviderCandidates;
  final MetadataCompareBuilder? compareBuilder;
  final LibraryMetadataSearchQueryBuilder? searchQueryBuilder;

  MetadataSearchQuery searchQueryFor({
    required LibraryWorkspaceSource source,
    required String title,
  }) {
    return searchQueryBuilder?.call(source: source, title: title) ??
        MetadataSearchQuery(query: title, limit: 5);
  }

  List<LibraryMetadataProviderOption> supportedProvidersForKind(
      CatalogMediaKind kind) {
    if (kind.isUnknown) {
      return providers;
    }
    return [
      for (final option in providers)
        if (option.supportsKind(kind)) option,
    ];
  }

  LibraryMetadataProviderOption? defaultSupportedOption(CatalogMediaKind kind) {
    final supported = supportedProvidersForKind(kind);
    for (final option in supported) {
      if (option.id == defaultProviderId) {
        return option;
      }
    }
    return supported.isEmpty ? null : supported.first;
  }

  bool supportsProvider(String providerId, [CatalogMediaKind? kind]) {
    final list = kind != null ? supportedProvidersForKind(kind) : providers;
    return list.any((option) => option.id == providerId);
  }

  String providerLabel(String providerId) {
    for (final option in providers) {
      if (option.id == providerId) {
        return option.label;
      }
    }
    return providerId;
  }
}
