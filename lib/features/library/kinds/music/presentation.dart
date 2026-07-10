import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/music/presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_fields.dart';
import 'package:collectarr_app/features/library/shared/workspace_presentation_support.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace_entry_builder.dart';
import 'package:flutter/material.dart';

const musicMetadataLabels = LibraryMetadataLabels(
  identitySectionTitle: 'Album identity',
  contextSectionTitle: 'Album context',
  creditsSectionTitle: 'Contributors & Discovery',
  creators: 'Contributors',
  characters: 'Featured artists',
);

const musicLibraryMediaBuilder = MusicLibraryMediaPresentationBuilder(
  metadataLabels: musicMetadataLabels,
);

const musicPreviewLabels = LibraryMediaPreviewLabels(
  series: 'Artist',
  itemCount: 'Releases',
);

const musicStatsLabels = LibraryMediaStatsLabels(
  topSeries: 'Top Artists',
  topPublisher: 'Top Labels',
);

const musicLibraryGroupLabels = LibraryMediaGroupLabels(
  series: 'Artist',
  seriesPlural: 'Artists',
  unknownSeries: 'Unknown artist',
  publisher: 'Label',
  publisherPlural: 'Labels',
  unknownPublisher: 'Unknown label',
);

const musicLibraryBucketLabelOverrides = LibraryBucketLabelOverrides();

String musicLibraryBucketLabelBuilder(LibraryBucketingContext context) {
  return defaultLibraryBucketLabel(
    context,
    musicLibraryGroupLabels,
    musicLibraryBucketLabelOverrides,
  );
}

final musicLibraryMediaPresentation = LibraryMediaPresentation(
  searchFieldLabels: LibraryMediaSearchFieldLabels(
    queryHint: 'Enter album, artist, release, or label...',
    emptySearchMessage: 'Enter an album, artist, release, or label.',
    seriesHint: 'Artist...',
    numberHint: 'Album / Release...',
    publisherHint: 'Label...',
  ),
  filterLabels: LibraryMediaFilterLabels(
    series: 'Artist',
    anySeries: 'Any artist',
    publisher: 'Label',
    anyPublisher: 'Any label',
  ),
  groupLabels: musicLibraryGroupLabels,
  builder: musicLibraryMediaBuilder,
  workspaceEntryBuilder: buildMusicLibraryWorkspaceEntryFromShelf,
  releaseEntryBuilder: buildMusicLibraryReleaseEntry,
  bucketLabelBuilder: musicLibraryBucketLabelBuilder,
  previewLabels: musicPreviewLabels,
  statsLabels: musicStatsLabels,
  usesTrackListCard: true,
  referenceLabels: LibraryReferenceLabels(itemScope: 'Album'),
  compactBucketIcon: Icons.person_2_outlined,
  fieldDefinitions: musicLibraryFieldDefinitions,
);
