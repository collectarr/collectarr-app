import 'package:collectarr_app/core/models/custom_episode.dart';
import 'package:collectarr_app/core/models/season.dart';
import 'package:collectarr_app/core/models/tracking_unit.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/providers/seasons_provider.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VideoSeasonTrackingSection extends ConsumerStatefulWidget {
  const VideoSeasonTrackingSection({
    super.key,
    required this.itemId,
    required this.accent,
  });

  final String itemId;
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
    final seasonsAsync = ref.watch(itemSeasonsProvider(widget.itemId));
    final trackedUnits =
        ref.watch(trackingUnitsByCatalogItemProvider)[widget.itemId] ??
            const <TrackingUnit>[];
    final watchSessions =
        ref.watch(watchSessionsByItemProvider)[widget.itemId] ??
            const <WatchSession>[];
    final customEpisodesAsync =
        ref.watch(customEpisodesByItemProvider(widget.itemId));
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
                Row(
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: _seasonMutationInFlight ||
                              selectedSeason.episodes.isEmpty ||
                              allEpisodesWatched
                          ? null
                          : () => _setSeasonWatched(
                                selectedSeason,
                                completed: true,
                              ),
                      icon: const Icon(Icons.done_all),
                      label: const Text('Mark season watched'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: _seasonMutationInFlight ||
                              watchedInSelectedSeason == 0
                          ? null
                          : () => _setSeasonWatched(
                                selectedSeason,
                                completed: false,
                              ),
                      icon: const Icon(Icons.remove_done_outlined),
                      label: const Text('Clear season'),
                    ),
                  ],
                ),
                if (selectedSeason.episodes.isEmpty) ...[
                  const SizedBox(height: 12),
                  _CustomEpisodesPanel(
                    itemId: widget.itemId,
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
                ] else ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _showCustomEpisodes = !_showCustomEpisodes;
                          });
                        },
                        icon: Icon(
                          _showCustomEpisodes
                              ? Icons.cloud_outlined
                              : Icons.edit_note,
                          size: 16,
                        ),
                        label: Text(
                          _showCustomEpisodes
                              ? 'Show provider episodes'
                              : 'Show custom episodes',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  if (_showCustomEpisodes) ...[
                    _CustomEpisodesPanel(
                      itemId: widget.itemId,
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
                  ] else ...[
                    const SizedBox(height: 4),
                    for (final episode in selectedSeason.episodes)
                    _VideoEpisodeTile(
                      accent: widget.accent,
                      episode: episode,
                      watched: watchedEpisodeKeys.contains(
                        _episodeKey(
                          selectedSeason.seasonNumber,
                          episode.episodeNumber,
                        ),
                      ),
                      watchCount: _episodeWatchCount(
                        watchSessions,
                        selectedSeason.seasonNumber,
                        episode.episodeNumber,
                      ),
                      busy: _pendingEpisodeKeys.contains(
                        _episodeKey(
                          selectedSeason.seasonNumber,
                          episode.episodeNumber,
                        ),
                      ),
                      onPressed: () => _toggleEpisode(
                        selectedSeason.seasonNumber,
                        episode,
                        watchedEpisodeKeys: watchedEpisodeKeys,
                      ),
                    ),
                  ],
                ],
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
            widget.itemId,
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
            widget.itemId,
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

  int _episodeWatchCount(
    List<WatchSession> sessions,
    int seasonNumber,
    int episodeNumber,
  ) {
    return sessions
        .where(
          (s) => s.seasonNumber == seasonNumber && s.episodeNumber == episodeNumber,
        )
        .length;
  }
}

class _VideoEpisodeTile extends StatelessWidget {
  const _VideoEpisodeTile({
    required this.accent,
    required this.episode,
    required this.watched,
    required this.watchCount,
    required this.busy,
    required this.onPressed,
  });

  final Color accent;
  final Episode episode;
  final bool watched;
  final int watchCount;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: palette.surfaceSubtle.withValues(alpha: 0.82),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: accent.withValues(alpha: 0.14)),
        ),
        child: ListTile(
            leading: busy
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    tooltip: watched ? 'Mark unwatched' : 'Mark watched',
                    onPressed: onPressed,
                    icon: Icon(
                      watched
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: watched ? accent : palette.textMuted,
                    ),
                  ),
            title: Text(
              'E${episode.episodeNumber} • ${episode.title}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              [
                if (episode.runtimeMinutes != null) '${episode.runtimeMinutes} min',
                if (episode.airDate != null && episode.airDate!.trim().isNotEmpty)
                  episode.airDate!,
                if (watchCount > 0) '🎬 $watchCount',
              ].join(' • '),
              style: TextStyle(color: palette.textMuted, fontSize: 12),
            ),
            onTap: busy ? null : onPressed,
          ),
        ),
      );
  }
}

