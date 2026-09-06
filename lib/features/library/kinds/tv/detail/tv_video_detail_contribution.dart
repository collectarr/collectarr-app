import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/detail/library_detail_user_links_section.dart';
import 'package:collectarr_app/features/library/detail/library_external_links_section.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/remote/tv_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';
import 'package:collectarr_app/features/library/kinds/tv/hierarchy/tv_upcoming_episodes_section.dart';
import 'package:collectarr_app/features/library/kinds/tv/provider/tv_seasons_provider.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_episode_rating_section.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_progress_section.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_season_tracking_section.dart';
import 'package:collectarr_app/features/library/tracking/session_history_section.dart';
import 'package:collectarr_app/features/library/ui/library_chrome_tokens.dart';
import 'package:collectarr_app/features/library/ui/library_density_scope.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Widget buildTvVideoDetailContribution(
  BuildContext context,
  LibraryDetailPageRequest request,
) {
  return TvVideoDetailContribution(request: request);
}

/// TV owns its provider-backed episodic detail sections and release graph.
final class TvVideoDetailContribution extends ConsumerStatefulWidget {
  const TvVideoDetailContribution({super.key, required this.request});

  final LibraryDetailPageRequest request;

  @override
  ConsumerState<TvVideoDetailContribution> createState() =>
      _TvVideoDetailContributionState();
}

class _TvVideoDetailContributionState
    extends ConsumerState<TvVideoDetailContribution> {
  Future<TvSeries?>? _seriesFuture;
  TvSeries? _seriesSnapshot;

  @override
  void initState() {
    super.initState();
    _seriesFuture = _loadSeries();
  }

  @override
  void didUpdateWidget(covariant TvVideoDetailContribution oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.request.item.source.itemId !=
        widget.request.item.source.itemId) {
      _seriesSnapshot = null;
      _seriesFuture = _loadSeries();
    }
  }

  Future<TvSeries?> _loadSeries() async {
    final api = ref.read(apiClientProvider);
    try {
      final dto = await api
          .getTvSeriesDto(widget.request.item.source.itemId)
          .timeout(const Duration(seconds: 20));
      final series = TvCoreMapper.fromSeriesDto(dto);
      _seriesSnapshot = series;
      return series;
    } on Object {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final seriesRef = CatalogEntityRef(
      kind: request.type.kind.apiValue,
      entityType: CatalogEntityType.work,
      id: request.item.source.itemId,
    );
    final seasonsAsync = ref.watch(tvSeasonsByCatalogRefProvider(seriesRef));
    return FutureBuilder<TvSeries?>(
      future: _seriesFuture,
      builder: (context, snapshot) {
        final series = snapshot.data ?? _seriesSnapshot;
        final watchTargets = _watchHistoryTargets(
          request: request,
          seriesRef: seriesRef,
          seasonsAsync: seasonsAsync,
          series: series,
        );
        final payload = request.item.source.catalogItem?.payload;
        final links = ((payload?['trailer_urls'] as List?)
                ?.whereType<Map<String, dynamic>>()
                .map((entry) =>
                    TrailerLink.fromJson(Map<String, dynamic>.from(entry)))
                .toList()) ??
            const <TrailerLink>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VideoProgressSection(
              seriesRef: seriesRef,
              accent: request.accent,
            ),
            const SizedBox(height: 16),
            VideoSeasonTrackingSection(
              seriesRef: seriesRef,
              kind: request.type.kind.apiValue,
              accent: request.accent,
            ),
            const SizedBox(height: 16),
            TvEpisodeRatingDisplaySection(
              itemId: request.item.source.itemId,
              accent: request.accent,
            ),
            const SizedBox(height: 16),
            LibraryExternalLinksSection(
              title: 'External links',
              links: links,
              accent: request.accent,
            ),
            const SizedBox(height: 16),
            LibraryDetailUserLinksSection(
              itemId: request.item.source.itemId,
              accent: request.accent,
            ),
            const SizedBox(height: 16),
            TvUpcomingEpisodesSection(
              seriesRef: seriesRef,
              accent: request.accent,
            ),
            if (series != null) ...[
              const SizedBox(height: 16),
              _TvReleaseBrowserSection(
                series: series,
                accent: request.accent,
              ),
            ],
            const SizedBox(height: 16),
            WatchHistorySection(
              itemId: request.item.source.itemId,
              accent: request.accent,
              defaultTargetRef: seriesRef,
              targetOptions: watchTargets,
            ),
          ],
        );
      },
    );
  }
}

