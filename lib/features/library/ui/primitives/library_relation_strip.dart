import 'package:cached_network_image/cached_network_image.dart';
import 'package:collectarr_app/core/models/library_relation_node.dart';
import 'package:flutter/material.dart';

class LibraryRelationStrip extends StatelessWidget {
  const LibraryRelationStrip({
    super.key,
    required this.relations,
    this.title = 'Related',
    this.onRelationTap,
  });

  final List<LibraryRelationNode> relations;
  final String title;
  final ValueChanged<LibraryRelationNode>? onRelationTap;

  @override
  Widget build(BuildContext context) {
    if (relations.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: relations.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final relation = relations[index];
              final card = _RelationCard(relation: relation);
              if (onRelationTap == null) {
                return card;
              }
              return InkWell(
                onTap: () => onRelationTap!(relation),
                borderRadius: BorderRadius.circular(6),
                child: card,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RelationCard extends StatelessWidget {
  const _RelationCard({required this.relation});

  final LibraryRelationNode relation;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 80,
              height: 80,
              child: relation.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: relation.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const ColoredBox(
                        color: Colors.black12,
                        child: Icon(Icons.image, size: 32),
                      ),
                      errorWidget: (_, __, ___) => const ColoredBox(
                        color: Colors.black12,
                        child: Icon(Icons.broken_image, size: 32),
                      ),
                    )
                  : const ColoredBox(
                      color: Colors.black12,
                      child: Icon(
                        Icons.collections_bookmark_outlined,
                        size: 32,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            relation.relationLabel,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            relation.targetTitle,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
