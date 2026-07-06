import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/custom_episode.dart';
import 'package:collectarr_app/core/models/season.dart';
import 'package:collectarr_app/core/models/tracking_unit.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_domain.dart';
import 'package:collectarr_app/features/library/kinds/video/edit/video_edit_controller.dart';
import 'package:collectarr_app/features/library/providers/seasons_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TvEpisodesTab extends ConsumerWidget {
  const TvEpisodesTab({
    super.key,
    required this.type,
    required this.item,
    required this.accent,
    required this.videoEdit,
  });

  final LibraryTypeConfig type;
  final LibraryMetadataItem item;
  final Color accent;
  final VideoEditController videoEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seriesRef = CatalogEntityRef(
      kind: type.workspace.kind.apiValue,
      entityType: CatalogEntityType.work,
      id: item.id,
    );
    final customEpisodesAsync =
        ref.watch(customEpisodesByCatalogRefProvider(seriesRef));
    final trackedUnits = ref.watch(trackingUnitsByCatalogRefProvider(seriesRef));
    final watchSessions = ref.watch(watchSessionsByCatalogRefProvider(seriesRef));
    final ratingMap = <String, int>{};
    final future = videoEdit.tvSeriesFuture ??= videoEdit.loadTvSeriesSnapshot();

    return EditTabShell(
      children: [
        EditSection(
          title: 'Episodes',
          accent: accent,
          child: FutureBuilder<TvSeries?>(
            future: future,
            builder: (context, snapshot) {
              final series = snapshot.data ?? videoEdit.tvSeriesSnapshot;
              if (snapshot.connectionState == ConnectionState.waiting &&
                  series == null) {
                return const EditSectionStateMessage(
                  message: 'Loading TV episodes...',
                  icon: Icons.hourglass_empty,
                );
              }
              final seasons = _resolvedTvSeasons(series, videoEdit);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (series == null)
                    const EditSectionStateMessage(
                      message:
                          'No provider TV series data is available yet. Use custom episodes below.',
                      icon: Icons.edit_note,
                    )
                  else ...[
                    Text(
                      'Provider episodes',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 10),
                    if (seasons.isEmpty)
                      const EditSectionStateMessage(
                        message:
                            'No provider episodes found for this series yet.',
                        icon: Icons.info_outline,
                      )
                    else
                      for (final season in seasons)
                        _tvSeasonEpisodeGroup(
                          context,
                          accent: accent,
                          seasonTitle: 'Season ${season.seasonNumber}',
                          imageUrl: season.posterUrl ??
                              series.posterUrl ??
                              series.backdropUrl,
                          providerEpisodes: season.episodes,
                          customEpisodes: const <TvEpisode>[],
                          customEpisodeModels: const <CustomEpisode>[],
                          seasonNumber: season.seasonNumber,
                          series: series,
                          trackedUnits: trackedUnits,
                          watchSessions: watchSessions,
                          ratingMap: ratingMap,
                          videoEdit: videoEdit,
                        ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Custom episodes',
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _showManualCustomEpisodeDialog(
                          context,
                          ref: ref,
                          type: type,
                          itemId: item.id as String,
                          accent: accent,
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Add episode'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  customEpisodesAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                    error: (_, __) => const EditSectionStateMessage(
                      message: 'Unable to load custom episodes.',
                      icon: Icons.error_outline,
                    ),
                    data: (grouped) {
                      final customEpisodes = grouped.values
                          .expand((episodes) => episodes)
                          .toList(growable: false)
                        ..sort((a, b) {
                          final seasonCompare =
                              a.seasonNumber.compareTo(b.seasonNumber);
                          if (seasonCompare != 0) return seasonCompare;
                          return a.episodeNumber.compareTo(b.episodeNumber);
                        });
                      if (customEpisodes.isEmpty) {
                        return const EditSectionStateMessage(
                          message: 'No custom episodes yet.',
                          icon: Icons.playlist_add,
                        );
                      }
                      final groupedCustomEpisodes = <int, List<CustomEpisode>>{};
                      for (final episode in customEpisodes) {
                        groupedCustomEpisodes
                            .putIfAbsent(episode.seasonNumber, () => <CustomEpisode>[])
                            .add(episode);
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final entry in groupedCustomEpisodes.entries)
                            _tvSeasonEpisodeGroup(
                              context,
                              accent: accent,
                              seasonTitle: 'Season ${entry.key}',
                              imageUrl: _seriesFallbackImage(series),
                              providerEpisodes: const <TvEpisode>[],
                              customEpisodes: const <TvEpisode>[],
                              customEpisodeModels: entry.value,
                              seasonNumber: entry.key,
                              series: series,
                              trackedUnits: trackedUnits,
                              watchSessions: watchSessions,
                              ratingMap: ratingMap,
                              videoEdit: videoEdit,
                            ),
                        ],
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class TvReleaseMediaTab extends ConsumerWidget {
  const TvReleaseMediaTab({
    super.key,
    required this.type,
    required this.item,
    required this.accent,
    required this.videoEdit,
  });

  final LibraryTypeConfig type;
  final LibraryMetadataItem item;
  final Color accent;
  final VideoEditController videoEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Release media',
          accent: accent,
          child: FutureBuilder<TvSeries?>(
            future: videoEdit.tvSeriesFuture ??= videoEdit.loadTvSeriesSnapshot(),
            builder: (context, snapshot) {
              final series = snapshot.data ?? videoEdit.tvSeriesSnapshot;
              if (snapshot.connectionState == ConnectionState.waiting &&
                  series == null) {
                return const EditSectionStateMessage(
                  message: 'Loading TV release media...',
                  icon: Icons.hourglass_empty,
                );
              }
              if (series == null) {
                return const EditSectionStateMessage(
                  message: 'No TV series data is available for this item yet.',
                  icon: Icons.tv_off_outlined,
                );
              }
              final media = videoEdit.tvReleaseMediaDraft.isEmpty
                  ? videoEdit.buildFallbackTvReleaseMedia(series)
                  : videoEdit.tvReleaseMediaDraft;
              if (media.isEmpty) {
                return const EditSectionStateMessage(
                  message: 'No release media is available for this series.',
                  icon: Icons.album_outlined,
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const EditSectionStateMessage(
                    message:
                        'Disc metadata is editable here; episode assignments are staged in the Episode map tab.',
                    icon: Icons.info_outline,
                  ),
                  const SizedBox(height: 12),
                  for (final disc in media)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        elevation: 0,
                        color: appPalette(context).panelRaised,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.album_outlined,
                                    size: 18,
                                    color: appPalette(context).textMuted,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    disc.title ?? 'Disc ${disc.discNumber ?? 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Disc ${disc.discNumber ?? 1}',
                                    style: TextStyle(
                                      color: appPalette(context).textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              if (disc.formatLabel != null) ...[
                                const SizedBox(height: 8),
                                Text('Format: ${disc.formatLabel}'),
                              ],
                              if (disc.features.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text('Features: ${disc.features.join(', ')}'),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class TvEpisodeDiscMapTab extends ConsumerWidget {
  const TvEpisodeDiscMapTab({
    super.key,
    required this.type,
    required this.item,
    required this.accent,
    required this.videoEdit,
  });

  final LibraryTypeConfig type;
  final LibraryMetadataItem item;
  final Color accent;
  final VideoEditController videoEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customEpisodesAsync = ref.watch(
      customEpisodesByCatalogRefProvider(
        CatalogEntityRef(
          kind: type.workspace.kind.apiValue,
          entityType: CatalogEntityType.work,
          id: item.id,
        ),
      ),
    );
    return EditTabShell(
      children: [
        EditSection(
          title: 'Episode map',
          accent: accent,
          child: FutureBuilder<TvSeries?>(
            future: videoEdit.tvSeriesFuture ??= videoEdit.loadTvSeriesSnapshot(),
            builder: (context, snapshot) {
              final series = snapshot.data ?? videoEdit.tvSeriesSnapshot;
              if (snapshot.connectionState == ConnectionState.waiting &&
                  series == null) {
                return const EditSectionStateMessage(
                  message: 'Loading TV episodes...',
                  icon: Icons.hourglass_empty,
                );
              }
              if (series == null) {
                return _manualEpisodeFallbackSection(
                  context,
                  accent: accent,
                  customEpisodesAsync: customEpisodesAsync,
                  type: type,
                  itemId: item.id as String,
                  ref: ref,
                );
              }
              final episodes = videoEdit.flattenTvEpisodes(series);
              if (episodes.isEmpty) {
                return _manualEpisodeFallbackSection(
                  context,
                  accent: accent,
                  customEpisodesAsync: customEpisodesAsync,
                  type: type,
                  itemId: item.id as String,
                  ref: ref,
                );
              }
              final discNumbers = <int>{
                for (final media in videoEdit.tvReleaseMediaDraft) media.discNumber ?? 1,
                if (videoEdit.tvReleaseMediaDraft.isEmpty) 1,
                for (final assignment in videoEdit.tvEpisodeDiscAssignments.values) assignment,
              }.toList()
                ..sort();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const EditSectionStateMessage(
                    message:
                        'Move episodes between discs here. The current mapping is staged locally in the dialog.',
                    icon: Icons.info_outline,
                  ),
                  const SizedBox(height: 12),
                  for (final season in series.seasons.isNotEmpty
                      ? series.seasons
                      : <TvSeason>[
                          TvSeason(
                            id: '${series.id}:season:1',
                            seriesId: series.id,
                            seasonNumber: 1,
                            episodes: episodes,
                          ),
                        ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        elevation: 0,
                        color: appPalette(context).panelRaised,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Season ${season.seasonNumber}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              for (final episode in season.episodes.isNotEmpty
                                  ? season.episodes
                                  : episodes.where(
                                      (episode) =>
                                          episode.seasonNumber ==
                                          season.seasonNumber,
                                    ))
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          videoEdit.tvEpisodeLabel(episode),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        flex: 2,
                                        child: DropdownButtonFormField<int>(
                                          initialValue:
                                              videoEdit.tvEpisodeDiscAssignments[episode.id] ??
                                                  (discNumbers.isEmpty
                                                      ? 1
                                                      : discNumbers.first),
                                          isExpanded: true,
                                          decoration: const InputDecoration(
                                            labelText: 'Disc',
                                          ),
                                          items: [
                                            for (final disc in discNumbers)
                                              DropdownMenuItem<int>(
                                                value: disc,
                                                child: Text('Disc $disc'),
                                              ),
                                          ],
                                          onChanged: (value) {
                                            if (value == null) {
                                              return;
                                            }
                                            videoEdit.updateTvEpisodeDiscAssignment(
                                              episode.id,
                                              value,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

List<TvSeason> _resolvedTvSeasons(TvSeries? series, VideoEditController videoEdit) {
  if (series == null) {
    return const <TvSeason>[];
  }
  if (series.seasons.isNotEmpty) {
    return series.seasons;
  }
  final episodes = videoEdit.flattenTvEpisodes(series);
  if (episodes.isEmpty) {
    return const <TvSeason>[];
  }
  final grouped = <int, List<TvEpisode>>{};
  for (final episode in episodes) {
    grouped.putIfAbsent(episode.seasonNumber, () => <TvEpisode>[]).add(episode);
  }
  return [
    for (final entry in grouped.entries)
      TvSeason(
        id: '${series.id}:season:${entry.key}',
        seriesId: series.id,
        seasonNumber: entry.key,
        episodes: entry.value,
        posterUrl: series.posterUrl,
      ),
  ];
}

String? _seriesFallbackImage(TvSeries? series) {
  if (series == null) {
    return null;
  }
  return series.posterUrl ?? series.backdropUrl;
}

Widget _tvSeasonEpisodeGroup(
  BuildContext context, {
  required String seasonTitle,
  required String? imageUrl,
  required List<TvEpisode> providerEpisodes,
  required List<TvEpisode> customEpisodes,
  required List<CustomEpisode> customEpisodeModels,
  required int seasonNumber,
  required TvSeries? series,
  required List<TrackingUnit> trackedUnits,
  required List<WatchSession> watchSessions,
  required Map<String, int> ratingMap,
  required VideoEditController videoEdit,
  required Color accent,
}) {
  final episodeItems = <Widget>[
    for (final episode in providerEpisodes)
      _tvEpisodeCard(
        context,
        accent: accent,
        seasonNumber: seasonNumber,
        episodeNumber: episode.episodeNumber,
        title: episode.title ?? 'Untitled',
        overview: episode.overview,
        airDate: _formatDate(episode.airDate),
        runtimeMinutes: episode.runtimeMinutes,
        imageUrl: episode.stillUrl,
        fallbackImageUrl: imageUrl,
        localImagePath: null,
        thumbnailImageUrl: null,
        discNumber: videoEdit.tvEpisodeDiscAssignments[episode.id],
        watched: _episodeWatched(
          trackedUnits: trackedUnits,
          watchSessions: watchSessions,
          seasonNumber: seasonNumber,
          episodeNumber: episode.episodeNumber,
        ),
        rating: ratingMap[_episodeRatingKey(seasonNumber, episode.episodeNumber)],
        onEdit: null,
        onDelete: null,
      ),
    for (final episode in customEpisodeModels)
      _tvEpisodeCard(
        context,
        accent: accent,
        seasonNumber: episode.seasonNumber,
        episodeNumber: episode.episodeNumber,
        title: episode.title,
        overview: episode.overview,
        airDate: episode.airDate,
        runtimeMinutes: episode.runtimeMinutes,
        imageUrl: episode.stillImageUrl,
        fallbackImageUrl: _seriesFallbackImage(series),
        localImagePath: episode.localImagePath,
        thumbnailImageUrl: episode.thumbnailImageUrl,
        discNumber: null,
        watched: _episodeWatched(
          trackedUnits: trackedUnits,
          watchSessions: watchSessions,
          seasonNumber: episode.seasonNumber,
          episodeNumber: episode.episodeNumber,
        ),
        rating: ratingMap[_episodeRatingKey(episode.seasonNumber, episode.episodeNumber)],
        onEdit: () {},
        onDelete: () {},
      ),
  ];

  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Card(
      elevation: 0,
      color: appPalette(context).panelRaised,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              seasonTitle,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            if (episodeItems.isEmpty)
              Text(
                'No episodes in this season.',
                style: TextStyle(color: appPalette(context).textMuted),
              )
            else
              Column(children: episodeItems),
          ],
        ),
      ),
    ),
  );
}

Widget _tvEpisodeCard(
  BuildContext context, {
  required Color accent,
  required int seasonNumber,
  required int episodeNumber,
  required String title,
  required String? overview,
  required String? airDate,
  required int? runtimeMinutes,
  required String? imageUrl,
  required String? fallbackImageUrl,
  required String? localImagePath,
  required String? thumbnailImageUrl,
  required int? discNumber,
  required bool watched,
  required int? rating,
  required VoidCallback? onEdit,
  required VoidCallback? onDelete,
}) {
  final code =
      'S${seasonNumber.toString().padLeft(2, '0')}E${episodeNumber.toString().padLeft(2, '0')}';
  final resolvedImage = imageUrl ?? thumbnailImageUrl ?? fallbackImageUrl;
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Material(
      color: appPalette(context).surfaceSubtle.withValues(alpha: 0.82),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: accent.withValues(alpha: 0.14)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 78,
              color: appPalette(context).surface,
              child: resolvedImage == null ? const Icon(Icons.image_outlined) : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$code • $title',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _pill(context, watched ? 'Watched' : 'Unwatched'),
                      if (airDate != null && airDate.trim().isNotEmpty)
                        _pill(context, airDate.trim()),
                      if (runtimeMinutes != null) _pill(context, '$runtimeMinutes min'),
                      if (rating != null) _pill(context, 'Rating $rating'),
                      _pill(
                        context,
                        discNumber == null
                            ? 'No disc assignment'
                            : 'Disc $discNumber',
                      ),
                    ],
                  ),
                  if (overview != null && overview.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      overview.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: appPalette(context).textMuted),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _pill(BuildContext context, String label) {
  return DecoratedBox(
    decoration: BoxDecoration(
      color: appPalette(context).panel,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: appPalette(context).divider),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(label, style: const TextStyle(fontSize: 11)),
    ),
  );
}

bool _episodeWatched({
  required List<TrackingUnit> trackedUnits,
  required List<WatchSession> watchSessions,
  required int seasonNumber,
  required int episodeNumber,
}) {
  final tracked = trackedUnits.any(
    (unit) =>
        unit.unitType == TrackingUnitType.episode &&
        unit.seasonNumber == seasonNumber &&
        unit.episodeNumber == episodeNumber &&
        !unit.isDeleted,
  );
  if (tracked) {
    return true;
  }
  return watchSessions.any(
    (session) =>
        session.seasonNumber == seasonNumber &&
        session.episodeNumber == episodeNumber &&
        !session.isDeleted,
  );
}

String _episodeRatingKey(int seasonNumber, int episodeNumber) {
  return '$seasonNumber:$episodeNumber';
}

String? _formatDate(DateTime? value) {
  if (value == null) {
    return null;
  }
  return value.toIso8601String().split('T').first;
}

Widget _manualEpisodeFallbackSection(
  BuildContext context, {
  required Color accent,
  required AsyncValue<Map<int, List<CustomEpisode>>> customEpisodesAsync,
  required LibraryTypeConfig type,
  required String itemId,
  required WidgetRef ref,
}) {
  final customEpisodes = customEpisodesAsync.maybeWhen(
    data: (grouped) => grouped.values.expand((episodes) => episodes).toList(),
    orElse: () => const <CustomEpisode>[],
  )..sort((a, b) {
      final seasonCompare = a.seasonNumber.compareTo(b.seasonNumber);
      if (seasonCompare != 0) return seasonCompare;
      return a.episodeNumber.compareTo(b.episodeNumber);
    });
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const EditSectionStateMessage(
        message:
            'No provider TV series data is available yet. Add custom episodes manually below.',
        icon: Icons.edit_note,
      ),
      const SizedBox(height: 12),
      if (customEpisodes.isEmpty)
        Text(
          'No custom episodes yet.',
          style: TextStyle(color: appPalette(context).textMuted),
        )
      else
        for (final episode in customEpisodes)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              elevation: 0,
              color: appPalette(context).panelRaised,
              child: ListTile(
                dense: true,
                title: Text(
                  'S${episode.seasonNumber.toString().padLeft(2, '0')}E${episode.episodeNumber.toString().padLeft(2, '0')}  ${episode.title}',
                ),
                subtitle: Text(
                  [
                    if (episode.overview != null &&
                        episode.overview!.trim().isNotEmpty)
                      episode.overview!.trim(),
                    if (episode.airDate != null &&
                        episode.airDate!.trim().isNotEmpty)
                      episode.airDate!,
                  ].join(' • '),
                ),
                trailing: IconButton(
                  tooltip: 'Delete episode',
                  onPressed: () async {
                    await ref.read(collectionMutationsProvider).removeCustomEpisode(episode);
                  },
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
            ),
          ),
    ],
  );
}

Future<void> _showManualCustomEpisodeDialog(
  BuildContext context, {
  required WidgetRef ref,
  required LibraryTypeConfig type,
  required String itemId,
  required Color accent,
}) async {
  await showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Add episode'),
      content: const Text('Use the existing edit dialog flow to add custom episodes.'),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
      ],
    ),
  );
}
