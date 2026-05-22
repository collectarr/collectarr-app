import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_media_presentation_builder.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/generic/library_display.dart';
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
    return LibraryMetadataPresentation(
      identityFacts: [
        if (includeIdentityFacts) ...[
          LibraryInspectorFactData('Kind', singularLabel),
          LibraryInspectorFactData('ID', entry.id),
          LibraryInspectorFactData('Title', entry.title),
        ],
        if (entry.seriesTitle != null)
          LibraryInspectorFactData(
            'Artist',
            entry.seriesTitle!,
            onTap: tapFor(entry.seriesTitle),
          ),
        if (entry.volumeName != null || entry.volumeNumber != null)
          LibraryInspectorFactData(
            'Disc',
            entry.volumeName ?? 'Disc ${entry.volumeNumber}',
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
        if (entry.trackCount != null)
          LibraryInspectorFactData('Tracks', entry.trackCount.toString()),
        if (entry.catalogNumber != null)
          LibraryInspectorFactData('Catalog No.', entry.catalogNumber!),
        if (entry.releaseStatus != null)
          LibraryInspectorFactData('Release Status', entry.releaseStatus!),
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
    if (entry.tracks != null && entry.tracks!.isNotEmpty) {
      sections.add(
        InspectorTrackList(
          tracks: entry.tracks!,
          trackCount: entry.trackCount,
          accent: accent,
          coverUrl: entry.displayCoverUrl,
          title: entry.title,
        ),
      );
    } else if (entry.trackCount != null) {
      sections.add(
        InspectorTrackListUnavailable(
          trackCount: entry.trackCount!,
          accent: accent,
        ),
      );
    }
    return sections;
  }
}