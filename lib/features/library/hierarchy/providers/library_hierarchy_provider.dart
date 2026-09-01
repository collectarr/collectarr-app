import 'package:collectarr_app/core/models/catalog_media_kind.dart';
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
      final api = ref.watch(apiClientProvider);
      final nodes = await hierarchy.fetchChildren(
        api: api,
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
        final list = envelope.normalized['children'];
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

  return const <LibraryHierarchyNode>[];
});

LibraryHierarchyNode _mapRawNode(Map<String, dynamic> raw, int fallbackIndex) {
  final id = (raw['id'] ?? raw['ref_id'] ?? 'node_$fallbackIndex').toString();
  final title =
      (raw['title'] ?? raw['name'] ?? 'Item $fallbackIndex').toString();
  final children = _childNodes(raw, fallbackIndex);
  final itemCount =
      _intValue(raw['total_count'] ?? raw['totalCount']) ?? children.length;
  final countLabel = '$itemCount items';
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
    totalCount: itemCount,
    children: children,
    metadata: raw,
  );
}

List<LibraryHierarchyNode> _childNodes(
  Map<String, dynamic> raw,
  int fallbackIndex,
) {
  final rawChildren = raw['children'];
  if (rawChildren is! List) {
    return const <LibraryHierarchyNode>[];
  }
  return [
    for (var index = 0; index < rawChildren.length; index++)
      if (rawChildren[index] is Map)
        _mapRawNode(
          Map<String, dynamic>.from(rawChildren[index] as Map),
          fallbackIndex * 1000 + index + 1,
        ),
  ];
}

int? _intValue(Object? value) => switch (value) {
      int value => value,
      num value => value.toInt(),
      String value => int.tryParse(value),
      _ => null,
    };
