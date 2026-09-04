import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';

import 'anime_episode.dart';
import 'anime_media.dart';

/// Projects the Anime-owned episode graph into generic renderer nodes.
final class AnimeHierarchyMapper {
  const AnimeHierarchyMapper._();

  static List<LibraryHierarchyNode> toLibraryNodes(AnimeMedia media) {
    if (media.episodes.isEmpty) return const <LibraryHierarchyNode>[];

    final children = [
      for (var index = 0; index < media.episodes.length; index++)
        _episodeNode(media.episodes[index], index + 1),
    ];
    return [
      LibraryHierarchyNode(
        id: '${media.id.value}:episodes',
        label: 'Episodes',
        secondaryLabel: '${children.length} episodes',
        level: LibraryHierarchyLevel.container,
        imageUrl: media.coverImageUrl,
        totalCount: children.length,
        children: children,
        metadata: {
          'kind': 'anime_episodes',
          'seriesId': media.id.value,
        },
      ),
    ];
  }

  static LibraryHierarchyNode _episodeNode(
    AnimeEpisode episode,
    int fallbackNumber,
  ) {
    final episodeNumber = episode.episodeNumber ?? fallbackNumber.toDouble();
    final details = <String>[];
    if (episode.runtimeMinutes != null) {
      details.add('${episode.runtimeMinutes} min');
    }
    if (episode.airDate != null) {
      details.add(episode.airDate!.year.toString());
    }
    return LibraryHierarchyNode(
      id: episode.id.value.isEmpty
          ? '${episode.seriesId.value}:episode:$episodeNumber'
          : episode.id.value,
      label: episode.title ?? 'Episode ${_numberLabel(episodeNumber)}',
      secondaryLabel: details.isEmpty ? null : details.join(' · '),
      level: LibraryHierarchyLevel.leaf,
      imageUrl: episode.coverImageUrl,
      metadata: {
        'kind': 'anime_episode',
        'seriesId': episode.seriesId.value,
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
