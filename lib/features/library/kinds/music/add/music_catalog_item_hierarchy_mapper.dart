import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';

/// Projects a Music catalog item and its contained discs/tracks into the
/// shared hierarchy UI.
final class MusicCatalogItemHierarchyMapper {
  const MusicCatalogItemHierarchyMapper._();

  static List<LibraryHierarchyNode> toLibraryNodes(MusicAlbum item) {
    final discs = [...item.discs]
      ..sort((left, right) => left.discNumber.compareTo(right.discNumber));
    return [for (final disc in discs) _discNode(item, disc)];
  }

  static LibraryHierarchyNode _discNode(MusicAlbum item, MusicDisc disc) {
    final tracks = [...disc.tracks]..sort((left, right) {
        final order =
            (left.positionOrder ?? 0).compareTo(right.positionOrder ?? 0);
        return order != 0 ? order : left.position.compareTo(right.position);
      });
    final details = tracks.isEmpty
        ? null
        : '${tracks.length} ${tracks.length == 1 ? 'track' : 'tracks'}';
    final title = disc.title?.trim();

    return LibraryHierarchyNode(
      id: disc.id.value,
      label:
          title == null || title.isEmpty ? 'Disc ${disc.discNumber}' : title,
      secondaryLabel: details,
      level: tracks.isEmpty
          ? LibraryHierarchyLevel.leaf
          : LibraryHierarchyLevel.container,
      imageUrl: item.coverImageUrl,
      totalCount: tracks.isEmpty ? null : tracks.length,
      children: [for (final track in tracks) _trackNode(item, disc, track)],
      extras: {
        'kind': 'music_item_disc',
        'catalogItemId': item.id.value,
        'discId': disc.id.value,
        'discNumber': disc.discNumber,
      },
    );
  }

  static LibraryHierarchyNode _trackNode(
    MusicAlbum item,
    MusicDisc disc,
    MusicTrack track,
  ) {
    final position = track.position.trim();
    final details = <String>[];
    if (track.artist?.trim().isNotEmpty == true) {
      details.add(track.artist!.trim());
    }
    if (track.durationMs != null) {
      details.add(_durationLabel(track.durationMs! ~/ 1000));
    }

    return LibraryHierarchyNode(
      id: track.id.value,
      label:
          '${position.isEmpty ? track.positionOrder ?? 0 : position}. ${track.title}',
      secondaryLabel: details.isEmpty ? null : details.join(' / '),
      imageUrl: item.coverImageUrl,
      extras: {
        'kind': 'music_item_track',
        'catalogItemId': item.id.value,
        'discId': disc.id.value,
        'trackId': track.id.value,
        'position': position,
        if (track.durationMs != null) 'durationMs': track.durationMs,
      },
    );
  }

  static String _durationLabel(int seconds) {
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    return '$minutes:${remainder.toString().padLeft(2, '0')}';
  }
}
