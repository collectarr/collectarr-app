import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';

import 'music_media.dart';
import 'music_release.dart';
import 'music_track.dart';

/// Projects Music's release -> media -> track graph into renderer nodes.
final class MusicHierarchyMapper {
  const MusicHierarchyMapper._();

  static List<LibraryHierarchyNode> toLibraryNodes(MusicRelease release) {
    final media = release.media;
    if (media.isNotEmpty) {
      return [
        for (var index = 0; index < media.length; index++)
          _mediaNode(release, media[index], index + 1),
      ];
    }
    if (release.tracks.isEmpty) return const <LibraryHierarchyNode>[];
    return [
      LibraryHierarchyNode(
        id: '${release.id.value}:tracks',
        label: 'Tracks',
        secondaryLabel: '${release.tracks.length} tracks',
        level: LibraryHierarchyLevel.container,
        imageUrl: release.coverImageUrl,
        totalCount: release.tracks.length,
        children: [
          for (var index = 0; index < release.tracks.length; index++)
            _trackNode(release, release.tracks[index], index + 1),
        ],
        metadata: {
          'kind': 'music_tracks',
          'releaseId': release.id.value,
        },
      ),
    ];
  }

  static LibraryHierarchyNode _mediaNode(
    MusicRelease release,
    MusicMedia media,
    int fallbackNumber,
  ) {
    final number = media.mediaNumber > 0 ? media.mediaNumber : fallbackNumber;
    final tracks = media.tracks;
    final details = <String>[];
    if (media.mediaType?.trim().isNotEmpty == true) {
      details.add(media.mediaType!.trim());
    }
    if (tracks.isNotEmpty) details.add('${tracks.length} tracks');
    return LibraryHierarchyNode(
      id: media.id.value.isEmpty
          ? '${release.id.value}:media:$number'
          : media.id.value,
      label: media.title?.trim().isNotEmpty == true
          ? media.title!.trim()
          : 'Disc $number',
      secondaryLabel: details.isEmpty ? null : details.join(' Â· '),
      level: tracks.isEmpty
          ? LibraryHierarchyLevel.leaf
          : LibraryHierarchyLevel.container,
      imageUrl: release.coverImageUrl,
      totalCount: tracks.isEmpty ? null : tracks.length,
      children: [
        for (var index = 0; index < tracks.length; index++)
          _trackNode(release, tracks[index], index + 1),
      ],
      metadata: {
        'kind': 'music_media',
        'releaseId': release.id.value,
        'mediaId': media.id.value,
        'mediaNumber': number,
        if (media.mediaType != null) 'mediaType': media.mediaType,
      },
    );
  }

  static LibraryHierarchyNode _trackNode(
    MusicRelease release,
    MusicTrack track,
    int fallbackPosition,
  ) {
    final position = track.position.trim().isEmpty
        ? fallbackPosition.toString()
        : track.position.trim();
    final details = <String>[];
    if (track.durationSeconds != null) {
      details.add(_durationLabel(track.durationSeconds!));
    }
    if (track.artist?.trim().isNotEmpty == true) {
      details.add(track.artist!.trim());
    }
    return LibraryHierarchyNode(
      id: track.id.value.isEmpty
          ? '${release.id.value}:track:$position'
          : track.id.value,
      label: '$position. ${track.title}',
      secondaryLabel: details.isEmpty ? null : details.join(' Â· '),
      level: LibraryHierarchyLevel.leaf,
      imageUrl: release.coverImageUrl,
      metadata: {
        'kind': 'music_track',
        'releaseId': release.id.value,
        'mediaId': track.mediaId.value,
        'trackId': track.id.value,
        'position': position,
        if (track.durationMs != null) 'durationMs': track.durationMs,
        if (track.artist != null) 'artist': track.artist,
        if (track.composition != null) 'composition': track.composition,
        if (track.instrument != null) 'instrument': track.instrument,
      },
    );
  }

  static String _durationLabel(int seconds) {
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    return '$minutes:${remainder.toString().padLeft(2, '0')}';
  }
}
