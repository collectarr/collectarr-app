import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';

/// Projects contained TV seasons and episodes into generic renderer nodes.
///
/// The renderer remains kind-agnostic; TV labels and identifiers stay here.
final class TvHierarchyMapper {
  const TvHierarchyMapper._();

  static List<LibraryHierarchyNode> toLibraryNodes(
    Iterable<TvSeasonMetadata> seasons,
  ) {
    return [
      for (var index = 0; index < seasons.length; index++)
        _seasonNode(seasons.elementAt(index), index + 1),
    ];
  }

  static LibraryHierarchyNode _seasonNode(
    TvSeasonMetadata season,
    int number,
  ) {
    final seasonNumber = season.seasonNumber;
    final seasonId = season.id ?? 'tv:season:$seasonNumber';
    final children = [
      for (var index = 0; index < season.episodes.length; index++)
        _episodeNode(season.episodes[index], seasonId, seasonNumber, index + 1),
    ];
    final episodeCount = season.episodeCount ?? children.length;
    return LibraryHierarchyNode(
      id: seasonId,
      label:
          season.title ?? 'Season ${seasonNumber == 0 ? number : seasonNumber}',
      secondaryLabel: '$episodeCount episodes',
      level: children.isEmpty
          ? LibraryHierarchyLevel.leaf
          : LibraryHierarchyLevel.container,
      totalCount: episodeCount,
      children: children,
      extras: {
        'kind': 'tv_season',
        'seasonNumber': seasonNumber,
        if (season.airDate?.isoString case final airDate?) 'airDate': airDate,
      },
    );
  }

  static LibraryHierarchyNode _episodeNode(
    TvEpisodeMetadata episode,
    String seasonId,
    int seasonNumber,
    int fallbackNumber,
  ) {
    final episodeNumber = episode.episodeNumber ?? fallbackNumber;
    final episodeId = episode.id ?? '$seasonId:episode:$episodeNumber';
    final details = <String>[];
    if (episode.runtimeMinutes != null) {
      details.add('${episode.runtimeMinutes} min');
    }
    if (episode.airDate?.year case final year?) {
      details.add(year.toString());
    }
    return LibraryHierarchyNode(
      id: episodeId,
      label: episode.episodeTitle ??
          episode.title ??
          'Episode ${_numberLabel(episodeNumber)}',
      secondaryLabel: details.isEmpty ? null : details.join(' · '),
      level: LibraryHierarchyLevel.leaf,
      extras: {
        'kind': 'tv_episode',
        'seasonId': seasonId,
        'seasonNumber': episode.seasonNumber ?? seasonNumber,
        'episodeNumber': episodeNumber,
        if (episode.airDate?.isoString case final airDate?) 'airDate': airDate,
        if (episode.runtimeMinutes != null)
          'runtimeMinutes': episode.runtimeMinutes,
      },
    );
  }

  static String _numberLabel(int number) => number.toString();
}
