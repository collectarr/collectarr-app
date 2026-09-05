import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';
import 'package:collectarr_app/features/library/kinds/tv/provider/tv_seasons_provider.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TvShelfSeasonDrilldown extends ConsumerWidget {
  const TvShelfSeasonDrilldown({
    super.key,
    required this.titleItem,
    required this.coverSize,
    required this.accent,
    required this.onBack,
    required this.onRefreshFromCore,
    required this.onOpenTitleDetails,
    this.seasonsOverride,
  });

  final LibraryProjectionRuntime titleItem;
  final double coverSize;
  final Color accent;
  final VoidCallback onBack;
  final Future<void> Function() onRefreshFromCore;
  final VoidCallback onOpenTitleDetails;

  /// Optional typed TV season data used by deterministic widget tests and
  /// callers that already have a TV-owned hierarchy snapshot.
  final List<TvSeason>? seasonsOverride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = appPalette(context);
    final seasons = seasonsOverride;
    if (seasons != null) {
      return _buildWithSeasons(context, seasons);
    }
    final seasonsAsync = ref.watch(
      tvSeasonsBySeriesProvider(titleItem.node.titleItemId),
    );
    return seasonsAsync.when(
      loading: () => _TvShelfDrilldownShell(
        titleItem: titleItem,
        accent: accent,
        onBack: onBack,
        onRefreshFromCore: onRefreshFromCore,
        onOpenTitleDetails: onOpenTitleDetails,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => _TvShelfDrilldownShell(
        titleItem: titleItem,
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

  Widget _buildWithSeasons(BuildContext context, List<TvSeason> seasons) {
    final palette = appPalette(context);
    final projector = const TvWorkspaceProjector();
    final seasonItems = [
      for (final season in seasons)
        _TvShelfSeasonItem(
          season: season,
          item: LibraryProjectionItem(
            source: titleItem.source,
            node: titleItem.node,
            dto: projector.projectTitle(
              source: titleItem.source,
              node:
                  LibraryTitleNodeRef(titleItemId: titleItem.node.titleItemId),
            ),
            customFieldBadges: titleItem.customFieldBadges,
          ),
        ),
    ];
    if (seasonItems.isEmpty) {
      return _TvShelfDrilldownShell(
        titleItem: titleItem,
        accent: accent,
        onBack: onBack,
        onRefreshFromCore: onRefreshFromCore,
        onOpenTitleDetails: onOpenTitleDetails,
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No seasons found for this show.',
            style: TextStyle(color: palette.textMuted),
          ),
        ),
      );
    }
    return _TvShelfDrilldownShell(
      titleItem: titleItem,
      accent: accent,
      onBack: onBack,
      onRefreshFromCore: onRefreshFromCore,
      onOpenTitleDetails: onOpenTitleDetails,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final seasonItem in seasonItems)
              SizedBox(
                width: coverSize,
                child: Column(
                  children: [
                    LibraryCoverImage(
                      title: seasonItem.season.title == null ||
                              seasonItem.season.title!.isEmpty
                          ? 'Season ${seasonItem.season.seasonNumber}'
                          : seasonItem.season.title!,
                      imageUrl: seasonItem.season.coverImageUrl ??
                          titleItem.dto.coverImageUrl,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      seasonItem.season.title == null ||
                              seasonItem.season.title!.isEmpty
                          ? 'Season ${seasonItem.season.seasonNumber}'
                          : seasonItem.season.title!,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    for (final ep in seasonItem.season.episodes) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            'E${_episodeNumber(ep.episodeNumber)}',
                            style: TextStyle(
                              color: palette.accent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              ep.title ??
                                  'Episode ${_episodeNumber(ep.episodeNumber)}',
                              style: TextStyle(
                                color: palette.textSecondary,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TvShelfDrilldownShell extends StatelessWidget {
  const _TvShelfDrilldownShell({
    required this.titleItem,
    required this.accent,
    required this.onBack,
    required this.onRefreshFromCore,
    required this.onOpenTitleDetails,
    required this.body,
  });

  final LibraryProjectionRuntime titleItem;
  final Color accent;
  final VoidCallback onBack;
  final Future<void> Function() onRefreshFromCore;
  final VoidCallback onOpenTitleDetails;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Scaffold(
      backgroundColor: palette.canvas,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: Text(titleItem.dto.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onRefreshFromCore,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: onOpenTitleDetails,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Seasons',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _TvShelfSeasonItem {
  const _TvShelfSeasonItem({
    required this.season,
    required this.item,
  });

  final TvSeason season;
  final LibraryProjectionRuntime item;
}

String _episodeNumber(double? number) {
  if (number == null) return '--';
  final label = number == number.truncateToDouble()
      ? number.toInt().toString()
      : number.toString();
  return label.padLeft(2, '0');
}
