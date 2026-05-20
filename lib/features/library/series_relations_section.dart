import 'package:cached_network_image/cached_network_image.dart';
import 'package:collectarr_app/core/models/series_relation.dart';
import 'package:collectarr_app/features/library/providers/series_relations_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SeriesRelationsSection extends ConsumerWidget {
  const SeriesRelationsSection({super.key, required this.seriesId});

  final String seriesId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relationsAsync = ref.watch(seriesRelationsProvider(seriesId));

    return relationsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (relations) {
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
                'Related Series',
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
                itemBuilder: (context, index) =>
                    _RelationCard(relation: relations[index]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RelationCard extends StatelessWidget {
  const _RelationCard({required this.relation});

  final SeriesRelation relation;

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
                      child: Icon(Icons.movie, size: 32),
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
            relation.targetSeriesTitle,
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
