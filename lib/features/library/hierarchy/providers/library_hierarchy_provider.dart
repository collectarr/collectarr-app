import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_data_capability.dart';
import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/providers/providers_sdk.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final libraryHierarchyProvider = FutureProvider.autoDispose.family<
    List<LibraryHierarchyNode>,
    ({
      CatalogMediaKind kind,
      String? itemId,
      String? provider,
      String? providerItemId,
      bool canHydrateFromCore,
    })>((ref, params) async {
  final kindRuntime = lookupLibraryKind(params.kind);
  final hierarchy = kindRuntime?.hierarchy;
  if (hierarchy != null && params.itemId != null) {
    try {
      final nodes = await hierarchy.fetchChildren(
        itemId: params.itemId!,
        provider: params.provider,
        providerItemId: params.providerItemId,
      );
      if (nodes.isNotEmpty) {
        return nodes;
      }
    } catch (_) {}
  }

  if (params.provider != null && params.providerItemId != null) {
    final registry = await ref.watch(providerRegistryProvider.future);
    final adapter = registry.get(params.provider!);
    if (adapter != null) {
      try {
        final envelope = await adapter.fetchItem(
          params.providerItemId!,
          kind: params.kind.apiValue,
        );
        final list = envelope.normalized['children'] ??
            envelope.normalized['seasons'] ??
            envelope.normalized['volumes'] ??
            envelope.normalized['discs'];
        if (list is List) {
          return [
            for (var i = 0; i < list.length; i++)
              if (list[i] is Map)
                _mapRawNode(Map<String, dynamic>.from(list[i] as Map), i + 1),
          ];
        }
      } catch (_) {}
    }
  }

  if (params.itemId != null && params.canHydrateFromCore) {
    final api = ref.watch(apiClientProvider);
    try {
      if (params.kind == CatalogMediaKind.tv) {
        final seasons = await api
            .getTvSeriesSeasonsDto(params.itemId!)
            .timeout(const Duration(seconds: 60));
        return [
          for (final s in seasons)
            LibraryHierarchyNode(
              id: s.id ?? 'season_${s.seasonNumber ?? 0}',
              label: s.title,
              secondaryLabel:
                  s.episodeCount != null ? '${s.episodeCount} episodes' : null,
              level: LibraryHierarchyLevel.container,
              imageUrl: s.coverImageUrlValue,
              totalCount: s.episodeCount,
              metadata: {
                'seasonNumber': s.seasonNumber,
                'airDate': s.airDateValue?.toIso8601String(),
              },
            ),
        ];
      }
      final volumes = await api
          .getItemVolumes(params.itemId!, kind: params.kind.apiValue)
          .timeout(const Duration(seconds: 60));
      return [
        for (final v in volumes)
          LibraryHierarchyNode(
            id: 'vol_${v.seasonNumber}',
            label: v.title,
            secondaryLabel:
                v.episodeCount != null ? '${v.episodeCount} items' : null,
            level: LibraryHierarchyLevel.container,
            imageUrl: v.posterUrl,
            totalCount: v.episodeCount,
            metadata: {
              'number': v.seasonNumber,
              'airDate': v.airDate,
            },
          ),
      ];
    } catch (_) {}
  }

  return const <LibraryHierarchyNode>[];
});

LibraryHierarchyNode _mapRawNode(Map<String, dynamic> raw, int fallbackIndex) {
  final id = (raw['id'] ?? raw['ref_id'] ?? 'node_$fallbackIndex').toString();
  final title =
      (raw['title'] ?? raw['name'] ?? 'Item $fallbackIndex').toString();
  final episodeCount = raw['episode_count'] as int? ??
      raw['chapter_count'] as int? ??
      raw['track_count'] as int?;
  final countLabel = episodeCount != null ? '$episodeCount items' : null;
  final posterUrl = (raw['poster_url'] ??
          raw['cover_image_url'] ??
          raw['image_url'] ??
          raw['cover_url'])
      ?.toString();

  return LibraryHierarchyNode(
    id: id,
    label: title,
    secondaryLabel: countLabel,
    level: LibraryHierarchyLevel.container,
    imageUrl: posterUrl,
    totalCount: episodeCount,
    metadata: raw,
  );
}
