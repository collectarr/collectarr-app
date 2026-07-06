import 'dart:math' as math;

import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/season.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_domain.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace_entry_builder.dart';
import 'package:collectarr_app/features/library/providers/seasons_provider.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TvShelfSeasonDrilldown extends ConsumerWidget {
  const TvShelfSeasonDrilldown({
    super.key,
    required this.titleEntry,
    required this.coverSize,
    required this.accent,
    required this.onBack,
    required this.onRefreshFromCore,
    required this.onOpenTitleDetails,
    this.seasonsOverride,
  });

  final LibraryWorkspaceEntry titleEntry;
  final double coverSize;
  final Color accent;
  final VoidCallback onBack;
  final Future<void> Function() onRefreshFromCore;
  final VoidCallback onOpenTitleDetails;
  final List<Season>? seasonsOverride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = appPalette(context);
    final seasons = seasonsOverride;
    if (seasons != null) {
      return _buildWithSeasons(context, seasons);
    }
    final seriesRef = CatalogEntityRef(
      kind: titleEntry.mediaType,
      entityType: CatalogEntityType.work,
      id: titleEntry.canonicalItemId,
    );
    final seasonsAsync = ref.watch(seasonsByCatalogRefProvider(seriesRef));
    return seasonsAsync.when(
      loading: () => _TvShelfDrilldownShell(
        titleEntry: titleEntry,
        accent: accent,
        onBack: onBack,
        onRefreshFromCore: onRefreshFromCore,
        onOpenTitleDetails: onOpenTitleDetails,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => _TvShelfDrilldownShell(
        titleEntry: titleEntry,
        accent: accent,
        onBack: onBack,
        onRefreshFromCore: onRefreshFromCore,
        onOpenTitleDetails: onOpenTitleDetails,
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            error.toString(),
            style: TextStyle(color: palette.textMuted),
          ),
        ),
      ),
      data: (seasons) => _buildWithSeasons(context, seasons),
    );
  }

  Widget _buildWithSeasons(BuildContext context, List<Season> seasons) {
    final palette = appPalette(context);
    final series = _buildSeriesSnapshot(titleEntry, seasons);
    final seasonEntries = [
      for (final season in seasons)
        _TvShelfSeasonItem(
          season: season,
          entry: buildTvSeasonWorkspaceEntry(
            series: series,
            season: _toTvSeason(series.id, season),
            overlay: TvPersonalOverlay(
              updatedAt: titleEntry.updatedAt,
              isOwnedOverride: titleEntry.isOwned,
              isTrackedOverride: titleEntry.isTracked,
              isWishlistedOverride: titleEntry.isWishlisted,
            ),
          ),
        ),
    ];
    if (seasonEntries.isEmpty) {
      return _TvShelfDrilldownShell(
        titleEntry: titleEntry,
        accent: accent,
        onBack: onBack,
        onRefreshFromCore: onRefreshFromCore,
        onOpenTitleDetails: onOpenTitleDetails,
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No season data is available for this TV show yet.',
            style: TextStyle(color: palette.textMuted),
          ),
        ),
      );
    }
    return _TvShelfSeasonDrilldownBody(
      titleEntry: titleEntry,
      series: series,
      seasonEntries: seasonEntries,
      coverSize: coverSize,
      accent: accent,
      onBack: onBack,
      onRefreshFromCore: onRefreshFromCore,
      onOpenTitleDetails: onOpenTitleDetails,
    );
  }
}

class _TvShelfDrilldownShell extends StatelessWidget {
  const _TvShelfDrilldownShell({
    required this.titleEntry,
    required this.accent,
    required this.onBack,
    required this.onRefreshFromCore,
    required this.onOpenTitleDetails,
    required this.body,
  });

  final LibraryWorkspaceEntry titleEntry;
  final Color accent;
  final VoidCallback onBack;
  final Future<void> Function() onRefreshFromCore;
  final VoidCallback onOpenTitleDetails;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: kAppPanel,
            border: Border(
              bottom: BorderSide(color: accent.withValues(alpha: 0.28)),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Back to titles',
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seasons',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: palette.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        titleEntry.resolvedTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: palette.textMuted,
                            ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onOpenTitleDetails,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open browser'),
                ),
                const SizedBox(width: 8),
                FilledButton.tonalIcon(
                  onPressed: onRefreshFromCore,
                  icon: const Icon(Icons.travel_explore_outlined),
                  label: const Text('Refresh seasons'),
                ),
              ],
            ),
          ),
        ),
        Expanded(child: body),
      ],
    );
  }
}

class _TvShelfSeasonDrilldownBody extends StatefulWidget {
  const _TvShelfSeasonDrilldownBody({
    required this.titleEntry,
    required this.series,
    required this.seasonEntries,
    required this.coverSize,
    required this.accent,
    required this.onBack,
    required this.onRefreshFromCore,
    required this.onOpenTitleDetails,
  });

  final LibraryWorkspaceEntry titleEntry;
  final TvSeries series;
  final List<_TvShelfSeasonItem> seasonEntries;
  final double coverSize;
  final Color accent;
  final VoidCallback onBack;
  final Future<void> Function() onRefreshFromCore;
  final VoidCallback onOpenTitleDetails;

  @override
  State<_TvShelfSeasonDrilldownBody> createState() =>
      _TvShelfSeasonDrilldownBodyState();
}

