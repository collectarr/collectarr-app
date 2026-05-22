import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_media_presentation_builder.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_media_sections.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter/material.dart';

class MusicLibraryMediaPresentationBuilder
    extends DefaultLibraryMediaPresentationBuilder {
  const MusicLibraryMediaPresentationBuilder();

  @override
  LibraryMetadataPresentation buildMetadataPresentation({
    required String singularLabel,
    required LibraryMediaFieldLabels labels,
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
            labels.variant,
            entry.variant!,
            onTap: tapFor(entry.variant),
          ),
        if (entry.barcode != null)
          LibraryInspectorFactData(labels.barcode, entry.barcode!),
      ],
      contextFacts: [
        if (entry.publisher != null)
          LibraryInspectorFactData(
            labels.publisher,
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