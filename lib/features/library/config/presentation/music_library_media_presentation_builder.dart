import 'dart:math' as math;

import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_media_presentation_builder.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_media_sections.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MusicLibraryMediaPresentationBuilder
    extends DefaultLibraryMediaPresentationBuilder {
  const MusicLibraryMediaPresentationBuilder();

  @override
  Widget? buildAddPreviewPane({
    required BuildContext context,
    required Color accent,
    required String singularLabel,
    required MediaEditFields mediaFields,
    required ReleaseEditFields releaseFields,
    required LibraryMediaPreviewLabels previewLabels,
    required LibraryMetadataItem? item,
    required ProviderCandidate? candidate,
    required AdminProviderPreview? preview,
    required bool isFetchingPreview,
    required String providerLabel,
  }) {
    final albumTitle = item?.title ?? candidate?.title ?? preview?.title;
    if (albumTitle == null || albumTitle.trim().isEmpty) {
      return null;
    }
    final artist = item?.series?.seriesTitle ??
        preview?.series?.seriesTitle ??
        candidate?.series?.seriesTitle;
    final releaseDetails = item?.music ?? preview?.music;
    final coverUrl = item?.displayCoverUrl ?? preview?.coverImageUrl ?? candidate?.imageUrl;
    final genres = item?.genres ?? preview?.genres ?? const <String>[];
    final albumSubtitle = _musicAlbumSubtitle(item: item, preview: preview);
    final releaseLine = _musicReleaseLine(
      albumTitle: albumTitle,
      item: item,
      preview: preview,
    );
    final labelCatalogLine = _musicLabelCatalogLine(
      item: item,
      preview: preview,
      candidate: candidate,
    );
    final genreLine = genres
        .map((genre) => genre.trim())
        .where((genre) => genre.isNotEmpty)
        .join(', ');
    final subLine = _musicSupportingLine(
      item: item,
      preview: preview,
      candidate: candidate,
    );
    final tracks = _musicPreviewTracks(item: item, preview: preview);
    return _MusicAddPreviewPane(
      accent: accent,
      artist: artist,
      albumTitle: albumTitle,
      albumSubtitle: albumSubtitle,
      releaseLine: releaseLine,
      labelCatalogLine: labelCatalogLine,
      genreLine: genreLine.isEmpty ? null : genreLine,
      subLine: subLine,
      coverUrl: coverUrl,
      itemNumber: item?.itemNumber ?? preview?.itemNumber ?? candidate?.issueNumber,
      tracks: tracks,
      trackCount: releaseDetails?.trackCount ?? tracks.length,
      isFetchingPreview: isFetchingPreview,
      hasCoreMetadata: item != null,
      providerLabel: item == null ? providerLabel : singularLabel,
    );
  }

  @override
  LibraryMetadataPresentation buildMetadataPresentation({
    required String singularLabel,
    required MediaEditFields mediaFields,
    required ReleaseEditFields releaseFields,
    required LibraryWorkspaceEntry entry,
    required bool includeIdentityFacts,
    required LibraryMetadataFactTapResolver tapFor,
  }) {
    final music = entry.music;
    final series = entry.series;
    return LibraryMetadataPresentation(
      identityFacts: [
        if (includeIdentityFacts) ...[
          LibraryInspectorFactData('Kind', singularLabel),
          LibraryInspectorFactData('ID', entry.id),
          LibraryInspectorFactData('Title', entry.title),
        ],
        if (series?.seriesTitle != null)
          LibraryInspectorFactData(
            'Artist',
            series!.seriesTitle!,
            onTap: tapFor(series.seriesTitle),
          ),
        if (series?.volumeName != null || series?.volumeNumber != null)
          LibraryInspectorFactData(
            'Disc',
            series?.volumeName ?? 'Disc ${series?.volumeNumber}',
          ),
        if (entry.variant != null)
          LibraryInspectorFactData(
            releaseFields.variantLabel,
            entry.variant!,
            onTap: tapFor(entry.variant),
          ),
        if (entry.barcode != null)
          LibraryInspectorFactData(releaseFields.barcodeLabel, entry.barcode!),
      ],
      contextFacts: [
        if (entry.publisher != null)
          LibraryInspectorFactData(
            mediaFields.publisherLabel,
            entry.publisher!,
            onTap: tapFor(entry.publisher),
          ),
        LibraryInspectorFactData(
          'Released',
          genericLibraryDash(
            formatPresentationNullableDate(entry.releaseDate) ??
                entry.releaseYear?.toString(),
          ),
        ),
        if (music?.trackCount != null)
          LibraryInspectorFactData('Tracks', music!.trackCount.toString()),
        if (music?.catalogNumber != null)
          LibraryInspectorFactData('Catalog No.', music!.catalogNumber!),
        if (music?.releaseStatus != null)
          LibraryInspectorFactData('Release Status', music!.releaseStatus!),
        if (entry.country != null)
          LibraryInspectorFactData('Country', entry.country!),
        if (entry.language != null)
          LibraryInspectorFactData('Language', entry.language!),
        LibraryInspectorFactData('Cover', entry.hasMissingCover ? 'Missing' : 'Ready'),
        LibraryInspectorFactData(
          'Metadata',
          entry.hasMissingMetadata ? 'Missing' : 'Ready',
        ),
      ],
      creators: entry.creators ?? const <Map<String, dynamic>>[],
      characters: entry.characters ?? const <String>[],
      storyArcs: entry.storyArcs ?? const <String>[],
      genres: entry.genres ?? const <String>[],
    );
  }

  @override
  List<Widget> buildInspectorSections({
    required BuildContext context,
    required LibraryWorkspaceEntry entry,
    required Color accent,
  }) {
    final sections = <Widget>[];
    final music = entry.music;
    if (music?.tracks case final tracks? when tracks.isNotEmpty) {
      sections.add(
        InspectorTrackList(
          tracks: tracks,
          trackCount: music?.trackCount,
          accent: accent,
          coverUrl: entry.displayCoverUrl,
          title: entry.title,
        ),
      );
    } else if (music?.trackCount != null) {
      sections.add(
        InspectorTrackListUnavailable(
          trackCount: music!.trackCount!,
          accent: accent,
        ),
      );
    }
    return sections;
  }
}

