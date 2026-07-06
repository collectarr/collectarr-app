import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/custom_episode.dart';
import 'package:collectarr_app/core/models/season.dart';
import 'package:collectarr_app/core/models/tracking_unit.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/providers/seasons_provider.dart';
import 'package:collectarr_app/features/library/kinds/video/video_episode_identity.dart';
import 'package:collectarr_app/features/library/kinds/video/video_episode_row.dart';
import 'package:collectarr_app/features/library/kinds/video/video_progress_presenter.dart';
import 'package:collectarr_app/features/library/kinds/video/video_progress_summary.dart';
import 'package:collectarr_app/features/library/kinds/video/video_season_summary_card.dart';
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

  @override
  Widget build(BuildContext context) {
    final seasonsAsync = ref.watch(
      seasonsByCatalogRefProvider(widget.seriesRef),
    );
    final trackedUnits =
        ref.watch(trackingUnitsByCatalogRefProvider(widget.seriesRef));
    final watchSessions =
        ref.watch(watchSessionsByCatalogRefProvider(widget.seriesRef));
    final customEpisodesAsync =
        ref.watch(customEpisodesByCatalogRefProvider(widget.seriesRef));
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
            .where((unit) => unit.unitType == TrackingUnitType.episode)
            .map(_episodeKeyForUnit)
            .toSet();
        final watchedInSelectedSeason = selectedSeason.episodes
            .where(
              (episode) => watchedEpisodeKeys.contains(
                _episodeKey(
                  selectedSeason.seasonNumber,
                  episode.episodeNumber,
                ),
              ),
            )
            .length;
        final allEpisodesWatched =
            selectedSeason.episodes.isNotEmpty &&
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
                  onClear: _seasonMutationInFlight ||
                          watchedInSelectedSeason == 0
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
                        label: Text(_seasonChipLabel(season, watchedEpisodeKeys)),
                        selected: season.seasonNumber == selectedSeason.seasonNumber,
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
                  catalogRef: widget.seriesRef,
                  providerSeason: selectedSeason,
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
                    Episode(
                      episodeNumber: epNum,
                      title: '',
                    ),
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
    List<Season> seasons, {
    required List<TrackingUnit> trackedUnits,
  }) {
    final currentSelection = _selectedSeasonNumber;
    if (currentSelection != null) {
      for (final season in seasons) {
        if (season.seasonNumber == currentSelection) {
          return currentSelection;
        }
      }
    }
    final trackedEpisodes = trackedUnits
        .where((unit) => unit.unitType == TrackingUnitType.episode)
        .toList(growable: false)
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

  Season? _seasonForNumber(List<Season> seasons, int seasonNumber) {
    for (final season in seasons) {
      if (season.seasonNumber == seasonNumber) {
        return season;
      }
    }
    return null;
  }

  String _seasonChipLabel(Season season, Set<String> watchedEpisodeKeys) {
    final watchedCount = season.episodes
        .where(
          (episode) => watchedEpisodeKeys.contains(
            _episodeKey(season.seasonNumber, episode.episodeNumber),
          ),
        )
        .length;
    if (season.episodes.isEmpty) {
      return season.title;
    }
    return '${season.title} ($watchedCount/${season.episodes.length})';
  }

  Future<void> _toggleEpisode(
    int seasonNumber,
    Episode episode, {
    required Set<String> watchedEpisodeKeys,
  }) async {
    final key = _episodeKey(seasonNumber, episode.episodeNumber);
    if (_pendingEpisodeKeys.contains(key)) {
      return;
    }
    setState(() {
      _pendingEpisodeKeys.add(key);
    });
    try {
      await ref.read(collectionMutationsProvider).setTrackingEpisodeCompleted(
            widget.seriesRef,
            seasonNumber: seasonNumber,
            episodeNumber: episode.episodeNumber,
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
    Season season, {
    required bool completed,
  }) async {
    if (_seasonMutationInFlight) {
      return;
    }
    setState(() {
      _seasonMutationInFlight = true;
    });
    try {
      await ref.read(collectionMutationsProvider).setSeasonEpisodesCompleted(
            widget.seriesRef,
            seasonNumber: season.seasonNumber,
            episodeNumbers: season.episodes.map((episode) => episode.episodeNumber),
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

  String _episodeKeyForUnit(TrackingUnit unit) {
    return _episodeKey(unit.seasonNumber ?? 0, unit.episodeNumber ?? 0);
  }
}

/// Panel for displaying and managing custom episodes within a season.
class _CustomEpisodesPanel extends ConsumerWidget {
  const _CustomEpisodesPanel({
    required this.catalogRef,
    required this.providerSeason,
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

  final CatalogEntityRef catalogRef;
  final Season providerSeason;
  final bool showCustomEpisodes;
  final ValueChanged<bool> onShowCustomEpisodesChanged;
  final int seasonNumber;
  final Color accent;
  final AsyncValue<Map<int, List<CustomEpisode>>> customEpisodesAsync;
  final Set<String> watchedEpisodeKeys;
  final List<WatchSession> watchSessions;
  final Set<String> pendingEpisodeKeys;
  final void Function(int episodeNumber) onToggleEpisode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = appPalette(context);
    final customEpisodes = customEpisodesAsync.maybeWhen(
      data: (grouped) => grouped[seasonNumber] ?? const <CustomEpisode>[],
      orElse: () => const <CustomEpisode>[],
    );
    final providerEpisodes = providerSeason.episodes;
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
                if (providerEpisodes.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => _importProviderSeason(context, ref),
                    icon: const Icon(Icons.file_download_outlined, size: 16),
                    label: const Text('Import provider season'),
                  ),
                if (providerEpisodes.isNotEmpty)
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
                          ? 'Show provider episodes'
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
        if (!showCustomEpisodes && providerEpisodes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: TextButton.icon(
              onPressed: () => _importProviderSeason(context, ref),
              icon: const Icon(Icons.layers_outlined, size: 16),
              label: const Text('Replace provider season with custom list'),
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
                  await ref.read(collectionMutationsProvider).removeCustomEpisode(ep);
                },
              ),
        ] else ...[
          if (providerEpisodes.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: Text(
                'No provider episodes found for this season.',
                style: TextStyle(color: palette.textMuted, fontSize: 12),
              ),
            )
          else ...[
            const SizedBox(height: 4),
            for (final episode in providerEpisodes)
              _ProviderEpisodeTile(
                seasonNumber: seasonNumber,
                accent: accent,
                episode: episode,
                watched: watchedEpisodeKeys
                    .contains('$seasonNumber:${episode.episodeNumber}'),
                watchCount: watchSessions
                    .where(
                      (s) =>
                          s.seasonNumber == seasonNumber &&
                          s.episodeNumber == episode.episodeNumber,
                    )
                    .length,
                busy: pendingEpisodeKeys
                    .contains('$seasonNumber:${episode.episodeNumber}'),
                onWatchToggle: () => onToggleEpisode(episode.episodeNumber),
                onDuplicate: () => _showCustomEpisodeDialog(
                  context,
                  ref,
                  seasonNumber: seasonNumber,
                  providerEpisode: episode,
                ),
              ),
          ],
        ],
      ],
    );
  }

  Future<void> _importProviderSeason(
    BuildContext context,
    WidgetRef ref,
  ) async {
    for (final episode in providerSeason.episodes) {
      await ref.read(collectionMutationsProvider).upsertCustomEpisode(
            catalogRef: catalogRef,
            seasonNumber: providerSeason.seasonNumber,
            episodeNumber: episode.episodeNumber,
            title: episode.title,
            overview: episode.overview,
            airDate: episode.airDate,
            runtimeMinutes: episode.runtimeMinutes,
          );
    }
    onShowCustomEpisodesChanged(true);
  }

  Future<void> _showCustomEpisodeDialog(
    BuildContext context,
    WidgetRef ref, {
    required int seasonNumber,
    CustomEpisode? existing,
    Episode? providerEpisode,
  }) async {
    final result = await showDialog<_CustomEpisodeFormResult>(
      context: context,
      builder: (_) => _CustomEpisodeFormDialog(
        accent: accent,
        title: existing == null ? 'Add custom episode' : 'Edit custom episode',
        confirmLabel: existing == null ? 'Add' : 'Save',
        initialEpisodeNumber:
            existing?.episodeNumber ?? providerEpisode?.episodeNumber ?? 1,
        initialTitle: existing?.title ?? providerEpisode?.title ?? '',
        initialOverview:
            existing?.overview ?? providerEpisode?.overview ?? '',
        initialAirDate: existing?.airDate ?? providerEpisode?.airDate ?? '',
        initialRuntimeMinutes:
            existing?.runtimeMinutes ?? providerEpisode?.runtimeMinutes,
      ),
    );
    if (result == null || !context.mounted) return;
    await ref.read(collectionMutationsProvider).upsertCustomEpisode(
          id: existing?.id,
          catalogRef: catalogRef,
          seasonNumber: seasonNumber,
          episodeNumber: result.episodeNumber,
          title: result.title,
          overview: result.overview,
          airDate: result.airDate,
          runtimeMinutes: result.runtimeMinutes,
        );
  }

  Future<void> _renumberCustomEpisode(
    BuildContext context,
    WidgetRef ref,
    CustomEpisode episode,
    int newEpisodeNumber,
  ) async {
    await ref.read(collectionMutationsProvider).upsertCustomEpisode(
          id: episode.id,
          catalogRef: catalogRef,
          seasonNumber: episode.seasonNumber,
          episodeNumber: newEpisodeNumber < 1 ? 1 : newEpisodeNumber,
          title: episode.title,
          overview: episode.overview,
          airDate: episode.airDate,
          runtimeMinutes: episode.runtimeMinutes,
        );
  }

  List<CustomEpisode> _sortedCustomEpisodes(List<CustomEpisode> episodes) {
    final sorted = [...episodes];
    sorted.sort((a, b) => a.episodeNumber.compareTo(b.episodeNumber));
    return sorted;
  }
}

class _ProviderEpisodeTile extends StatelessWidget {
  const _ProviderEpisodeTile({
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
  final Episode episode;
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
          episodeNumber: episode.episodeNumber,
          title: episode.title,
          airDate: _parseDate(episode.airDate),
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
  final CustomEpisode episode;
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
          airDate: _parseDate(episode.airDate),
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
  });

  final int episodeNumber;
  final String title;
  final String? overview;
  final String? airDate;
  final int? runtimeMinutes;
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
  });

  final Color accent;
  final String title;
  final String confirmLabel;
  final int initialEpisodeNumber;
  final String initialTitle;
  final String? initialOverview;
  final String? initialAirDate;
  final int? initialRuntimeMinutes;

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
    _airDateController = TextEditingController(text: widget.initialAirDate ?? '');
    _runtimeController = TextEditingController(
      text: widget.initialRuntimeMinutes?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _episodeNumberController.dispose();
    _titleController.dispose();
    _overviewController.dispose();
    _airDateController.dispose();
    _runtimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AccentAlertDialog(
      titlePadding: EdgeInsets.zero,
      title: AccentDialogHeader(
        title: widget.title,
        accent: widget.accent,
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
            TextField(
              controller: _airDateController,
              decoration: const InputDecoration(
                labelText: 'Air date (optional)',
                hintText: 'YYYY-MM-DD',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _runtimeController,
              decoration: const InputDecoration(
                labelText: 'Runtime minutes (optional)',
              ),
              keyboardType: TextInputType.number,
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