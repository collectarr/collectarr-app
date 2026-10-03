import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';

/// Holds the typed TV document used by the contained-media and episode tabs.
///
/// Episode-to-disc assignments are dialog-local presentation state; seasons,
/// episodes, and media themselves come from the root Catalog Item document.
final class TvMediaEditController {
  TvMediaEditController({
    required CatalogItemDto item,
    this.initialDiscCount,
  }) : metadata = TvMetadata.fromJson(item.kindData) {
    tvMediaDraft = metadata.media.isEmpty
        ? buildFallbackTvMedia(metadata)
        : List<TvMediaMetadata>.of(metadata.media);
    _initializeEpisodeDiscAssignments();
  }

  final TvMetadata metadata;
  final int? initialDiscCount;
  late List<TvMediaMetadata> tvMediaDraft;
  final Map<String, int> tvEpisodeDiscAssignments = <String, int>{};
  Future<TvMetadata?>? metadataFuture;
  TvMetadata? get metadataSnapshot => metadata;

  Future<TvMetadata?> loadMetadataSnapshot() async => metadata;

  void _initializeEpisodeDiscAssignments() {
    if (tvMediaDraft.isEmpty) return;
    final discNumber =
        tvMediaDraft.first.mediaNumber ?? tvMediaDraft.first.position;
    for (final episode in flattenTvEpisodes(metadata)) {
      final id = _episodeId(episode);
      tvEpisodeDiscAssignments[id] = discNumber;
      tvEpisodeDiscAssignments[
              '${episode.seasonNumber ?? 0}:${episode.episodeNumber ?? episode.position}'] =
          discNumber;
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
  }) =>
      tvEpisodeDiscAssignments[episodeId] ??
      tvEpisodeDiscAssignments['$seasonNumber:$episodeNumber'];

  List<TvMediaMetadata> buildFallbackTvMedia(TvMetadata document) {
    final episodes = flattenTvEpisodes(document);
    final discCount =
        (initialDiscCount ?? (episodes.isEmpty ? 1 : episodes.length))
            .clamp(1, 20)
            .toInt();
    final formatLabel = document.physicalFormatLabel ?? document.physicalFormat;
    return [
      for (var position = 1; position <= discCount; position++)
        TvMediaMetadata(
          position: position,
          mediaNumber: position,
          mediaType: formatLabel,
          title: 'Disc $position',
        ),
    ];
  }

  List<TvEpisodeMetadata> flattenTvEpisodes(TvMetadata document) {
    final seasonEpisodes = [
      for (final season in document.seasonsWithEpisodes) ...season.episodes,
    ];
    return seasonEpisodes;
  }

  String tvEpisodeLabel(TvEpisodeMetadata episode, {int? seasonNumber}) {
    final season = episode.seasonNumber ?? seasonNumber ?? 0;
    final number = episode.episodeNumber ?? episode.position;
    final title = episode.episodeTitle ?? episode.title;
    return 'S${season.toString().padLeft(2, '0')}E${number.toString().padLeft(2, '0')} ${title?.isEmpty ?? true ? 'Episode' : title}';
  }

  String _episodeId(TvEpisodeMetadata episode) =>
      episode.id ??
      '${episode.seasonNumber ?? 0}:${episode.episodeNumber ?? episode.position}';
}