class _TvShelfSeasonDrilldownBodyState
    extends State<_TvShelfSeasonDrilldownBody> {
  int? _expandedSeasonNumber;

  @override
  void initState() {
    super.initState();
    _expandedSeasonNumber =
        widget.seasonEntries.isEmpty ? null : widget.seasonEntries.first.season.seasonNumber;
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: kAppPanel,
            border: Border(
              bottom: BorderSide(color: widget.accent.withValues(alpha: 0.28)),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Back to titles',
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seasons',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: palette.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.titleEntry.resolvedTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: palette.textMuted,
                            ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: widget.onOpenTitleDetails,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open browser'),
                ),
                const SizedBox(width: 8),
                FilledButton.tonalIcon(
                  onPressed: widget.onRefreshFromCore,
                  icon: const Icon(Icons.travel_explore_outlined),
                  label: const Text('Refresh seasons'),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _TvShelfSeriesHeader(
                series: widget.series,
                seasonCount: widget.seasonEntries.length,
              ),
              const SizedBox(height: 16),
              for (final seasonItem in widget.seasonEntries) ...[
                _TvSeasonExpansionCard(
                  item: seasonItem,
                  coverSize: widget.coverSize,
                  accent: widget.accent,
                  expanded: _expandedSeasonNumber ==
                      seasonItem.season.seasonNumber,
                  onTap: () {
                    setState(() {
                      _expandedSeasonNumber = _expandedSeasonNumber ==
                              seasonItem.season.seasonNumber
                          ? null
                          : seasonItem.season.seasonNumber;
                    });
                  },
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TvShelfSeriesHeader extends StatelessWidget {
  const _TvShelfSeriesHeader({
    required this.series,
    required this.seasonCount,
  });

  final TvSeries series;
  final int seasonCount;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final totalEpisodes = series.seasons.fold<int>(
      0,
      (sum, season) => sum + season.episodes.length,
    );
    return Card(
      elevation: 0,
      color: palette.panel,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              series.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              '$seasonCount seasons · $totalEpisodes episodes',
              style: TextStyle(color: palette.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _TvSeasonExpansionCard extends StatelessWidget {
  const _TvSeasonExpansionCard({
    required this.item,
    required this.coverSize,
    required this.accent,
    required this.expanded,
    required this.onTap,
  });

  final _TvShelfSeasonItem item;
  final double coverSize;
  final Color accent;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final season = item.season;
    final seasonEntry = item.entry;
    return Card(
      elevation: 0,
      color: palette.panel,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: math.max(64, coverSize * 0.42),
                      height: math.max(84, coverSize * 0.58),
                      child: LibraryCoverImage(
                        title: seasonEntry.resolvedTitle,
                        imageUrl: seasonEntry.coverImageUrl,
                        borderRadius: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          seasonEntry.displayTitle ?? seasonEntry.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Season ${season.seasonNumber} · ${season.episodes.length}/${season.episodeCount ?? season.episodes.length} episodes',
                          style: TextStyle(color: palette.textMuted),
                        ),
                        if (season.overview != null &&
                            season.overview!.trim().isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            season.overview!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: palette.textMuted),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    color: accent,
                  ),
                ],
              ),
              if (expanded) ...[
                const SizedBox(height: 12),
                for (final episode in season.episodes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _TvEpisodeRow(episode: episode),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TvEpisodeRow extends StatelessWidget {
  const _TvEpisodeRow({required this.episode});

  final Episode episode;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final code = 'E${episode.episodeNumber.toString().padLeft(2, '0')}';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surfaceSubtle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: palette.divider),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Text(
          code,
          style: TextStyle(
            color: palette.textMuted,
            fontWeight: FontWeight.w800,
          ),
        ),
        title: Text(
          episode.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          [
            if (episode.airDate != null && episode.airDate!.trim().isNotEmpty)
              episode.airDate!,
            if (episode.runtimeMinutes != null) '${episode.runtimeMinutes} min',
          ].join(' · '),
        ),
      ),
    );
  }
}

class _TvShelfSeasonItem {
  const _TvShelfSeasonItem({
    required this.season,
    required this.entry,
  });

  final Season season;
  final LibraryWorkspaceEntry entry;
}

TvSeries _buildSeriesSnapshot(
  LibraryWorkspaceEntry titleEntry,
  List<Season> seasons,
) {
  return TvSeries(
    id: titleEntry.canonicalItemId,
    title: titleEntry.resolvedTitle,
    originalTitle: titleEntry.originalTitle,
    overview: titleEntry.synopsis,
    firstAirDate: titleEntry.releaseDate,
    lastAirDate: null,
    status: titleEntry.collectionStatus,
    network: titleEntry.publisher,
    originalLanguage: titleEntry.language,
    country: titleEntry.country,
    runtimeMinutes: titleEntry.video?.runtimeMinutes,
    seasonCount: seasons.length,
    episodeCount: seasons.fold<int>(
      0,
      (sum, season) => sum + season.episodes.length,
    ),
    posterUrl: titleEntry.coverImageUrl,
    backdropUrl: titleEntry.thumbnailImageUrl,
    seasons: const <TvSeason>[],
  );
}

TvSeason _toTvSeason(String seriesId, Season season) {
  return TvSeason(
    id: season.providerItemId ?? '$seriesId:season:${season.seasonNumber}',
    seriesId: seriesId,
    seasonNumber: season.seasonNumber,
    title: season.title,
    overview: season.overview,
    airDate: _parseDate(season.airDate),
    episodeCount: season.episodeCount,
    posterUrl: season.posterUrl,
    episodes: [
      for (final episode in season.episodes)
        TvEpisode(
          id: episode.providerItemId ??
              '$seriesId:season:${season.seasonNumber}:episode:${episode.episodeNumber}',
          seriesId: seriesId,
          seasonId: season.providerItemId ?? '$seriesId:season:${season.seasonNumber}',
          seasonNumber: season.seasonNumber,
          episodeNumber: episode.episodeNumber,
          title: episode.title,
          overview: episode.overview,
          airDate: _parseDate(episode.airDate),
          runtimeMinutes: episode.runtimeMinutes,
        ),
    ],
  );
}

DateTime? _parseDate(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}
