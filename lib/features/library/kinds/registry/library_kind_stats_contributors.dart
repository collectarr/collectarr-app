import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_stats_registry.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';

LibraryStatsCapability libraryStatsForKind(CatalogMediaKind kind) =>
    collectarrKindStats[kind]!;

LibraryValueCapability? libraryValueForKind(CatalogMediaKind kind) =>
    collectarrKindValues[kind];

LibraryRelationCapability? libraryRelationsForKind(CatalogMediaKind kind) =>
    collectarrKindRelations[kind];

LibraryUiPolicy libraryUiPolicyForKind(CatalogMediaKind kind) =>
    collectarrKindUiPolicies[kind]!;

LibraryLinkedMetadataCapability libraryLinkedMetadataForKind(
  CatalogMediaKind kind,
) =>
    collectarrKindLinkedMetadata[kind]!;
