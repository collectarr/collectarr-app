import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/tracking_unit_summary.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/library/kinds/tv/provider/tv_seasons_provider.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_episode_identity.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_progress_episode_row.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_progress_presenter.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_progress_summary.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_unit.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_tracking.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_mutation_provider.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_season_summary_card.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VideoSeasonTrackingSection extends ConsumerStatefulWidget {
  const VideoSeasonTrackingSection({
    super.key,
    required this.seriesRef,
    required this.kind,
    required this.accent,
  });

  final CatalogEntityRef seriesRef;
  final String kind;
  final Color accent;

  @override
  ConsumerState<VideoSeasonTrackingSection> createState() =>
      _VideoSeasonTrackingSectionState();
}

class _VideoSeasonTrackingSectionState
    extends ConsumerState<VideoSeasonTrackingSection> {
  int? _selectedSeasonNumber;
  final Set<String> _pendingEpisodeKeys = <String>{};
  bool _seasonMutationInFlight = false;
  bool _showCustomEpisodes = false;

  LibraryEntryRef get entryRef => LibraryEntryRef(
        kind: widget.seriesRef.kind,
        id: LibraryEntryId(widget.seriesRef.rootScope.id),
      );

  @override
  Widget build(BuildContext context) {
    final seasonsAsync = ref.watch(
      tvSeasonsByCatalogRefProvider(widget.seriesRef),
    );
    final trackedUnits =
        ref.watch(trackingUnitsByLibraryEntryRefProvider(entryRef));
    final watchSessions =
        ref.watch(watchSessionsByLibraryEntryRefProvider(entryRef));
    final customEpisodesAsync =
        ref.watch(tvCustomEpisodesByLibraryEntryRefProvider(entryRef));
    return seasonsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (seasons) {
        if (seasons.isEmpty) {
          return const SizedBox.shrink();
        }
        final selectedSeasonNumber =
            _resolvedSeasonNumber(seasons, trackedUnits: trackedUnits);
        final selectedSeason = _seasonForNumber(
              seasons,
              selectedSeasonNumber,
            ) ??
            seasons.first;
        final watchedEpisodeKeys = trackedUnits
            .whereType<TvTrackingUnit>()
            .map(_episodeKeyForUnit)
            .toSet();
        final watchedInSelectedSeason = selectedSeason.episodes
            .where(
              (episode) => watchedEpisodeKeys.contains(
                _episodeKey(
                  selectedSeason.seasonNumber,
                  episode.episodeNumber ?? episode.position,
                ),
              ),
            )
            .length;
        final allEpisodesWatched = selectedSeason.episodes.isNotEmpty &&
            watchedInSelectedSeason == selectedSeason.episodes.length;
        final seasonSummary = const VideoProgressPresenter().seasonSummary(
          season: selectedSeason,
          trackedUnits: trackedUnits,
          watchSessions: watchSessions,
        );
        return DecoratedBox(
          decoration: BoxDecoration(
            color: appPalette(context).surfaceSubtle,
            border: Border.all(color: widget.accent.withValues(alpha: 0.33)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seasons & episodes',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: widget.accent,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$watchedInSelectedSeason/${selectedSeason.episodes.length} watched in ${selectedSeason.title}',
                  style: TextStyle(
                    color: appPalette(context).textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                VideoSeasonSummaryCard(
                  summary: seasonSummary,
                  accent: widget.accent,
                  onMarkWatched: _seasonMutationInFlight ||
                          selectedSeason.episodes.isEmpty ||
                          allEpisodesWatched
                      ? null
                      : () => _setSeasonWatched(
                            selectedSeason,
                            completed: true,
                          ),
                  onClear:
                      _seasonMutationInFlight || watchedInSelectedSeason == 0
                          ? null
                          : () => _setSeasonWatched(
                                selectedSeason,
                                completed: false,
                              ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final season in seasons)
                      ChoiceChip(
                        label:
                            Text(_seasonChipLabel(season, watchedEpisodeKeys)),
                        selected:
                            season.seasonNumber == selectedSeason.seasonNumber,
                        selectedColor: widget.accent.withValues(alpha: 0.24),
                        onSelected: (_) {
                          setState(() {
                            _selectedSeasonNumber = season.seasonNumber;
                          });
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 12),
                _CustomEpisodesPanel(
                  libraryEntryRef: entryRef,
                  catalogSeason: selectedSeason,
                  showCustomEpisodes:
                      selectedSeason.episodes.isEmpty || _showCustomEpisodes,
                  onShowCustomEpisodesChanged: (value) {
                    if (_showCustomEpisodes == value) {
                      return;
                    }
                    setState(() {
                      _showCustomEpisodes = value;
                    });
                  },
                  seasonNumber: selectedSeason.seasonNumber,
                  accent: widget.accent,
                  customEpisodesAsync: customEpisodesAsync,
                  watchedEpisodeKeys: watchedEpisodeKeys,
                  watchSessions: watchSessions,
                  pendingEpisodeKeys: _pendingEpisodeKeys,
                  onToggleEpisode: (epNum) => _toggleEpisode(
                    selectedSeason.seasonNumber,
                    epNum,
                    watchedEpisodeKeys: watchedEpisodeKeys,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _resolvedSeasonNumber(
    List<TvSeasonMetadata> seasons, {
    required List<TrackingUnitSummary> trackedUnits,
  }) {
    final currentSelection = _selectedSeasonNumber;
    if (currentSelection != null) {
      for (final season in seasons) {
        if (season.seasonNumber == currentSelection) {
          return currentSelection;
        }
      }
    }
    final trackedEpisodes =
        trackedUnits.whereType<TvTrackingUnit>().toList(growable: false)
          ..sort((a, b) {
            final seasonCompare =
                (b.seasonNumber ?? 0).compareTo(a.seasonNumber ?? 0);
            if (seasonCompare != 0) {
              return seasonCompare;
            }
            return (b.episodeNumber ?? 0).compareTo(a.episodeNumber ?? 0);
          });
    for (final trackedEpisode in trackedEpisodes) {
      final seasonNumber = trackedEpisode.seasonNumber;
      if (seasonNumber == null) {
        continue;
      }
      for (final season in seasons) {
        if (season.seasonNumber == seasonNumber) {
          return seasonNumber;
        }
      }
    }
    return seasons.first.seasonNumber;
  }

  TvSeasonMetadata? _seasonForNumber(
    List<TvSeasonMetadata> seasons,
    int seasonNumber,
  ) {
    for (final season in seasons) {
      if (season.seasonNumber == seasonNumber) {
        return season;
      }
    }
    return null;
  }

  String _seasonChipLabel(
    TvSeasonMetadata season,
    Set<String> watchedEpisodeKeys,
  ) {
    final watchedCount = season.episodes
        .where(
          (episode) => watchedEpisodeKeys.contains(
            _episodeKey(
              season.seasonNumber,
              episode.episodeNumber ?? episode.position,
            ),
          ),
        )
        .length;
    if (season.episodes.isEmpty) {
      return season.title ?? 'Season ${season.seasonNumber}';
    }
    return '${season.title} ($watchedCount/${season.episodes.length})';
  }

  Future<void> _toggleEpisode(
    int seasonNumber,
    int episodeNumber, {
    required Set<String> watchedEpisodeKeys,
  }) async {
    final key = _episodeKey(seasonNumber, episodeNumber);
    if (_pendingEpisodeKeys.contains(key)) {
      return;
    }
    setState(() {
      _pendingEpisodeKeys.add(key);
    });
    try {
      await ref.read(tvTrackingUnitMutationsProvider).setEpisodeCompleted(
            entryRef,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            completed: !watchedEpisodeKeys.contains(key),
          );
    } finally {
      if (mounted) {
        setState(() {
          _pendingEpisodeKeys.remove(key);
        });
      }
    }
  }

  Future<void> _setSeasonWatched(
    TvSeasonMetadata season, {
    required bool completed,
  }) async {
    if (_seasonMutationInFlight) {
      return;
    }
    setState(() {
      _seasonMutationInFlight = true;
    });
    try {
      await ref
          .read(tvTrackingUnitMutationsProvider)
          .setSeasonEpisodesCompleted(
            entryRef,
            seasonNumber: season.seasonNumber,
            episodeNumbers: season.episodes.map(
              (episode) => episode.episodeNumber ?? episode.position,
            ),
            completed: completed,
          );
    } finally {
      if (mounted) {
        setState(() {
          _seasonMutationInFlight = false;
        });
      }
    }
  }

  String _episodeKey(int seasonNumber, int episodeNumber) {
    return '$seasonNumber:$episodeNumber';
  }

  String _episodeKeyForUnit(TvTrackingUnit unit) {
    return _episodeKey(unit.seasonNumber ?? 0, unit.episodeNumber ?? 0);
  }
}

/// Panel for displaying and managing custom episodes within a season.
class _CustomEpisodesPanel extends ConsumerWidget {
  const _CustomEpisodesPanel({
    required this.libraryEntryRef,
    required this.catalogSeason,
    required this.showCustomEpisodes,
    required this.onShowCustomEpisodesChanged,
    required this.seasonNumber,
    required this.accent,
    required this.customEpisodesAsync,
    required this.watchedEpisodeKeys,
    required this.watchSessions,
    required this.pendingEpisodeKeys,
    required this.onToggleEpisode,
  });

  final LibraryEntryRef libraryEntryRef;
  final TvSeasonMetadata catalogSeason;
  final bool showCustomEpisodes;
  final ValueChanged<bool> onShowCustomEpisodesChanged;
  final int seasonNumber;
  final Color accent;
  final AsyncValue<Map<int, List<TvCustomEpisode>>> customEpisodesAsync;
  final Set<String> watchedEpisodeKeys;
  final List<WatchSession> watchSessions;
  final Set<String> pendingEpisodeKeys;
  final void Function(int episodeNumber) onToggleEpisode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = appPalette(context);
    final customEpisodes = customEpisodesAsync.maybeWhen(
      data: (grouped) => grouped[seasonNumber] ?? const <TvCustomEpisode>[],
      orElse: () => const <TvCustomEpisode>[],
    );
    final catalogEpisodes = catalogSeason.episodes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_note, size: 16, color: palette.textMuted),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Custom episodes',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: palette.textMuted,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (catalogEpisodes.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => _importCatalogSeason(context, ref),
                    icon: const Icon(Icons.file_download_outlined, size: 16),
                    label: const Text('Import catalog season'),
                  ),
                if (catalogEpisodes.isNotEmpty)
                  TextButton.icon(
                    onPressed: () =>
                        onShowCustomEpisodesChanged(!showCustomEpisodes),
                    icon: Icon(
                      showCustomEpisodes
                          ? Icons.cloud_outlined
                          : Icons.edit_note,
                      size: 16,
                    ),
                    label: Text(
                      showCustomEpisodes
                          ? 'Show catalog episodes'
                          : 'Show custom episodes',
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  color: accent,
                  tooltip: 'Add custom episode',
                  onPressed: () => _showCustomEpisodeDialog(
                    context,
                    ref,
                    seasonNumber: seasonNumber,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (!showCustomEpisodes && catalogEpisodes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: TextButton.icon(
              onPressed: () => _importCatalogSeason(context, ref),
              icon: const Icon(Icons.layers_outlined, size: 16),
              label: const Text('Replace catalog season with custom list'),
            ),
          ),
        if (showCustomEpisodes) ...[
          if (customEpisodes.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: Text(
                'No custom episodes — tap + to add one.',
                style: TextStyle(color: palette.textMuted, fontSize: 12),
              ),
            )
          else
            for (final ep in _sortedCustomEpisodes(customEpisodes))
              _CustomEpisodeTile(
                accent: accent,
                episode: ep,
                watched: watchedEpisodeKeys
                    .contains('$seasonNumber:${ep.episodeNumber}'),
                watchCount: watchSessions
                    .whereType<TvWatchSession>()
                    .where(
                      (s) =>
                          s.seasonNumber == seasonNumber &&
                          s.episodeNumber == ep.episodeNumber,
                    )
                    .length,
                busy: pendingEpisodeKeys
                    .contains('$seasonNumber:${ep.episodeNumber}'),
                onWatchToggle: () => onToggleEpisode(ep.episodeNumber),
                onEdit: () => _showCustomEpisodeDialog(
                  context,
                  ref,
                  seasonNumber: seasonNumber,
                  existing: ep,
                ),
                onMoveUp: ep.episodeNumber <= 1
                    ? null
                    : () => _renumberCustomEpisode(
                          context,
                          ref,
                          ep,
                          ep.episodeNumber - 1,
                        ),
                onMoveDown: () => _renumberCustomEpisode(
                  context,
                  ref,
                  ep,
                  ep.episodeNumber + 1,
                ),
                onDelete: () async {
                  await ref
                      .read(tvCustomEpisodeMutationsProvider)
                      .removeCustomEpisode(ep);
                },
              ),
        ] else ...[
          if (catalogEpisodes.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: Text(
                'No catalog episodes found for this season.',
                style: TextStyle(color: palette.textMuted, fontSize: 12),
              ),
            )
          else ...[
            const SizedBox(height: 4),
            for (final episode in catalogEpisodes)
              _CatalogEpisodeTile(
                seasonNumber: seasonNumber,
                accent: accent,
                episode: episode,
                watched: watchedEpisodeKeys.contains(
                    '$seasonNumber:${episode.episodeNumber ?? episode.position}'),
                watchCount: watchSessions
                    .whereType<TvWatchSession>()
                    .where(
                      (s) =>
                          s.seasonNumber == seasonNumber &&
                          s.episodeNumber ==
                              (episode.episodeNumber ?? episode.position),
                    )
                    .length,
                busy: pendingEpisodeKeys.contains(
                    '$seasonNumber:${episode.episodeNumber ?? episode.position}'),
                onWatchToggle: () =>
                    onToggleEpisode(episode.episodeNumber ?? episode.position),
                onDuplicate: () => _showCustomEpisodeDialog(
                  context,
                  ref,
                  seasonNumber: seasonNumber,
                  catalogEpisode: episode,
                ),
              ),
          ],
        ],
      ],
    );
  }

  Future<void> _importCatalogSeason(
    BuildContext context,
    WidgetRef ref,
  ) async {
    for (final episode in catalogSeason.episodes) {
      await ref.read(tvCustomEpisodeMutationsProvider).upsertCustomEpisode(
            libraryEntryRef: libraryEntryRef,
            seasonNumber: catalogSeason.seasonNumber,
            episodeNumber: episode.episodeNumber ?? episode.position,
            title: episode.episodeTitle ?? episode.title ?? 'Untitled',
            description: episode.description,
            airDate: episode.airDate?.asDateTime,
            runtimeMinutes: episode.runtimeMinutes,
          );
    }
    onShowCustomEpisodesChanged(true);
  }

  Future<void> _showCustomEpisodeDialog(
    BuildContext context,
    WidgetRef ref, {
    required int seasonNumber,
    TvCustomEpisode? existing,
    TvEpisodeMetadata? catalogEpisode,
  }) async {
    final result = await showDialog<_CustomEpisodeFormResult>(
      context: context,
      builder: (_) => _CustomEpisodeFormDialog(
        accent: accent,
        title: existing == null ? 'Add custom episode' : 'Edit custom episode',
        confirmLabel: existing == null ? 'Add' : 'Save',
        initialEpisodeNumber: existing?.episodeNumber ??
            catalogEpisode?.episodeNumber ??
            catalogEpisode?.position ??
            1,
        initialTitle: existing?.title ??
            catalogEpisode?.episodeTitle ??
            catalogEpisode?.title ??
            '',
        initialOverview:
            existing?.description ?? catalogEpisode?.description ?? '',
        initialAirDate: _formatTvAirDate(existing?.airDate) ??
            _formatTvAirDate(catalogEpisode?.airDate?.asDateTime) ??
            '',
        initialRuntimeMinutes:
            existing?.runtimeMinutes ?? catalogEpisode?.runtimeMinutes,
        initialStillImageUrl: existing?.stillImageUrl ?? '',
        initialLocalImagePath: existing?.localImagePath ?? '',
        initialThumbnailImageUrl: existing?.thumbnailImageUrl ?? '',
      ),
    );
    if (result == null || !context.mounted) return;
    await ref.read(tvCustomEpisodeMutationsProvider).upsertCustomEpisode(
          id: existing?.id.value,
          libraryEntryRef: libraryEntryRef,
          seasonNumber: seasonNumber,
          episodeNumber: result.episodeNumber,
          title: result.title,
          description: result.overview,
          airDate: _parseDate(result.airDate),
          runtimeMinutes: result.runtimeMinutes,
          stillImageUrl: result.stillImageUrl,
          localImagePath: result.localImagePath,
          thumbnailImageUrl: result.thumbnailImageUrl,
        );
  }

  Future<void> _renumberCustomEpisode(
    BuildContext context,
    WidgetRef ref,
    TvCustomEpisode episode,
    int newEpisodeNumber,
  ) async {
    await ref.read(tvCustomEpisodeMutationsProvider).upsertCustomEpisode(
          id: episode.id.value,
          libraryEntryRef: libraryEntryRef,
          seasonNumber: episode.seasonNumber,
          episodeNumber: newEpisodeNumber < 1 ? 1 : newEpisodeNumber,
          title: episode.title,
          description: episode.description,
          airDate: episode.airDate,
          runtimeMinutes: episode.runtimeMinutes,
          stillImageUrl: episode.stillImageUrl,
          localImagePath: episode.localImagePath,
          thumbnailImageUrl: episode.thumbnailImageUrl,
        );
  }

  List<TvCustomEpisode> _sortedCustomEpisodes(List<TvCustomEpisode> episodes) {
    final sorted = [...episodes];
    sorted.sort((a, b) => a.episodeNumber.compareTo(b.episodeNumber));
    return sorted;
  }
}

class _CatalogEpisodeTile extends StatelessWidget {
  const _CatalogEpisodeTile({
    required this.accent,
    required this.seasonNumber,
    required this.episode,
    required this.watched,
    required this.watchCount,
    required this.busy,
    required this.onWatchToggle,
    required this.onDuplicate,
  });

  final Color accent;
  final int seasonNumber;
  final TvEpisodeMetadata episode;
  final bool watched;
  final int watchCount;
  final bool busy;
  final VoidCallback onWatchToggle;
  final VoidCallback onDuplicate;

  @override
  Widget build(BuildContext context) {
    return VideoEpisodeRow(
      episode: VideoEpisodeProgressSummary(
        episode: VideoEpisodeIdentity(
          seasonNumber: seasonNumber,
          episodeNumber: episode.episodeNumber ?? episode.position,
          title: episode.episodeTitle ?? episode.title,
          airDate: episode.airDate?.asDateTime,
          runtimeMinutes: episode.runtimeMinutes,
        ),
        watchedCount: watchCount,
        isWatched: watched,
      ),
      accent: accent,
      watched: watched,
      watchCount: watchCount,
      busy: busy,
      onToggleWatched: onWatchToggle,
      onDuplicate: onDuplicate,
    );
  }
}

class _CustomEpisodeTile extends StatelessWidget {
  const _CustomEpisodeTile({
    required this.accent,
    required this.episode,
    required this.watched,
    required this.watchCount,
    required this.busy,
    required this.onWatchToggle,
    required this.onEdit,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onDelete,
  });

  final Color accent;
  final TvCustomEpisode episode;
  final bool watched;
  final int watchCount;
  final bool busy;
  final VoidCallback onWatchToggle;
  final VoidCallback onEdit;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return VideoEpisodeRow(
      episode: VideoEpisodeProgressSummary(
        episode: VideoEpisodeIdentity(
          seasonNumber: episode.seasonNumber,
          episodeNumber: episode.episodeNumber,
          title: episode.title,
          airDate: episode.airDate,
          runtimeMinutes: episode.runtimeMinutes,
        ),
        watchedCount: watchCount,
        isWatched: watched,
      ),
      accent: accent,
      watched: watched,
      watchCount: watchCount,
      busy: busy,
      onToggleWatched: onWatchToggle,
      onEdit: onEdit,
      extraActions: [
        IconButton(
          icon: const Icon(Icons.arrow_upward, size: 18),
          color: appPalette(context).textMuted,
          tooltip: 'Move up',
          onPressed: onMoveUp,
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_downward, size: 18),
          color: appPalette(context).textMuted,
          tooltip: 'Move down',
          onPressed: onMoveDown,
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 18),
          color: appPalette(context).textMuted,
          tooltip: 'Delete custom episode',
          onPressed: onDelete,
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
        ),
      ],
    );
  }
}

class _CustomEpisodeFormResult {
  const _CustomEpisodeFormResult({
    required this.episodeNumber,
    required this.title,
    this.overview,
    this.airDate,
    this.runtimeMinutes,
    this.stillImageUrl,
    this.localImagePath,
    this.thumbnailImageUrl,
  });

  final int episodeNumber;
  final String title;
  final String? overview;
  final String? airDate;
  final int? runtimeMinutes;
  final String? stillImageUrl;
  final String? localImagePath;
  final String? thumbnailImageUrl;
}

class _CustomEpisodeFormDialog extends StatefulWidget {
  const _CustomEpisodeFormDialog({
    required this.accent,
    required this.title,
    required this.confirmLabel,
    required this.initialEpisodeNumber,
    required this.initialTitle,
    required this.initialOverview,
    required this.initialAirDate,
    required this.initialRuntimeMinutes,
    required this.initialStillImageUrl,
    required this.initialLocalImagePath,
    required this.initialThumbnailImageUrl,
  });

  final Color accent;
  final String title;
  final String confirmLabel;
  final int initialEpisodeNumber;
  final String initialTitle;
  final String? initialOverview;
  final String? initialAirDate;
  final int? initialRuntimeMinutes;
  final String? initialStillImageUrl;
  final String? initialLocalImagePath;
  final String? initialThumbnailImageUrl;

  @override
  State<_CustomEpisodeFormDialog> createState() =>
      _CustomEpisodeFormDialogState();
}

class _CustomEpisodeFormDialogState extends State<_CustomEpisodeFormDialog> {
  late final TextEditingController _episodeNumberController;
  late final TextEditingController _titleController;
  late final TextEditingController _overviewController;
  late final TextEditingController _airDateController;
  late final TextEditingController _runtimeController;
  late final TextEditingController _stillImageUrlController;
  late final TextEditingController _localImagePathController;
  late final TextEditingController _thumbnailImageUrlController;

  bool get _isValid =>
      _titleController.text.trim().isNotEmpty &&
      (int.tryParse(_episodeNumberController.text) ?? 0) > 0;

  @override
  void initState() {
    super.initState();
    _episodeNumberController = TextEditingController(
      text: widget.initialEpisodeNumber.toString(),
    );
    _titleController = TextEditingController(text: widget.initialTitle);
    _overviewController =
        TextEditingController(text: widget.initialOverview ?? '');
    _airDateController =
        TextEditingController(text: widget.initialAirDate ?? '');
    _runtimeController = TextEditingController(
      text: widget.initialRuntimeMinutes?.toString() ?? '',
    );
    _stillImageUrlController =
        TextEditingController(text: widget.initialStillImageUrl ?? '');
    _localImagePathController =
        TextEditingController(text: widget.initialLocalImagePath ?? '');
    _thumbnailImageUrlController =
        TextEditingController(text: widget.initialThumbnailImageUrl ?? '');
  }

  @override
  void dispose() {
    _episodeNumberController.dispose();
    _titleController.dispose();
    _overviewController.dispose();
    _airDateController.dispose();
    _runtimeController.dispose();
    _stillImageUrlController.dispose();
    _localImagePathController.dispose();
    _thumbnailImageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AccentAlertDialog(
      titlePadding: EdgeInsets.zero,
      title: AccentDialogHeader(
        title: widget.title,
        icon: Icons.playlist_add,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _episodeNumberController,
              decoration: const InputDecoration(labelText: 'Episode number'),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _overviewController,
              decoration:
                  const InputDecoration(labelText: 'Overview (optional)'),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            LibraryDateFieldButton(
              label: 'Air date (optional)',
              value: DateTime.tryParse(_airDateController.text.trim()),
              onChanged: (value) => setState(() {
                _airDateController.text =
                    value == null ? '' : formatDate(value);
              }),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _runtimeController,
              decoration: const InputDecoration(
                labelText: 'Runtime minutes (optional)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _stillImageUrlController,
              decoration: const InputDecoration(
                  labelText: 'Still image URL (optional)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _thumbnailImageUrlController,
              decoration: const InputDecoration(
                labelText: 'Thumbnail image URL (optional)',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _localImagePathController,
              decoration: const InputDecoration(
                labelText: 'Local image path (optional)',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isValid
              ? () => Navigator.pop(
                    context,
                    _CustomEpisodeFormResult(
                      episodeNumber:
                          int.parse(_episodeNumberController.text.trim()),
                      title: _titleController.text.trim(),
                      overview: _overviewController.text.trim().isEmpty
                          ? null
                          : _overviewController.text.trim(),
                      airDate: _airDateController.text.trim().isEmpty
                          ? null
                          : _airDateController.text.trim(),
                      runtimeMinutes:
                          int.tryParse(_runtimeController.text.trim()),
                      stillImageUrl:
                          _stillImageUrlController.text.trim().isEmpty
                              ? null
                              : _stillImageUrlController.text.trim(),
                      localImagePath:
                          _localImagePathController.text.trim().isEmpty
                              ? null
                              : _localImagePathController.text.trim(),
                      thumbnailImageUrl:
                          _thumbnailImageUrlController.text.trim().isEmpty
                              ? null
                              : _thumbnailImageUrlController.text.trim(),
                    ),
                  )
              : null,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

DateTime? _parseDate(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return null;
  }
  return DateTime.tryParse(raw);
}

String? _formatTvAirDate(DateTime? value) {
  return value?.toIso8601String().split('T').first;
}
