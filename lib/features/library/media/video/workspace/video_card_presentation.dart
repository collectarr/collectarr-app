import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';
import 'package:flutter/material.dart';

/// Builds the [LibraryCardPresentation] for a video workspace entry (movies, TV,
/// anime, etc.).  The video-specific compact badges that were previously
/// hard-coded inside [LibraryWorkspaceCard] are now expressed here.
LibraryCardPresentation buildVideoCardPresentation(
  LibraryWorkspaceEntry entry, {
  required bool musicVertical,
}) {
  return LibraryCardPresentation(
    compactBadges: _videoCompactBadges(entry),
  );
}

List<LibraryCardBadge> _videoCompactBadges(LibraryWorkspaceEntry entry) {
  final video = entry.video;
  if (video == null) return const [];

  final badges = <LibraryCardBadge>[];
  final edition = resolveLibraryEntryReferenceRelease(entry).edition ??
      (entry.editions.isNotEmpty ? entry.editions.first : null);
  final format = entry.referenceFormatLabel?.trim() ??
      edition?.format?.trim() ??
      edition?.physicalFormatLabel?.trim();
  final region = edition?.region?.trim() ?? entry.country?.trim();
  final hdr = video.color?.trim();
  final screenRatio = video.screenRatio?.trim();
  final audio = video.audioTracks?.trim();
  final subtitles = video.subtitles?.trim();
  final layers = video.layers?.trim();
  final trailerCount =
      entry.trailerUrls.where((link) => link.isTrailerLink).length;

  if (format != null && format.isNotEmpty) {
    badges.add(LibraryCardBadge(icon: Icons.album_outlined, label: format));
  }
  if (region != null && region.isNotEmpty) {
    badges.add(LibraryCardBadge(icon: Icons.public_outlined, label: region));
  }
  if (hdr != null && hdr.isNotEmpty) {
    badges.add(LibraryCardBadge(icon: Icons.hdr_on_outlined, label: hdr));
  }
  if (screenRatio != null && screenRatio.isNotEmpty) {
    badges.add(
      LibraryCardBadge(icon: Icons.aspect_ratio_outlined, label: screenRatio),
    );
  }
  if (audio != null && audio.isNotEmpty) {
    badges.add(LibraryCardBadge(icon: Icons.volume_up_outlined, label: audio));
  }
  if (subtitles != null && subtitles.isNotEmpty) {
    badges.add(
      LibraryCardBadge(
        icon: Icons.closed_caption_outlined,
        label: subtitles,
      ),
    );
  }
  if (layers != null && layers.isNotEmpty) {
    badges.add(LibraryCardBadge(icon: Icons.layers_outlined, label: layers));
  }
  if (trailerCount > 0) {
    badges.add(
      LibraryCardBadge(
        icon: Icons.ondemand_video_outlined,
        label: trailerCount == 1 ? 'Trailer' : '$trailerCount trailers',
      ),
    );
  }
  return badges;
}