List<WatchHistoryTargetOption> _watchHistoryTargets({
  required LibraryDetailPageRequest request,
  required CatalogEntityRef seriesRef,
  required AsyncValue<List<TvSeason>> seasonsAsync,
  required TvSeries? series,
}) {
  final releases = series?.releases ?? const <TvRelease>[];
  return [
    WatchHistoryTargetOption(
      ref: seriesRef,
      label: 'Series',
      subtitle: request.item.source.catalogItem?.title ?? '',
    ),
    ...seasonsAsync.maybeWhen(
      data: (seasons) => [
        for (final season in seasons) ...[
          WatchHistoryTargetOption(
            ref: CatalogEntityRef(
              kind: seriesRef.kind,
              entityType: CatalogEntityType.season,
              id: '${seriesRef.id}:season:${season.seasonNumber}',
            ),
            label: season.title ?? 'Season ${season.seasonNumber ?? 0}',
            subtitle: 'Season ${season.seasonNumber ?? 0}',
            seasonNumber: season.seasonNumber ?? 0,
          ),
          for (final episode in season.episodes)
            WatchHistoryTargetOption(
              ref: CatalogEntityRef(
                kind: seriesRef.kind,
                entityType: CatalogEntityType.episode,
                id: '${seriesRef.id}:season:${season.seasonNumber}:episode:${episode.episodeNumber}',
              ),
              label: episode.title ?? 'Episode ${episode.episodeNumber ?? 0}',
              subtitle:
                  'Season ${season.seasonNumber} • Episode ${episode.episodeNumber}',
              seasonNumber: season.seasonNumber,
              episodeNumber: episode.episodeNumber?.toInt() ?? 0,
            ),
        ],
      ],
      orElse: () => const <WatchHistoryTargetOption>[],
    ),
    for (final release in releases)
      WatchHistoryTargetOption(
        ref: CatalogEntityRef(
          kind: seriesRef.kind,
          entityType: CatalogEntityType.release,
          id: release.id,
        ),
        label: release.title,
        subtitle: release.format,
      ),
  ];
}

class _TvReleaseBrowserSection extends StatefulWidget {
  const _TvReleaseBrowserSection({
    required this.series,
    required this.accent,
  });

  final TvSeries series;
  final Color accent;

  @override
  State<_TvReleaseBrowserSection> createState() =>
      _TvReleaseBrowserSectionState();
}

class _TvReleaseBrowserSectionState extends State<_TvReleaseBrowserSection> {
  String? _selectedReleaseId;
  final Map<String, String?> _selectedMediaIdByRelease = <String, String?>{};

  @override
  void initState() {
    super.initState();
    _selectedReleaseId =
        widget.series.releases.isEmpty ? null : widget.series.releases.first.id;
  }

  @override
  void didUpdateWidget(covariant _TvReleaseBrowserSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.series.id != widget.series.id) {
      _selectedReleaseId = widget.series.releases.isEmpty
          ? null
          : widget.series.releases.first.id;
      _selectedMediaIdByRelease.clear();
    } else if (_selectedReleaseId != null &&
        widget.series.releases
            .every((release) => release.id != _selectedReleaseId)) {
      _selectedReleaseId = widget.series.releases.isEmpty
          ? null
          : widget.series.releases.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final releases = widget.series.releases;
    TvRelease? selectedRelease;
    for (final release in releases) {
      if (release.id == _selectedReleaseId) {
        selectedRelease = release;
        break;
      }
    }
    selectedRelease ??= releases.isEmpty ? null : releases.first;
    final palette = appPalette(context);
    return LibraryDetailSection(
      title: 'Releases / discs',
      accentColor: widget.accent,
      children: [
        if (releases.isEmpty)
          Text(
            'No TV releases were returned for this series yet.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: palette.textMuted,
                ),
          )
        else ...[
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 230,
              mainAxisExtent: 172,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: releases.length,
            itemBuilder: (context, index) {
              final release = releases[index];
              return _TvReleaseTile(
                release: release,
                accent: widget.accent,
                selected: release.id == _selectedReleaseId,
                onTap: () => setState(() => _selectedReleaseId = release.id),
              );
            },
          ),
          if (selectedRelease != null) ...[
            const SizedBox(height: 12),
            Builder(
              builder: (context) {
                final release = selectedRelease!;
                return _TvReleaseDetailsPanel(
                  series: widget.series,
                  release: release,
                  accent: widget.accent,
                  selectedMediaId: _selectedMediaIdByRelease[release.id] ??
                      release.media.firstOrNull?.id,
                  onSelectMedia: (mediaId) => setState(
                    () => _selectedMediaIdByRelease[release.id] = mediaId,
                  ),
                );
              },
            ),
          ],
        ],
      ],
    );
  }
}

