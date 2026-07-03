import 'package:cached_network_image/cached_network_image.dart';
import 'package:collectarr_app/core/models/season.dart';
import 'package:collectarr_app/features/library/providers/seasons_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SeasonsSection extends ConsumerWidget {
  const SeasonsSection({
    super.key,
    this.provider,
    this.providerItemId,
    this.itemId,
    this.kind,
  })  : assert(
          itemId != null || (provider != null && providerItemId != null),
          'Provide itemId or provider + providerItemId.',
        ),
        assert(
          itemId == null || (provider == null && providerItemId == null),
          'Use either itemId or provider + providerItemId.',
        );

  final String? provider;
  final String? providerItemId;
  final String? itemId;
  final String? kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seasonsAsync = itemId != null
        ? ref.watch(itemSeasonsProvider((itemId: itemId!, kind: kind)))
        : ref.watch(
            seasonsProvider(
              (provider: provider!, providerItemId: providerItemId!),
            ),
          );

    return seasonsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (seasons) {
        if (seasons.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Seasons',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ...seasons.map((season) => _SeasonTile(season: season)),
          ],
        );
      },
    );
  }
}

class _SeasonTile extends StatefulWidget {
  const _SeasonTile({required this.season});

  final Season season;

  @override
  State<_SeasonTile> createState() => _SeasonTileState();
}

class _SeasonTileState extends State<_SeasonTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final season = widget.season;
    return Column(
      children: [
        ListTile(
          leading: season.posterUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CachedNetworkImage(
                    imageUrl: season.posterUrl!,
                    width: 40,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                )
              : const Icon(Icons.tv),
          title: Text(season.title),
          subtitle: Text(
            [
              if (season.episodeCount != null)
                '${season.episodeCount} episodes',
              if (season.airDate != null) season.airDate!,
            ].join(' · '),
          ),
          trailing: Icon(
            _expanded ? Icons.expand_less : Icons.expand_more,
          ),
          onTap: () => setState(() => _expanded = !_expanded),
        ),
        if (_expanded && season.episodes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 56, right: 16, bottom: 8),
            child: Column(
              children: season.episodes
                  .map((ep) => _EpisodeRow(episode: ep))
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _EpisodeRow extends StatelessWidget {
  const _EpisodeRow({required this.episode});

  final Episode episode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '${episode.episodeNumber}',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  episode.title,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (episode.runtimeMinutes != null)
                  Text(
                    '${episode.runtimeMinutes} min',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
