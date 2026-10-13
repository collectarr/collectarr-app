import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';

import 'anime_metadata.dart';
import 'anime_metadata_children.dart';

/// Projects contained Anime episode values for hierarchy and search views.
final class AnimeHierarchyMapper {
  const AnimeHierarchyMapper._();

  static List<LibraryHierarchyNode> fromCatalogItemJson(
    Map<String, dynamic> item,
  ) {
    final id = item['id']?.toString().trim();
    if (id == null || id.isEmpty) {
      throw const FormatException('Anime Catalog Item is missing its id');
    }
    return fromMetadata(
      catalogItemId: id,
      metadata: AnimeMetadata.fromJson(item),
    );
  }

  static List<LibraryHierarchyNode> fromMetadata({
    required String catalogItemId,
    required AnimeMetadata metadata,
  }) {
    final episodesByIdentity = <String, AnimeEpisodeMetadata>{};
    for (final episode in [
      ...metadata.episodes,
      for (final season in metadata.seasons) ...season.episodes,
    ]) {
      final identity = episode.id ??
          '${episode.seasonNumber ?? 0}:${episode.episodeNumber ?? episode.position}';
      episodesByIdentity.putIfAbsent(identity, () => episode);
    }
    if (episodesByIdentity.isEmpty) return const <LibraryHierarchyNode>[];

    final episodes = episodesByIdentity.values.toList()
      ..sort((left, right) {
        final seasonOrder =
            (left.seasonNumber ?? 0).compareTo(right.seasonNumber ?? 0);
        if (seasonOrder != 0) return seasonOrder;
        final numberOrder = (left.episodeNumber ?? left.position)
            .compareTo(right.episodeNumber ?? right.position);
        return numberOrder != 0
            ? numberOrder
            : left.position.compareTo(right.position);
      });
    final children = [
      for (var index = 0; index < episodes.length; index++)
        _episodeNode(catalogItemId, episodes[index], index + 1),
    ];
    return [
      LibraryHierarchyNode(
        id: '$catalogItemId:episodes',
        label: 'Episodes',
        secondaryLabel: '${children.length} episodes',
        level: LibraryHierarchyLevel.container,
        imageUrl: metadata.thumbnailImageUrl ?? metadata.coverImageUrl,
        totalCount: children.length,
        children: children,
        extras: {
          'kind': 'anime_episodes',
          'catalogItemId': catalogItemId,
        },
      ),
    ];
  }

  static LibraryHierarchyNode _episodeNode(
    String catalogItemId,
    AnimeEpisodeMetadata episode,
    int fallbackNumber,
  ) {
    final episodeNumber = episode.episodeNumber ?? fallbackNumber;
    final label = episode.episodeTitle ?? episode.title;
    final details = <String>[];
    if (episode.runtimeMinutes != null) {
      details.add('${episode.runtimeMinutes} min');
    }
    if (episode.airDate?.year case final year?) details.add(year.toString());
    return LibraryHierarchyNode(
      id: episode.id ??
          '$catalogItemId:episode:${episode.seasonNumber ?? 0}:$episodeNumber',
      label: label ?? 'Episode $episodeNumber',
      secondaryLabel: details.isEmpty ? null : details.join(' · '),
      level: LibraryHierarchyLevel.leaf,
      extras: {
        'kind': 'anime_episode',
        'catalogItemId': catalogItemId,
        'position': episode.position,
        if (episode.seasonNumber != null) 'seasonNumber': episode.seasonNumber,
        if (episode.episodeNumber != null)
          'episodeNumber': episode.episodeNumber,
        if (episode.airDate != null) 'airDate': episode.airDate!.toJson(),
        if (episode.runtimeMinutes != null)
          'runtimeMinutes': episode.runtimeMinutes,
      },
    );
  }
}
