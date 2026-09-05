import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';
import 'package:collectarr_app/features/library/hierarchy/providers/library_hierarchy_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VideoAddPreviewSeasonsSection extends ConsumerWidget {
  const VideoAddPreviewSeasonsSection({
    super.key,
    required this.kind,
    required this.provider,
    required this.providerItemId,
    required this.accent,
  });

  final CatalogMediaKind kind;
  final String provider;
  final String providerItemId;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = appPalette(context);
    final seasonsAsync = ref.watch(
      libraryHierarchyProvider((
        kind: kind,
        provider: provider,
        providerItemId: providerItemId,
        itemId: null,
        canHydrateFromCore: false,
      )),
    );

    return seasonsAsync.when(
      loading: () => Padding(
        padding: const EdgeInsets.only(top: 22),
        child: Row(
          children: [
            const SizedBox.square(
              dimension: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text(
              'Loading seasons...',
              style: TextStyle(color: palette.textMuted),
            ),
          ],
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (seasons) {
        if (seasons.isEmpty) return const SizedBox.shrink();
        final totalEpisodes = seasons.fold<int>(
          0,
          (sum, season) => sum + (season.totalCount ?? season.children.length),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seasons (${seasons.length}) · $totalEpisodes episodes',
              style: TextStyle(color: accent),
            ),
            const SizedBox(height: 8),
            for (final season in seasons)
              _VideoAddPreviewSeasonNode(season: season, accent: accent),
          ],
        );
      },
    );
  }
}

class _VideoAddPreviewSeasonNode extends StatefulWidget {
  const _VideoAddPreviewSeasonNode({
    required this.season,
    required this.accent,
  });

  final LibraryHierarchyNode season;
  final Color accent;

  @override
  State<_VideoAddPreviewSeasonNode> createState() =>
      _VideoAddPreviewSeasonNodeState();
}

class _VideoAddPreviewSeasonNodeState
    extends State<_VideoAddPreviewSeasonNode> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final season = widget.season;
    final episodeCount = season.totalCount ?? season.children.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: season.children.isNotEmpty
              ? () => setState(() => _expanded = !_expanded)
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                if (season.imageUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: Image.network(
                      season.imageUrl!,
                      width: 28,
                      height: 42,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        season.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        [
                          '$episodeCount episodes',
                          if (_airDate(season) != null) _airDate(season)!,
                        ].join(' · '),
                        style: TextStyle(
                          color: palette.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (season.children.isNotEmpty)
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: palette.textMuted,
                  ),
              ],
            ),
          ),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.only(left: 36, bottom: 4),
            child: Column(
              children: [
                for (final episode in season.children)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 26,
                          child: Text(
                            _episodeNumber(episode),
                            style: TextStyle(
                              color: widget.accent.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            episode.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (_runtimeMinutes(episode) != null)
                          Text(
                            '${_runtimeMinutes(episode)} min',
                            style: TextStyle(
                              color: palette.textMuted,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

String? _airDate(LibraryHierarchyNode node) =>
    (node.metadata['air_date'] ?? node.metadata['airDate'])?.toString();

String _episodeNumber(LibraryHierarchyNode node) =>
    (node.metadata['episode_number'] ??
            node.metadata['episodeNumber'] ??
            node.metadata['number'] ??
            node.id)
        .toString();

int? _runtimeMinutes(LibraryHierarchyNode node) {
  final value = node.metadata['runtime_minutes'] ??
      node.metadata['runtimeMinutes'] ??
      node.metadata['runtime'];
  return switch (value) {
    int value => value,
    num value => value.toInt(),
    String value => int.tryParse(value),
    _ => null,
  };
}