/// Panel for displaying and managing custom episodes within a season.
class _CustomEpisodesPanel extends ConsumerWidget {
  const _CustomEpisodesPanel({
    required this.itemId,
    required this.seasonNumber,
    required this.accent,
    required this.customEpisodesAsync,
    required this.watchedEpisodeKeys,
    required this.watchSessions,
    required this.pendingEpisodeKeys,
    required this.onToggleEpisode,
  });

  final String itemId;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.edit_note, size: 16, color: palette.textMuted),
            const SizedBox(width: 4),
            Text(
              'Custom episodes',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: palette.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add, size: 18),
              color: accent,
              tooltip: 'Add custom episode',
              onPressed: () => _showAddDialog(context, ref, customEpisodes),
            ),
          ],
        ),
        if (customEpisodes.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: 4, bottom: 4),
            child: Text(
              'No custom episodes — tap + to add one.',
              style: TextStyle(color: palette.textMuted, fontSize: 12),
            ),
          ),
        for (final ep in customEpisodes)
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
            onPressed: () => onToggleEpisode(ep.episodeNumber),
            onDelete: () async {
              await ref
                  .read(collectionMutationsProvider)
                  .removeCustomEpisode(ep);
            },
          ),
      ],
    );
  }

  Future<void> _showAddDialog(
    BuildContext context,
    WidgetRef ref,
    List<CustomEpisode> existing,
  ) async {
    final nextEpisodeNumber = existing.isEmpty
        ? 1
        : existing
                .map((e) => e.episodeNumber)
                .reduce((a, b) => a > b ? a : b) +
            1;
    final result = await showDialog<_CustomEpisodeFormResult>(
      context: context,
      builder: (_) => _CustomEpisodeFormDialog(
        accent: accent,
        initialEpisodeNumber: nextEpisodeNumber,
      ),
    );
    if (result == null || !context.mounted) return;
    await ref.read(collectionMutationsProvider).upsertCustomEpisode(
          itemId: itemId,
          seasonNumber: seasonNumber,
          episodeNumber: result.episodeNumber,
          title: result.title,
          overview: result.overview,
          airDate: result.airDate,
          runtimeMinutes: result.runtimeMinutes,
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
    required this.onPressed,
    required this.onDelete,
  });

  final Color accent;
  final CustomEpisode episode;
  final bool watched;
  final int watchCount;
  final bool busy;
  final VoidCallback onPressed;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: palette.surfaceSubtle.withValues(alpha: 0.82),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: accent.withValues(alpha: 0.14)),
        ),
        child: ListTile(
          leading: busy
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : IconButton(
                  tooltip: watched ? 'Mark unwatched' : 'Mark watched',
                  onPressed: onPressed,
                  icon: Icon(
                    watched ? Icons.check_box : Icons.check_box_outline_blank,
                    color: watched ? accent : palette.textMuted,
                  ),
                ),
          title: Text(
            'E${episode.episodeNumber} • ${episode.title}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            [
              if (episode.runtimeMinutes != null) '${episode.runtimeMinutes} min',
              if (episode.airDate != null && episode.airDate!.trim().isNotEmpty)
                episode.airDate!,
              if (watchCount > 0) '🎬 $watchCount',
              '✏️ custom',
            ].join(' • '),
            style: TextStyle(color: palette.textMuted, fontSize: 12),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            color: palette.textMuted,
            tooltip: 'Delete custom episode',
            onPressed: onDelete,
          ),
          onTap: busy ? null : onPressed,
        ),
      ),
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
    required this.initialEpisodeNumber,
  });

  final Color accent;
  final int initialEpisodeNumber;

  @override
  State<_CustomEpisodeFormDialog> createState() =>
      _CustomEpisodeFormDialogState();
}

class _CustomEpisodeFormDialogState extends State<_CustomEpisodeFormDialog> {
  late final TextEditingController _episodeNumberController;
  final _titleController = TextEditingController();
  final _overviewController = TextEditingController();
  final _airDateController = TextEditingController();
  final _runtimeController = TextEditingController();

  bool get _isValid =>
      _titleController.text.trim().isNotEmpty &&
      (int.tryParse(_episodeNumberController.text) ?? 0) > 0;

  @override
  void initState() {
    super.initState();
    _episodeNumberController = TextEditingController(
      text: widget.initialEpisodeNumber.toString(),
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
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      title: AccentDialogHeader(
        title: 'Add custom episode',
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
          child: const Text('Add'),
        ),
      ],
    );
  }
}