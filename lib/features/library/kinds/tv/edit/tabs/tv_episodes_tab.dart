import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/custom_episode.dart';
import 'package:collectarr_app/core/models/tracking_unit.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/dialogs/tv_custom_episode_dialog.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit/widgets/tv_episode_row.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_domain.dart';
import 'package:collectarr_app/features/library/shared/video/edit/video_edit_controller.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
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
              final providerEpisodes = series == null
                  ? const <TvEpisode>[]
                  : videoEdit.flattenTvEpisodes(series);
              final customEpisodes = _sortedCustomEpisodes(customEpisodesAsync);
              final rows = _mergedEpisodeRows(
                providerEpisodes: providerEpisodes,
                customEpisodes: customEpisodes,
                trackedUnits: trackedUnits,
                watchSessions: watchSessions,
                videoEdit: videoEdit,
              );

              if (snapshot.connectionState == ConnectionState.waiting &&
                  series == null &&
                  customEpisodesAsync.isLoading &&
                  rows.isEmpty) {
                return const EditSectionStateMessage(
                  message: 'Loading TV episodes...',
                  icon: Icons.hourglass_empty,
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          series == null ? 'Local episode overrides' : 'Episodes',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => showTvCustomEpisodeDialog(
                          context,
                          ref: ref,
                          type: type,
                          itemId: item.id,
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Add episode'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (rows.isEmpty)
                    EditSectionStateMessage(
                      message: series == null
                          ? 'No local episodes yet.'
                          : 'No episodes found for this series yet.',
                      icon: Icons.play_circle_outline,
                    )
                  else
                    for (final season in _groupBySeason(rows))
                      _buildSeasonCard(
                        context,
                        seasonTitle: 'Season ${season.seasonNumber}',
                        imageUrl:
                            season.posterUrl ?? series?.posterUrl ?? series?.backdropUrl,
                        episodes: season.episodes,
                        trackedUnits: trackedUnits,
                        watchSessions: watchSessions,
                        accent: accent,
                        type: type,
                        itemId: item.id,
                        ref: ref,
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

class _EpisodeRowData {
  const _EpisodeRowData({
    required this.seasonNumber,
    required this.episodeNumber,
    required this.title,
    required this.overview,
    required this.airDate,
    required this.runtimeMinutes,
    required this.stillImageUrl,
    required this.localImagePath,
    required this.thumbnailImageUrl,
    required this.discNumber,
    required this.watched,
    required this.rating,
    required this.customEpisode,
  });

  final int seasonNumber;
  final int episodeNumber;
  final String title;
  final String? overview;
  final String? airDate;
  final int? runtimeMinutes;
  final String? stillImageUrl;
  final String? localImagePath;
  final String? thumbnailImageUrl;
  final int? discNumber;
  final bool watched;
  final int? rating;
  final CustomEpisode? customEpisode;
}

class _SeasonGroup {
  const _SeasonGroup({
    required this.seasonNumber,
    required this.posterUrl,
    required this.episodes,
  });

  final int seasonNumber;
  final String? posterUrl;
  final List<_EpisodeRowData> episodes;
}

List<CustomEpisode> _sortedCustomEpisodes(
  AsyncValue<Map<int, List<CustomEpisode>>> customEpisodesAsync,
) {
  final episodes = customEpisodesAsync.maybeWhen(
    data: (grouped) => grouped.values.expand((episodes) => episodes).toList(),
    orElse: () => const <CustomEpisode>[],
  ).toList(growable: true)
    ..sort((a, b) {
      final seasonCompare = a.seasonNumber.compareTo(b.seasonNumber);
      if (seasonCompare != 0) return seasonCompare;
      return a.episodeNumber.compareTo(b.episodeNumber);
    });
  return episodes;
}

List<_EpisodeRowData> _mergedEpisodeRows({
  required List<TvEpisode> providerEpisodes,
  required List<CustomEpisode> customEpisodes,
  required List<TrackingUnit> trackedUnits,
  required List<WatchSession> watchSessions,
  required VideoEditController videoEdit,
}) {
  final rowsByKey = <String, _EpisodeRowData>{};

  for (final episode in providerEpisodes) {
    rowsByKey['${episode.seasonNumber}:${episode.episodeNumber}'] = _EpisodeRowData(
      seasonNumber: episode.seasonNumber,
      episodeNumber: episode.episodeNumber,
      title: episode.title ?? 'Untitled',
      overview: episode.overview,
      airDate: _formatDate(episode.airDate),
      runtimeMinutes: episode.runtimeMinutes,
      stillImageUrl: episode.stillUrl,
      localImagePath: null,
      thumbnailImageUrl: null,
      discNumber: videoEdit.discAssignmentForEpisode(
        episodeId: episode.id,
        seasonNumber: episode.seasonNumber,
        episodeNumber: episode.episodeNumber,
      ),
      watched: _episodeWatched(
        trackedUnits: trackedUnits,
        watchSessions: watchSessions,
        seasonNumber: episode.seasonNumber,
        episodeNumber: episode.episodeNumber,
      ),
      rating: null,
      customEpisode: null,
    );
  }

  for (final episode in customEpisodes) {
    rowsByKey['${episode.seasonNumber}:${episode.episodeNumber}'] = _EpisodeRowData(
      seasonNumber: episode.seasonNumber,
      episodeNumber: episode.episodeNumber,
      title: episode.title,
      overview: episode.overview,
      airDate: episode.airDate,
      runtimeMinutes: episode.runtimeMinutes,
      stillImageUrl: episode.stillImageUrl,
      localImagePath: episode.localImagePath,
      thumbnailImageUrl: episode.thumbnailImageUrl,
      discNumber: videoEdit.discAssignmentForEpisode(
        episodeId: episode.id,
        seasonNumber: episode.seasonNumber,
        episodeNumber: episode.episodeNumber,
      ),
      watched: _episodeWatched(
        trackedUnits: trackedUnits,
        watchSessions: watchSessions,
        seasonNumber: episode.seasonNumber,
        episodeNumber: episode.episodeNumber,
      ),
      rating: null,
      customEpisode: episode,
    );
  }

  final rows = rowsByKey.values.toList(growable: true)
    ..sort((a, b) {
      final seasonCompare = a.seasonNumber.compareTo(b.seasonNumber);
      if (seasonCompare != 0) return seasonCompare;
      return a.episodeNumber.compareTo(b.episodeNumber);
    });
  return rows;
}

List<_SeasonGroup> _groupBySeason(List<_EpisodeRowData> rows) {
  final grouped = <int, List<_EpisodeRowData>>{};
  for (final row in rows) {
    grouped.putIfAbsent(row.seasonNumber, () => <_EpisodeRowData>[]).add(row);
  }
  return [
    for (final entry in grouped.entries)
      _SeasonGroup(seasonNumber: entry.key, posterUrl: null, episodes: entry.value),
  ];
}

Widget _buildSeasonCard(
  BuildContext context, {
  required String seasonTitle,
  required String? imageUrl,
  required List<_EpisodeRowData> episodes,
  required List<TrackingUnit> trackedUnits,
  required List<WatchSession> watchSessions,
  required Color accent,
  required LibraryTypeConfig type,
  required String itemId,
  required WidgetRef ref,
}) {
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
            Text(seasonTitle, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            if (episodes.isEmpty)
              Text(
                'No episodes in this season.',
                style: TextStyle(color: appPalette(context).textMuted),
              )
            else
              for (final episode in episodes)
                TvEpisodeRow(
                  accent: accent,
                  seasonNumber: episode.seasonNumber,
                  episodeNumber: episode.episodeNumber,
                  title: episode.title,
                  overview: episode.overview,
                  airDate: episode.airDate,
                  runtimeMinutes: episode.runtimeMinutes,
                  imageUrl: episode.stillImageUrl,
                  fallbackImageUrl: imageUrl,
                  localImagePath: episode.localImagePath,
                  thumbnailImageUrl: episode.thumbnailImageUrl,
                  discNumber: episode.discNumber,
                  watched: episode.watched,
                  rating: episode.rating,
                  onEdit: () => showTvCustomEpisodeDialog(
                    context,
                    ref: ref,
                    type: type,
                    itemId: itemId,
                    existingEpisode: episode.customEpisode,
                    seasonNumber: episode.seasonNumber,
                    episodeNumber: episode.episodeNumber,
                    title: episode.title,
                    overview: episode.overview,
                    airDate: episode.airDate,
                    runtimeMinutes: episode.runtimeMinutes,
                    stillImageUrl: episode.stillImageUrl,
                    localImagePath: episode.localImagePath,
                    thumbnailImageUrl: episode.thumbnailImageUrl,
                  ),
                  onDelete: episode.customEpisode == null
                      ? null
                      : () async {
                          await ref
                              .read(collectionMutationsProvider)
                              .removeCustomEpisode(episode.customEpisode!);
                        },
                ),
          ],
        ),
      ),
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

String? _formatDate(DateTime? value) {
  if (value == null) {
    return null;
  }
  return value.toIso8601String().split('T').first;
}
