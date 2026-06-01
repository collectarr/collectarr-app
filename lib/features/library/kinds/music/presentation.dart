import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/shared/presentation_support.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';

const musicLibraryMediaPresentation = LibraryMediaPresentation(
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
  groupLabels: LibraryMediaGroupLabels(
    series: 'Artist',
    seriesPlural: 'Artists',
    unknownSeries: 'Unknown artist',
    publisher: 'Label',
    publisherPlural: 'Labels',
    unknownPublisher: 'Unknown label',
  ),
  builder: musicLibraryMediaBuilder,
  previewLabels: releasesPreviewLabels,
  statsLabels: musicStatsLabels,
  referenceLabels: LibraryReferenceLabels(itemScope: 'Album'),
  compactBucketIcon: Icons.person_2_outlined,
  groupModes: [
    LibraryGroupMode.series,
    LibraryGroupMode.publisher,
    LibraryGroupMode.year,
    LibraryGroupMode.location,
    LibraryGroupMode.title,
    LibraryGroupMode.ownership,
  ],
);