class _TvReleaseTile extends StatelessWidget {
  const _TvReleaseTile({
    required this.release,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final TvRelease release;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final density = LibraryDensityScope.maybeOf(context)?.density ??
        LibraryDensity.comfortable;
    return Material(
      color: selected ? accent.withValues(alpha: 0.16) : palette.panel,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  selected ? accent.withValues(alpha: 0.85) : palette.divider,
            ),
          ),
          padding: density.metrics.panelInsets,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LibraryCoverImage(
                    title: release.title,
                    imageUrl: release.coverImageUrl,
                    borderRadius: 12,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                release.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                [
                  if (release.format?.trim().isNotEmpty == true)
                    release.format!,
                  '${release.media.length} media',
                  '${release.episodeMappings.length} maps',
                ].join(' • '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.textMuted,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TvReleaseDetailsPanel extends StatelessWidget {
  const _TvReleaseDetailsPanel({
    required this.series,
    required this.release,
    required this.accent,
    required this.selectedMediaId,
    required this.onSelectMedia,
  });

  final TvSeries series;
  final TvRelease release;
  final Color accent;
  final String? selectedMediaId;
  final ValueChanged<String> onSelectMedia;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final density = LibraryDensityScope.maybeOf(context)?.density ??
        LibraryDensity.comfortable;
    final selectedMedia = release.media.isEmpty
        ? null
        : release.media.firstWhere(
            (media) => media.id == selectedMediaId,
            orElse: () => release.media.first,
          );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: density.metrics.panelInsets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              release.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              [
                if (release.releaseDate != null)
                  release.releaseDate!
                      .toLocal()
                      .toIso8601String()
                      .split('T')
                      .first,
                if (release.regionCode?.trim().isNotEmpty == true)
                  release.regionCode!,
                if (release.languageAudio.isNotEmpty)
                  release.languageAudio.join(', '),
              ].join(' • '),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.textMuted,
                  ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final media in release.media)
                  ChoiceChip(
                    label: Text(
                      media.title ??
                          media.mediaType ??
                          'Disc ${media.mediaNumber ?? 1}',
                    ),
                    selected: selectedMedia?.id == media.id,
                    selectedColor: accent.withValues(alpha: 0.24),
                    onSelected: (_) => onSelectMedia(media.id),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (selectedMedia != null) ...[
              Text(
                selectedMedia.title ??
                    selectedMedia.mediaType ??
                    'Disc ${selectedMedia.mediaNumber ?? 1}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                [
                  if (selectedMedia.mediaType?.trim().isNotEmpty == true)
                    selectedMedia.mediaType!,
                  if (selectedMedia.mediaNumber != null)
                    'Disc ${selectedMedia.mediaNumber}',
                  '${selectedMedia.episodes.length} episodes',
                ].join(' • '),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.textMuted,
                    ),
              ),
              const SizedBox(height: 8),
              if (selectedMedia.episodes.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final episode in selectedMedia.episodes)
                      Chip(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        label: Text(_episodeLabel(series, episode)),
                      ),
                  ],
                ),
              const SizedBox(height: 12),
              if (release.episodeMappings.isNotEmpty)
                _TvEpisodeMapList(
                  series: series,
                  release: release,
                  media: selectedMedia,
                  accent: accent,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TvEpisodeMapList extends StatelessWidget {
  const _TvEpisodeMapList({
    required this.series,
    required this.release,
    required this.media,
    required this.accent,
  });

  final TvSeries series;
  final TvRelease release;
  final TvReleaseMedia media;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final maps = release.episodeMappings
        .where((mapping) => mapping.mediaId == media.id)
        .toList(growable: false);
    if (maps.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Episode map',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: palette.textPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final mapping in maps)
              Chip(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                label: Text(
                  [
                    if (mapping.discNumber != null)
                      'Disc ${mapping.discNumber}',
                    if (mapping.sequenceNumber != null)
                      'Seq ${mapping.sequenceNumber}',
                    _episodeTitleForId(series, mapping.episodeId),
                  ].where((value) => value.trim().isNotEmpty).join(' • '),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

String _episodeLabel(TvSeries series, TvEpisode episode) {
  final title = _episodeTitleForId(series, episode.id);
  final season = episode.seasonNumber ?? 0;
  final number = episode.episodeNumber?.toInt() ?? 0;
  return title.isEmpty ? 'S$season E$number' : 'S$season E$number • $title';
}

String _episodeTitleForId(TvSeries series, String episodeId) {
  for (final season in series.seasons) {
    for (final episode in season.episodes) {
      if (episode.id == episodeId) {
        return episode.title?.isEmpty ?? true
            ? 'Episode ${episode.episodeNumber?.toInt() ?? 0}'
            : episode.title!;
      }
    }
  }
  return '';
}
