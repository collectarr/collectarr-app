import 'package:collectarr_app/core/models/season.dart';
import 'package:collectarr_app/core/models/tracking_unit.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/providers/seasons_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final seasonsAsync = ref.watch(itemSeasonsProvider(widget.itemId));
    final trackedUnits =
        ref.watch(trackingUnitsByCatalogItemProvider)[widget.itemId] ??
            const <TrackingUnit>[];
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
            color: const Color(0xD51C1F21),
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
                  style: const TextStyle(color: kAppTextMuted, fontSize: 12),
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
                  const Text(
                    'This season does not have episode data yet.',
                    style: TextStyle(color: kAppTextMuted),
                  ),
                ] else ...[
                  const SizedBox(height: 12),
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
}

class _VideoEpisodeTile extends StatelessWidget {
  const _VideoEpisodeTile({
    required this.accent,
    required this.episode,
    required this.watched,
    required this.busy,
    required this.onPressed,
  });

  final Color accent;
  final Episode episode;
  final bool watched;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0x10000000),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: accent.withValues(alpha: 0.14)),
        ),
        child: Material(
          color: Colors.transparent,
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
                      color: watched ? accent : kAppTextMuted,
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
              ].join(' • '),
              style: const TextStyle(color: kAppTextMuted, fontSize: 12),
            ),
            onTap: busy ? null : onPressed,
          ),
        ),
      ),
    );
  }
}