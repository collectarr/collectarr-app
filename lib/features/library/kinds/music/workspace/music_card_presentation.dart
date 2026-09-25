import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_relations.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';
import 'package:flutter/material.dart';

/// Builds kind-owned values for the shared workspace card renderer.
LibraryCardPresentation buildMusicCardPresentation(
  LibraryProjectionView item, {
  required bool coverFocused,
}) {
  final music = item.dto is MusicWorkspaceProjection
      ? item.dto as MusicWorkspaceProjection
      : null;
  final tracks = musicCardTrackCount(item);
  final duration = musicCardDuration(item);

  return LibraryCardPresentation(
    releaseDate: music?.releaseDate,
    format: music?.format,
    contextFacts: [
      musicCardArtist(item),
      music?.publisher,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).toList(),
    compactBadges: [
      if (tracks != null)
        LibraryCardBadge(
          icon: Icons.music_note_outlined,
          label: '$tracks tracks',
        ),
      if (duration != null)
        LibraryCardBadge(
          icon: Icons.schedule,
          label: duration,
        ),
    ],
  );
}

/// Returns the primary artist name for a music item.
String? musicCardArtist(LibraryProjectionView item) {
  final group = _musicGroup(item);
  final groupArtist = group?.artist?.trim();
  if (groupArtist != null && groupArtist.isNotEmpty) return groupArtist;
  final creators = group?.primaryRelease?.contributions ??
      const <MusicReleaseContribution>[];
  for (final creator in creators) {
    final rawName = (creator.displayName ?? '').trim();
    if (rawName.isEmpty) continue;
    final role = creator.role.toLowerCase();
    if (role.contains('artist') ||
        role.contains('performer') ||
        role.contains('musician') ||
        role.contains('band')) {
      return rawName;
    }
  }
  return 'Unknown artist';
}

/// Returns a formatted duration string for the album.
String? musicCardDuration(LibraryProjectionView item) {
  final runtimeFact = _metadataFactValue(
    _metadataPresentationForEntry(item),
    'Runtime',
  );
  if (runtimeFact != null && runtimeFact.isNotEmpty) {
    return runtimeFact;
  }
  final totalDurationMs = _musicGroup(item)?.tracks.fold<int>(
        0,
        (total, track) => total + (track.track.durationMs ?? 0),
      );
  final totalSeconds = totalDurationMs == null || totalDurationMs == 0
      ? null
      : (totalDurationMs / 1000).round();
  if (totalSeconds == null || totalSeconds <= 0) {
    return null;
  }
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

/// Returns the track count for the album.
int? musicCardTrackCount(LibraryProjectionView item) {
  return _musicGroup(item)?.trackCount ??
      int.tryParse(
        _metadataFactValue(
              _metadataPresentationForEntry(item),
              'Tracks',
            ) ??
            '',
      );
}

MusicReleaseGroup? _musicGroup(LibraryProjectionView item) {
  final catalog = item.source.catalogData;
  return catalog is MusicWorkspaceCatalogData ? catalog.music : null;
}

LibraryMetadataPresentation? _metadataPresentationForEntry(
  LibraryProjectionView item,
) {
  final registration = defaultLibraryKindRegistry.tryGet(item.source.mediaKind);
  if (registration == null) return null;
  return libraryPresentationForKind(registration.kind)
      .builder
      .buildMetadataPresentation(
        singularLabel: registration.identity.singularLabel,
        item: item,
        includeIdentityFacts: true,
        tapFor: (_) => null,
      );
}

String? _metadataFactValue(
  LibraryMetadataPresentation? presentation,
  String label,
) {
  if (presentation == null) return null;
  for (final fact in presentation.allFacts) {
    if (fact.label == label) {
      final value = fact.value.trim();
      if (value.isNotEmpty && value != '-') {
        return value;
      }
    }
  }
  return null;
}
