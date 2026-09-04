import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';

/// Projects the TV-owned season/episode graph into the generic renderer node.
///
/// The renderer remains kind-agnostic; all TV semantics and labels are kept in
/// this mapper at the TV boundary.
final class TvHierarchyMapper {
  const TvHierarchyMapper._();

  static List<LibraryHierarchyNode> toLibraryNodes(
    Iterable<TvSeason> seasons,
  ) {
    return [
      for (var index = 0; index < seasons.length; index++)
        _seasonNode(seasons.elementAt(index), index + 1),
    ];
  }

  static LibraryHierarchyNode _seasonNode(TvSeason season, int number) {
    final seasonId = season.id.isEmpty
        ? '${season.seriesId}:season:${season.seasonNumber ?? number}'
        : season.id;
    final children = [
      for (var index = 0; index < season.episodes.length; index++)
        _episodeNode(season.episodes[index], seasonId, index + 1),
    ];
    final episodeCount = season.episodeCount ?? children.length;
    final seasonNumber = season.seasonNumber ?? number;
    return LibraryHierarchyNode(
      id: seasonId,
      label: season.title ?? 'Season $seasonNumber',
      secondaryLabel: '$episodeCount episodes',
      level: children.isEmpty
          ? LibraryHierarchyLevel.leaf
          : LibraryHierarchyLevel.container,
      imageUrl: season.coverImageUrl,
      totalCount: episodeCount,
      children: children,
      metadata: {
        'kind': 'tv_season',
        'seriesId': season.seriesId,
        'seasonNumber': seasonNumber,
        if (season.airDate != null)
          'airDate': season.airDate!.toIso8601String(),
      },
    );
  }

  static LibraryHierarchyNode _episodeNode(
    TvEpisode episode,
    String seasonId,
    int fallbackNumber,
  ) {
    final episodeId = episode.id.isEmpty
        ? '$seasonId:episode:${episode.episodeNumber ?? fallbackNumber}'
        : episode.id;
    final episodeNumber = episode.episodeNumber ?? fallbackNumber.toDouble();
    final details = <String>[];
    if (episode.runtimeMinutes != null) {
      details.add('${episode.runtimeMinutes} min');
    }
    if (episode.airDate != null) {
      details.add(episode.airDate!.year.toString());
    }
    return LibraryHierarchyNode(
      id: episodeId,
      label: episode.title ?? 'Episode ${_numberLabel(episodeNumber)}',
      secondaryLabel: details.isEmpty ? null : details.join(' · '),
      level: LibraryHierarchyLevel.leaf,
      imageUrl: episode.coverImageUrl,
      metadata: {
        'kind': 'tv_episode',
        'seasonId': seasonId,
        'episodeNumber': episodeNumber,
        if (episode.airDate != null)
          'airDate': episode.airDate!.toIso8601String(),
        if (episode.runtimeMinutes != null)
          'runtimeMinutes': episode.runtimeMinutes,
      },
    );
  }

  static String _numberLabel(double number) {
    return number == number.truncateToDouble()
        ? number.toInt().toString()
        : number.toString();
  }
}
