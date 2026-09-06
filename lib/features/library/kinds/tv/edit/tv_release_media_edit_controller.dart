import 'dart:async';

import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/remote/tv_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Owns the TV-only release-media and episode-to-disc editing state.
///
/// The generic video editor still owns controls shared by video kinds, while
/// TV owns the series snapshot and its release/episode mapping semantics here.
final class TvReleaseMediaEditController {
  TvReleaseMediaEditController({
    required this.item,
    this.ref,
    this.initialDiscCount,
  });

  final CatalogItem item;
  final WidgetRef? ref;
  final int? initialDiscCount;

  Future<TvSeries?>? tvSeriesFuture;
  TvSeries? tvSeriesSnapshot;
  List<TvReleaseMedia> tvReleaseMediaDraft = const <TvReleaseMedia>[];
  Map<String, int> tvEpisodeDiscAssignments = <String, int>{};

  Future<TvSeries?> loadTvSeriesSnapshot() async {
    if (ref == null) return null;
    final api = ref!.read(apiClientProvider);
    final meta = item.kindMetadata;
    final seriesId =
        (meta is TvSeriesMetadata ? meta.series?.seriesId : null) ?? item.id;
    try {
      final dto = await api
          .getTvSeriesDto(seriesId)
          .timeout(const Duration(seconds: 20));
      final series = TvCoreMapper.fromSeriesDto(dto);
      tvSeriesSnapshot = series;
      primeTvSeriesDraft(series);
      return series;
    } on TimeoutException {
      return null;
    }
  }

  void primeTvSeriesDraft(TvSeries series) {
    tvSeriesSnapshot = series;
    tvReleaseMediaDraft = series.media.isEmpty
        ? buildFallbackTvReleaseMedia(series)
        : List<TvReleaseMedia>.from(series.media);
    tvEpisodeDiscAssignments = {
      for (final media in tvReleaseMediaDraft)
        for (final episode in media.episodes) ...{
          episode.id: media.mediaNumber ?? 1,
          '${episode.seasonNumber}:${episode.episodeNumber}':
              media.mediaNumber ?? 1,
        },
    };
    if (tvEpisodeDiscAssignments.isEmpty) {
      final fallbackDisc = tvReleaseMediaDraft.isEmpty
          ? 1
          : (tvReleaseMediaDraft.first.mediaNumber ?? 1);
      for (final episode in flattenTvEpisodes(series)) {
        tvEpisodeDiscAssignments[episode.id] = fallbackDisc;
        tvEpisodeDiscAssignments[
            '${episode.seasonNumber}:${episode.episodeNumber}'] = fallbackDisc;
      }
    }
  }

  void updateTvEpisodeDiscAssignment(
    String episodeId, {
    required int seasonNumber,
    required int episodeNumber,
    required int discNumber,
  }) {
    tvEpisodeDiscAssignments[episodeId] = discNumber;
    tvEpisodeDiscAssignments['$seasonNumber:$episodeNumber'] = discNumber;
  }

  int? discAssignmentForEpisode({
    required String episodeId,
    required int seasonNumber,
    required int episodeNumber,
  }) {
    return tvEpisodeDiscAssignments[episodeId] ??
        tvEpisodeDiscAssignments['$seasonNumber:$episodeNumber'];
  }

  List<TvReleaseMedia> buildFallbackTvReleaseMedia(TvSeries series) {
    final episodes = flattenTvEpisodes(series);
    final discCount =
        (initialDiscCount ?? episodes.length).clamp(1, 20).toInt();
    final meta = item.kindMetadata;
    final formatLabel = meta is TvSeriesMetadata
        ? (meta.physicalFormatLabel ?? meta.physicalFormat)
        : null;
    if (discCount == 1) {
      return [
        TvReleaseMedia(
          id: '${series.id}:media:1',
          releaseId: series.id,
          title: 'Disc 1',
          mediaType: formatLabel,
          mediaNumber: 1,
          episodes: episodes,
        ),
      ];
    }
    return [
      for (var i = 1; i <= discCount; i++)
        TvReleaseMedia(
          id: '${series.id}:media:$i',
          releaseId: series.id,
          title: 'Disc $i',
          mediaType: formatLabel,
          mediaNumber: i,
          episodes: const <TvEpisode>[],
        ),
    ];
  }

  List<TvEpisode> flattenTvEpisodes(TvSeries series) {
    final episodes = <TvEpisode>[];
    for (final season in series.seasons) {
      episodes.addAll(season.episodes);
    }
    if (episodes.isNotEmpty) {
      return episodes;
    }
    for (final media in series.media) {
      episodes.addAll(media.episodes);
    }
    return episodes;
  }

  String tvEpisodeLabel(TvEpisode episode) {
    final seasonPart = 'S${episode.seasonNumber.toString().padLeft(2, '0')}';
    final episodeNumber = episode.episodeNumber?.toInt() ?? 0;
    final episodePart = 'E${episodeNumber.toString().padLeft(2, '0')}';
    return '$seasonPart$episodePart ${episode.title?.isEmpty ?? true ? 'Episode' : episode.title}';
  }
}
