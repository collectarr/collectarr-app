import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';
import 'music_album.dart';

import 'music_medium.dart';
import 'music_release.dart';
import 'music_track.dart';

/// Projects Music's release -> medium -> track graph into renderer nodes.
final class MusicHierarchyMapper {
  const MusicHierarchyMapper._();

  /// Builds display-only disc groups from the album's contained track values.
  /// The synthetic node keys are UI grouping keys, not catalog identities.
  static List<LibraryHierarchyNode> toAlbumLibraryNodes(MusicAlbum album) {
    if (album.tracks.isEmpty) return const <LibraryHierarchyNode>[];
    final tracksByDisc = <int, List<MusicAlbumTrack>>{};
    for (final track in album.tracks) {
      tracksByDisc.putIfAbsent(track.discNumber, () => []).add(track);
    }
    final discTitles = {
      for (final value in album.discTitles) value.discNumber: value.title,
    };
    return [
      for (final discNumber in (tracksByDisc.keys.toList()..sort()))
        LibraryHierarchyNode(
          id: 'album:${album.id.value}:disc:$discNumber',
          label: discTitles[discNumber]?.trim().isNotEmpty == true
              ? discTitles[discNumber]!.trim()
              : 'Disc $discNumber',
          secondaryLabel: '${tracksByDisc[discNumber]!.length} tracks',
          level: LibraryHierarchyLevel.container,
          imageUrl: album.coverImageUrl,
          totalCount: tracksByDisc[discNumber]!.length,
          children: [
            for (final track in (tracksByDisc[discNumber]!
              ..sort((a, b) => a.position.compareTo(b.position))))
              LibraryHierarchyNode(
                id: 'album:${album.id.value}:disc:${track.discNumber}:track:${track.position}',
                label: '${track.position}. ${track.title}',
                secondaryLabel: track.durationMs == null
                    ? track.artist
                    : _durationLabel(track.durationMs! ~/ 1000),
                level: LibraryHierarchyLevel.leaf,
                imageUrl: album.coverImageUrl,
                extras: {
                  'kind': 'music_track',
                  'albumId': album.id.value,
                  'discNumber': track.discNumber,
                  'position': track.position,
                  if (track.artist != null) 'artist': track.artist,
                  if (track.durationMs != null) 'durationMs': track.durationMs,
                },
              ),
          ],
          extras: {
            'kind': 'music_disc_group',
            'albumId': album.id.value,
            'discNumber': discNumber,
          },
        ),
    ];
  }

  static List<LibraryHierarchyNode> toLibraryNodes(MusicRelease release) {
    final mediums = release.mediums;
    if (mediums.isNotEmpty) {
      return [
        for (var index = 0; index < mediums.length; index++)
          _mediumNode(release, mediums[index], index + 1),
      ];
    }
    if (release.tracks.isEmpty) return const <LibraryHierarchyNode>[];
    return [
      LibraryHierarchyNode(
        id: '${release.id.value}:tracks',
        label: 'Tracks',
        secondaryLabel: '${release.trackCount} tracks',
        level: LibraryHierarchyLevel.container,
        imageUrl: release.coverImageUrl,
        totalCount: release.tracks.length,
        children: [
          for (var index = 0; index < release.tracks.length; index++)
            _trackNode(release, release.tracks[index], index + 1),
        ],
        extras: {
          'kind': 'music_tracks',
          'releaseId': release.id.value,
        },
      ),
    ];
  }

  static LibraryHierarchyNode _mediumNode(
    MusicRelease release,
    MusicMedium medium,
    int fallbackNumber,
  ) {
    final number =
        medium.mediumNumber > 0 ? medium.mediumNumber : fallbackNumber;
    final tracks = medium.tracks;
    final details = <String>[];
    if (medium.mediumType?.trim().isNotEmpty == true) {
      details.add(medium.mediumType!.trim());
    }
    if (tracks.isNotEmpty) details.add('${tracks.length} tracks');
    return LibraryHierarchyNode(
      id: medium.id.value.isEmpty
          ? '${release.id.value}:medium:$number'
          : medium.id.value,
      label: medium.title?.trim().isNotEmpty == true
          ? medium.title!.trim()
          : 'Disc $number',
      secondaryLabel: details.isEmpty ? null : details.join(' / '),
      level: tracks.isEmpty
          ? LibraryHierarchyLevel.leaf
          : LibraryHierarchyLevel.container,
      imageUrl: release.coverImageUrl,
      totalCount: tracks.isEmpty ? null : tracks.length,
      children: [
        for (var index = 0; index < tracks.length; index++)
          _trackNode(release, tracks[index], index + 1),
      ],
      extras: {
        'kind': 'music_medium',
        'releaseId': release.id.value,
        'mediumId': medium.id.value,
        'mediumNumber': number,
        if (medium.mediumType != null) 'mediumType': medium.mediumType,
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
    if (track.durationMs != null) {
      details.add(_durationLabel(track.durationMs! ~/ 1000));
    }
    return LibraryHierarchyNode(
      id: track.id.value.isEmpty
          ? '${release.id.value}:track:$position'
          : track.id.value,
      label: '$position. ${track.title}',
      secondaryLabel: details.isEmpty ? null : details.join(' / '),
      level: LibraryHierarchyLevel.leaf,
      imageUrl: release.coverImageUrl,
      extras: {
        'kind': 'music_track',
        'releaseId': release.id.value,
        'mediumId': track.mediumId.value,
        'trackId': track.id.value,
        'position': position,
        if (track.durationMs != null) 'durationMs': track.durationMs,
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
