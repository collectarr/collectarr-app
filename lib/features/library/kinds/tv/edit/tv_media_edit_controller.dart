import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';

/// Holds the typed TV document used by the contained-media and episode tabs.
///
/// Stages TV media and episode-to-media relationships from the root document.
final class TvMediaEditController {
  TvMediaEditController({
    required CatalogItemDto item,
    this.initialDiscCount,
  }) : metadata = TvMetadata.fromJson(item.kindData) {
    tvMediaDraft = metadata.media.isEmpty
        ? buildFallbackTvMedia(metadata)
        : List<TvMediaMetadata>.unmodifiable(
            metadata.media.map(_withStableMediaId),
          );
    _initializeEpisodeDiscAssignments();
  }

  final TvMetadata metadata;
  final int? initialDiscCount;
  late List<TvMediaMetadata> tvMediaDraft;
  final Map<String, int> _tvEpisodeDiscAssignments = <String, int>{};
  final Set<String> _editedEpisodeKeys = <String>{};
  Future<TvMetadata?>? metadataFuture;
  TvMetadata? get metadataSnapshot => metadata;

  Future<TvMetadata?> loadMetadataSnapshot() async => metadata;

  void _initializeEpisodeDiscAssignments() {
    for (final season in metadata.seasonsWithEpisodes) {
      for (final episode in season.episodes) {
        final assignedMedia = tvMediaDraft
            .where((media) => media.id == episode.mediaId)
            .firstOrNull;
        if (assignedMedia == null) continue;
        _tvEpisodeDiscAssignments[_episodeKey(
          episode,
          seasonNumber: season.seasonNumber,
        )] = assignedMedia.mediaNumber ?? assignedMedia.position;
      }
    }
  }

  Iterable<int> get assignedDiscNumbers => _tvEpisodeDiscAssignments.values;

  void updateTvEpisodeDiscAssignment(
    String episodeId, {
    required int seasonNumber,
    required int episodeNumber,
    required int discNumber,
  }) {
    final key =
        episodeId.isNotEmpty ? 'id:$episodeId' : '$seasonNumber:$episodeNumber';
    _tvEpisodeDiscAssignments[key] = discNumber;
    _editedEpisodeKeys.add(key);
  }

  int? discAssignmentForEpisode({
    required String episodeId,
    required int seasonNumber,
    required int episodeNumber,
  }) =>
      _tvEpisodeDiscAssignments[episodeId.isNotEmpty
          ? 'id:$episodeId'
          : '$seasonNumber:$episodeNumber'];

  TvMetadata applyEpisodeMediaAssignments(TvMetadata document) {
    if (_editedEpisodeKeys.isEmpty) return document;

    final mediaWithIds = [
      for (final media in tvMediaDraft) _withStableMediaId(media),
    ];
    final mediaByNumber = {
      for (final media in mediaWithIds)
        media.mediaNumber ?? media.position: media,
    };

    TvEpisodeMetadata updateEpisode(
      TvEpisodeMetadata episode, {
      int? seasonNumber,
    }) {
      final key = _episodeKey(episode, seasonNumber: seasonNumber);
      if (!_editedEpisodeKeys.contains(key)) return episode;
      final discNumber = _tvEpisodeDiscAssignments[key];
      final mediaId = discNumber == null ? null : mediaByNumber[discNumber]?.id;
      return episode.withMediaId(mediaId);
    }

    return document.copyWith(
      media: mediaWithIds,
      episodes: [
        for (final episode in document.episodes)
          updateEpisode(
            episode,
            seasonNumber: _seasonNumberForEpisode(document, episode),
          ),
      ],
      seasons: [
        for (final season in document.seasons)
          TvSeasonMetadata(
            id: season.id,
            seasonNumber: season.seasonNumber,
            title: season.title,
            description: season.description,
            airDate: season.airDate,
            releaseDate: season.releaseDate,
            episodeCount: season.episodeCount,
            episodes: [
              for (final episode in season.episodes)
                updateEpisode(episode, seasonNumber: season.seasonNumber),
            ],
          ),
      ],
    );
  }

  int? _seasonNumberForEpisode(TvMetadata document, TvEpisodeMetadata target) {
    if (target.seasonNumber != null) return target.seasonNumber;
    for (final season in document.seasonsWithEpisodes) {
      for (final episode in season.episodes) {
        final sameEpisode = target.id != null && episode.id != null
            ? target.id == episode.id
            : target.episodeNumber == episode.episodeNumber &&
                target.position == episode.position;
        if (sameEpisode &&
            _editedEpisodeKeys.contains(
              _episodeKey(episode, seasonNumber: season.seasonNumber),
            )) {
          return season.seasonNumber;
        }
      }
    }
    return null;
  }

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
          id: _fallbackMediaId(position, position),
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

  TvMediaMetadata _withStableMediaId(TvMediaMetadata media) =>
      media.id == null || media.id!.isEmpty
          ? media.withId(_fallbackMediaId(
              media.mediaNumber ?? media.position,
              media.position,
            ))
          : media;

  String _fallbackMediaId(int number, int position) =>
      'tv-media-$number-$position';

  String _episodeKey(TvEpisodeMetadata episode, {int? seasonNumber}) => episode
                  .id !=
              null &&
          episode.id!.isNotEmpty
      ? 'id:${episode.id}'
      : '${episode.seasonNumber ?? seasonNumber ?? 0}:${episode.episodeNumber ?? episode.position}';
}
