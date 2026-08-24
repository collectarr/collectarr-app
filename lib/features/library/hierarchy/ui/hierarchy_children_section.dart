import 'package:cached_network_image/cached_network_image.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';
import 'package:collectarr_app/features/library/hierarchy/providers/library_hierarchy_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HierarchyChildrenSection extends ConsumerWidget {
  const HierarchyChildrenSection({
    super.key,
    required this.kind,
    this.title,
    this.provider,
    this.providerItemId,
    this.itemId,
    this.canHydrateFromCore = false,
  })  : assert(
          itemId != null || (provider != null && providerItemId != null),
          'Provide itemId or provider + providerItemId.',
        ),
        assert(
          itemId == null || (provider == null && providerItemId == null),
          'Use either itemId or provider + providerItemId.',
        );

  final CatalogMediaKind kind;
  final String? title;
  final String? provider;
  final String? providerItemId;
  final String? itemId;
  final bool canHydrateFromCore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nodesAsync = ref.watch(
      libraryHierarchyProvider((
        kind: kind,
        itemId: itemId,
        provider: provider,
        providerItemId: providerItemId,
        canHydrateFromCore: canHydrateFromCore,
      )),
    );

    return nodesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (nodes) {
        if (nodes.isEmpty) {
          return const SizedBox.shrink();
        }
        final resolvedTitle = title ??
          libraryKindRuntimeForKind(kind)
            .hierarchy
            .childrenTitle(nodes.length);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                resolvedTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: nodes.length,
              itemBuilder: (_, index) => _HierarchyNodeTile(node: nodes[index]),
            ),
          ],
        );
      },
    );
  }

}

class _HierarchyNodeTile extends StatefulWidget {
  const _HierarchyNodeTile({required this.node});

  final LibraryHierarchyNode node;

  @override
  State<_HierarchyNodeTile> createState() => _HierarchyNodeTileState();
}

class _HierarchyNodeTileState extends State<_HierarchyNodeTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final node = widget.node;
    final hasChildren = node.children.isNotEmpty;

    return Column(
      children: [
        ListTile(
          leading: node.imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CachedNetworkImage(
                    imageUrl: node.imageUrl!,
                    width: 40,
                    height: 60,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.folder_outlined),
                  ),
                )
              : const Icon(Icons.folder_outlined),
          title: Text(node.label),
          subtitle:
              node.secondaryLabel != null ? Text(node.secondaryLabel!) : null,
          trailing: hasChildren
              ? IconButton(
                  icon: Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                  onPressed: () => setState(() => _expanded = !_expanded),
                )
              : (node.actions.isNotEmpty
                  ? IconButton(
                      icon: Icon(node.actions.first.icon ?? Icons.more_vert),
                      onPressed: node.actions.first.onTap,
                    )
                  : null),
          onTap:
              hasChildren ? () => setState(() => _expanded = !_expanded) : null,
        ),
        if (_expanded && hasChildren)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              children: [
                for (final child in node.children)
                  _HierarchyNodeTile(node: child),
              ],
            ),
          ),
      ],
    );
  }
}
