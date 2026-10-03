import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';

import 'anime_episode.dart';
import 'anime_media.dart';

/// Projects the Anime-entry episode graph into generic renderer nodes.
final class AnimeHierarchyMapper {
  const AnimeHierarchyMapper._();

  static List<LibraryHierarchyNode> toLibraryNodes(AnimeMedia media) {
    return _toLibraryNodes(
      id: media.id.value,
      coverImageUrl: media.coverImageUrl,
      episodes: media.episodes,
    );
  }

  static List<LibraryHierarchyNode> fromCatalogItemJson(
    Map<String, dynamic> item,
  ) {
    final id = item['id']?.toString().trim();
    if (id == null || id.isEmpty) {
      throw const FormatException('Anime Catalog Item is missing its id');
    }
    final rawEpisodes = item['episodes'];
    final episodes = <AnimeEpisode>[
      if (rawEpisodes is Iterable)
        for (final value in rawEpisodes)
          if (value is Map)
            AnimeEpisode.fromJson({
              ...Map<String, dynamic>.from(value),
              'series_id': id,
            }),
    ];
    return _toLibraryNodes(
      id: id,
      coverImageUrl: item['cover_image_url']?.toString(),
      episodes: episodes,
    );
  }

  static List<LibraryHierarchyNode> _toLibraryNodes({
    required String id,
    required String? coverImageUrl,
    required List<AnimeEpisode> episodes,
  }) {
    if (episodes.isEmpty) return const <LibraryHierarchyNode>[];

    final children = [
      for (var index = 0; index < episodes.length; index++)
        _episodeNode(episodes[index], index + 1),
    ];
    return [
      LibraryHierarchyNode(
        id: '$id:episodes',
        label: 'Episodes',
        secondaryLabel: '${children.length} episodes',
        level: LibraryHierarchyLevel.container,
        imageUrl: coverImageUrl,
        totalCount: children.length,
        children: children,
        extras: {
          'kind': 'anime_episodes',
          'seriesId': id,
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
      extras: {
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