class _MusicAddPreviewPane extends StatelessWidget {
  const _MusicAddPreviewPane({
    required this.accent,
    required this.artist,
    required this.albumTitle,
    required this.albumSubtitle,
    required this.releaseLine,
    required this.labelCatalogLine,
    required this.genreLine,
    required this.subLine,
    required this.coverUrl,
    required this.itemNumber,
    required this.tracks,
    required this.trackCount,
    required this.isFetchingPreview,
    required this.hasCoreMetadata,
    required this.providerLabel,
  });

  final Color accent;
  final String? artist;
  final String albumTitle;
  final String? albumSubtitle;
  final String? releaseLine;
  final String? labelCatalogLine;
  final String? genreLine;
  final String? subLine;
  final String? coverUrl;
  final String? itemNumber;
  final List<_MusicPreviewTrackData> tracks;
  final int? trackCount;
  final bool isFetchingPreview;
  final bool hasCoreMetadata;
  final String providerLabel;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final totalDuration = _musicTotalDurationLabel(tracks);
    final headingCount = trackCount ?? tracks.length;
    final trackGroups = _groupTracksByDisc(tracks);
    final trackHeading = headingCount > 0
        ? totalDuration == null
            ? '$headingCount tracks'
            : '$headingCount tracks ($totalDuration)'
        : null;
    final headerChildren = <Widget>[
      if (artist != null && artist!.trim().isNotEmpty)
        Text(
          artist!,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: accent,
            fontSize: 24,
            fontWeight: FontWeight.w500,
            height: 1,
          ),
        ),
      if (artist != null && artist!.trim().isNotEmpty)
        const SizedBox(height: 2),
      Text(
        albumTitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: palette.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.15,
        ),
      ),
      if (albumSubtitle != null && albumSubtitle!.trim().isNotEmpty) ...[
        const SizedBox(height: 3),
        Text(
          albumSubtitle!,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: palette.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
      ],
      const SizedBox(height: 8),
      Divider(
        height: 1,
        thickness: 1,
        color: palette.divider.withValues(alpha: 0.86),
      ),
      const SizedBox(height: 10),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (releaseLine != null && releaseLine!.trim().isNotEmpty)
                  Text(
                    releaseLine!,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                if (genreLine != null && genreLine!.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    genreLine!,
                    style: TextStyle(
                      color: accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
                  ),
                ],
                if (subLine != null && subLine!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    subLine!,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              labelCatalogLine ?? providerLabel,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Divider(
        height: 1,
        thickness: 1,
        color: palette.divider.withValues(alpha: 0.86),
      ),
      const SizedBox(height: 12),
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.canvas,
            Color.alphaBlend(accent.withValues(alpha: 0.18), palette.canvas),
            palette.canvas,
          ],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, paneConstraints) {
          final compactHeight = paneConstraints.maxHeight < 320;
          if (compactHeight) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...headerChildren,
                  _buildCompactTrackSection(
                    context: context,
                    maxWidth: paneConstraints.maxWidth - 38,
                    trackHeading: trackHeading,
                  ),
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...headerChildren,
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final stacked = constraints.maxWidth < 560;
                      final coverImage = LibraryInteractiveCover(
                        title: albumTitle,
                        itemNumber: itemNumber,
                        imageUrl: coverUrl,
                        accentColor: accent,
                        borderRadius: 6,
                      );
                      final cover = SizedBox(
                        width: 300,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: coverImage,
                        ),
                      );
                      final stackedCoverSize = math.min(
                        180.0,
                        math.min(
                          constraints.maxWidth,
                          math.max(0.0, constraints.maxHeight - 96.0),
                        ),
                      );
                      final showStackedCover = stackedCoverSize >= 72;
                      final details = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (trackHeading != null)
                            Text(
                              trackHeading,
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          if (tracks.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Expanded(
                                child: ListView(
                                  children: [
                                    for (final group in trackGroups)
                                      ..._buildTrackGroupWidgets(group),
                                  ],
                              ),
                            ),
                          ] else
                            Expanded(
                              child: Center(
                                child: Text(
                                    _trackListPlaceholder(),
                                  style: TextStyle(
                                    color: palette.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      );
                      if (stacked) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: details),
                            if (showStackedCover) ...[
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: SizedBox.square(
                                  dimension: stackedCoverSize,
                                  child: coverImage,
                                ),
                              ),
                            ],
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: details),
                          const SizedBox(width: 20),
                          cover,
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompactTrackSection({
    required BuildContext context,
    required double maxWidth,
    required String? trackHeading,
  }) {
    final palette = appPalette(context);
    final stacked = maxWidth < 560;
    final coverSize = math.min(stacked ? 160.0 : 180.0, math.max(0.0, maxWidth));
    final showCover = coverSize >= 72;
    final trackGroups = _groupTracksByDisc(tracks);
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (trackHeading != null)
          Text(
            trackHeading,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        if (tracks.isNotEmpty) ...[
          const SizedBox(height: 4),
          for (final group in trackGroups) ..._buildTrackGroupWidgets(group),
        ] else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              _trackListPlaceholder(),
              style: TextStyle(
                color: palette.textMuted,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
    if (!showCover) {
      return details;
    }
    final cover = SizedBox.square(
      dimension: coverSize,
      child: LibraryInteractiveCover(
        title: albumTitle,
        itemNumber: itemNumber,
        imageUrl: coverUrl,
        accentColor: accent,
        borderRadius: 6,
      ),
    );
    if (stacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          details,
          const SizedBox(height: 12),
          cover,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: details),
        const SizedBox(width: 20),
        cover,
      ],
    );
  }

  List<Widget> _buildTrackGroupWidgets(_MusicTrackGroup group) {
    return [
      if (group.label != null) ...[
        Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 4),
          child: Text(
            group.label!,
            style: TextStyle(
              color: accent.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
      for (var index = 0; index < group.tracks.length; index++)
        _MusicAddPreviewTrackRow(
          index: index + 1,
          track: group.tracks[index],
          accent: accent,
        ),
    ];
  }

  String _trackListPlaceholder() {
    if (isFetchingPreview) {
      return 'Fetching track list...';
    }
    if (hasCoreMetadata && (trackCount ?? 0) > 0) {
      return 'Collectarr Core returned this release, but the cached track list is not available yet.';
    }
    return 'Track list unavailable for this release yet.';
  }
}

class _MusicAddPreviewTrackRow extends StatelessWidget {
  const _MusicAddPreviewTrackRow({
    required this.index,
    required this.track,
    required this.accent,
  });

  final int index;
  final _MusicPreviewTrackData track;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '${track.position ?? index}',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (track.durationLabel != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        track.durationLabel!,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MusicPreviewTrackData {
  const _MusicPreviewTrackData({
    required this.title,
    this.position,
    this.durationSeconds,
    this.discNumber,
  });

  final String title;
  final int? position;
  final int? durationSeconds;
  final int? discNumber;

  String? get durationLabel {
    final value = durationSeconds;
    if (value == null) {
      return null;
    }
    final hours = value ~/ 3600;
    final minutes = (value % 3600) ~/ 60;
    final seconds = value % 60;
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

String? _musicReleaseLine({
  required String albumTitle,
  required LibraryMetadataItem? item,
  required AdminProviderPreview? preview,
}) {
  final releaseYear = item?.releaseYear ??
      item?.releaseDate?.year ??
      preview?.releaseDate?.year ??
      preview?.series?.volumeStartYear;
  if (releaseYear == null) {
    return albumTitle;
  }
  return '$albumTitle ($releaseYear)';
}

String? _musicLabelCatalogLine({
  required LibraryMetadataItem? item,
  required AdminProviderPreview? preview,
  required ProviderCandidate? candidate,
}) {
  final parts = <String>[];
  final format = item?.variant ?? preview?.variantName ?? candidate?.variantName;
  if (format != null && format.trim().isNotEmpty) {
    parts.add(format.trim());
  }
  final catalogNumber = item?.music?.catalogNumber ?? preview?.music?.catalogNumber;
  if (catalogNumber != null && catalogNumber.trim().isNotEmpty) {
    parts.add(catalogNumber.trim());
  }
  final publisher = item?.publisher ?? preview?.publisher ?? candidate?.publisher;
  if (parts.isEmpty && publisher != null && publisher.trim().isNotEmpty) {
    return publisher.trim();
  }
  return parts.isEmpty ? null : parts.join('  ');
}

String? _musicSupportingLine({
  required LibraryMetadataItem? item,
  required AdminProviderPreview? preview,
  required ProviderCandidate? candidate,
}) {
  final values = <String>[];
  final publisher = item?.publisher ?? preview?.publisher ?? candidate?.publisher;
  if (publisher != null && publisher.trim().isNotEmpty) {
    values.add(publisher.trim());
  }
  final status = item?.music?.releaseStatus ?? preview?.music?.releaseStatus;
  if (status != null && status.trim().isNotEmpty) {
    values.add(status.trim());
  }
  return values.isEmpty ? null : values.join(' / ');
}

String? _musicAlbumSubtitle({
  required LibraryMetadataItem? item,
  required AdminProviderPreview? preview,
}) {
  final albumTitle = item?.title ?? preview?.title;
  final candidates = <String?>[
    item?.publishing?.subtitle,
    preview?.publishing?.subtitle,
    item?.series?.volumeName,
    preview?.series?.volumeName,
  ];
  for (final candidate in candidates) {
    final value = candidate?.trim();
    if (value == null || value.isEmpty) {
      continue;
    }
    if (albumTitle != null && value.toLowerCase() == albumTitle.trim().toLowerCase()) {
      continue;
    }
    return value;
  }
  final volumeNumber = item?.series?.volumeNumber ?? preview?.series?.volumeNumber;
  if (volumeNumber != null && volumeNumber > 1) {
    return 'Disc $volumeNumber';
  }
  return null;
}

List<_MusicPreviewTrackData> _musicPreviewTracks({
  required LibraryMetadataItem? item,
  required AdminProviderPreview? preview,
}) {
  final itemTracks = item?.music?.tracks;
  if (itemTracks != null && itemTracks.isNotEmpty) {
    return [
      for (final track in itemTracks)
        _MusicPreviewTrackData(
          title: track.title.trim().isEmpty ? 'Untitled track' : track.title,
          position: track.position,
          durationSeconds: track.durationSeconds,
          discNumber: track.discNumber,
        ),
    ];
  }
  final previewTracks = preview?.music?.tracks;
  if (previewTracks == null || previewTracks.isEmpty) {
    return const [];
  }
  return [
    for (final track in previewTracks)
      _MusicPreviewTrackData(
        title: track.title.trim().isEmpty ? 'Untitled track' : track.title,
        position: track.position,
        durationSeconds: track.durationSeconds,
        discNumber: track.discNumber,
      ),
  ];
}

List<_MusicTrackGroup> _groupTracksByDisc(List<_MusicPreviewTrackData> tracks) {
  if (tracks.isEmpty) {
    return const <_MusicTrackGroup>[];
  }
  final discNumbers = {
    for (final track in tracks)
      if (track.discNumber != null && track.discNumber! > 0) track.discNumber!,
  };
  if (discNumbers.length <= 1) {
    final singleDisc = discNumbers.isEmpty ? null : discNumbers.first;
    return [
      _MusicTrackGroup(
        label: singleDisc != null && singleDisc > 1 ? 'Disc $singleDisc' : null,
        tracks: tracks,
      ),
    ];
  }
  final groups = <int, List<_MusicPreviewTrackData>>{};
  for (final track in tracks) {
    final discNumber = track.discNumber ?? 1;
    groups.putIfAbsent(discNumber, () => <_MusicPreviewTrackData>[]).add(track);
  }
  final orderedDiscNumbers = groups.keys.toList()..sort();
  return [
    for (final discNumber in orderedDiscNumbers)
      _MusicTrackGroup(
        label: 'Disc $discNumber',
        tracks: groups[discNumber]!,
      ),
  ];
}

class _MusicTrackGroup {
  const _MusicTrackGroup({
    required this.label,
    required this.tracks,
  });

  final String? label;
  final List<_MusicPreviewTrackData> tracks;
}

String? _musicTotalDurationLabel(List<_MusicPreviewTrackData> tracks) {
  if (tracks.isEmpty) {
    return null;
  }
  var total = 0;
  var hasDuration = false;
  for (final track in tracks) {
    if (track.durationSeconds != null) {
      total += track.durationSeconds!;
      hasDuration = true;
    }
  }
  if (!hasDuration) {
    return null;
  }
  final hours = total ~/ 3600;
  final minutes = (total % 3600) ~/ 60;
  final seconds = total % 60;
  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}