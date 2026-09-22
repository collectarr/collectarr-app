import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_medium.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_card_presentation.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/config/workspace_presentation_support.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';

const musicMetadataLabels = LibraryMetadataLabels(
  identitySectionTitle: 'Album identity',
  contextSectionTitle: 'Album context',
  creditsSectionTitle: 'Contributors & Discovery',
  values: {
    'creators': 'Contributors',
    'characters': 'Featured artists',
    'genres': 'Genres',
  },
);

const musicLibraryMediaBuilder = MusicLibraryMediaPresentationBuilder(
  metadataLabels: musicMetadataLabels,
);

const musicPreviewLabels = LibraryMediaPreviewLabels(
  values: {
    'series': 'Artist',
    'item_count': 'Releases',
    'item_number': 'Disc / Volume',
    'publisher': 'Label',
    'variant': 'Format / Edition',
    'barcode': 'Barcode',
    'export_title': 'Release',
  },
);

const musicStatsLabels = LibraryMediaStatsLabels(
  values: {'top_series': 'Top Artists', 'top_publisher': 'Top Labels'},
);

const musicLibraryGroupLabels = LibraryPresentationLabels(
  values: {
    'media_scope': 'Release Groups',
    'series': 'Artist',
    'series_plural': 'Artists',
    'unknown_series': 'Unknown artist',
    'publisher': 'Label',
    'publisher_plural': 'Labels',
    'unknown_publisher': 'Unknown label',
    'export_title': 'Release',
  },
);

const musicLibraryBucketLabelOverrides = LibraryPresentationLabels();

final musicLibraryFilterDefinitions = <LibraryFilterDefinition<Object?>>[
  LibraryFilterDefinition<Object?>(
    id: 'series',
    label: 'Artist',
    anyLabel: 'Any artist',
    value: (item) => (item.dto is MusicWorkspaceProjection)
        ? (item.dto as MusicWorkspaceProjection).artist
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    id: 'location',
    label: 'Location',
    anyLabel: 'Any location',
  ),
  LibraryFilterDefinition<Object?>(
    id: 'tag',
    label: 'Tag',
    anyLabel: 'Any tag',
    inputKind: LibraryFilterInputKind.autocomplete,
    value: (item) => MusicOwnedItemProjection.fromDispatch(
      item.source.ownedItemDispatch,
    )?.tags?.split(','),
  ),
  LibraryFilterDefinition<Object?>(
    id: 'publisher',
    label: 'Label',
    anyLabel: 'Any label',
    value: (item) => (item.dto is MusicWorkspaceProjection)
        ? (item.dto as MusicWorkspaceProjection).publisher
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    id: 'year',
    label: 'Year',
    anyLabel: 'Any year',
    value: (item) => (item.dto is MusicWorkspaceProjection)
        ? (item.dto as MusicWorkspaceProjection).releaseDate?.year.toString()
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    id: 'condition',
    label: 'Condition',
    anyLabel: 'Any condition',
    value: (item) => MusicOwnedItemProjection.fromDispatch(
      item.source.ownedItemDispatch,
    )?.condition,
  ),
  LibraryFilterDefinition<Object?>(
    id: 'country',
    label: 'Country',
    anyLabel: 'Any country',
    value: (item) => (item.dto is MusicWorkspaceProjection)
        ? (item.dto as MusicWorkspaceProjection).country
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    id: 'language',
    label: 'Language',
    anyLabel: 'Any language',
    value: (item) => (item.dto is MusicWorkspaceProjection)
        ? (item.dto as MusicWorkspaceProjection).language
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    id: 'format',
    label: 'Format',
    anyLabel: 'Any format',
    value: (item) => _musicMediaFor(item)
        .map((medium) => medium.mediumType)
        .whereType<String>(),
  ),
  LibraryFilterDefinition<Object?>(
    id: 'packaging',
    label: 'Packaging',
    anyLabel: 'Any packaging',
    value: (item) => _musicReleasesFor(item)
        .map((release) => release.packaging)
        .whereType<String>(),
  ),
  LibraryFilterDefinition<Object?>(
    id: 'release_type',
    label: 'Release type',
    anyLabel: 'Any release type',
    value: (item) => _musicReleasesFor(item)
        .map((release) => release.releaseType)
        .whereType<String>(),
  ),
  LibraryFilterDefinition<Object?>(
    id: 'genre',
    label: 'Genre',
    anyLabel: 'Any genre',
    value: (item) => (item.dto is MusicWorkspaceProjection)
        ? (item.dto as MusicWorkspaceProjection).genres
        : const <String>[],
  ),
  LibraryFilterDefinition<Object?>(
    id: 'studio',
    label: 'Studio',
    anyLabel: 'Any studio',
    value: (item) => (item.dto is MusicWorkspaceProjection)
        ? (item.dto as MusicWorkspaceProjection).music.studio
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    id: 'is_live',
    label: 'Live recording',
    anyLabel: 'Any live status',
    value: (item) => (item.dto is MusicWorkspaceProjection)
        ? (item.dto as MusicWorkspaceProjection).isLive == true
            ? 'Yes'
            : 'No'
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    id: 'sound',
    label: 'Sound',
    anyLabel: 'Any sound type',
    value: (item) => _musicMediaFor(item)
        .map((medium) => medium.soundType)
        .whereType<String>(),
  ),
  LibraryFilterDefinition<Object?>(
    id: 'spars',
    label: 'SPARS',
    anyLabel: 'Any SPARS code',
    value: (item) =>
        _musicMediaFor(item).map((medium) => medium.spars).whereType<String>(),
  ),
  LibraryFilterDefinition<Object?>(
    id: 'vinyl_color',
    label: 'Vinyl color',
    anyLabel: 'Any vinyl color',
    value: (item) => _musicMediaFor(item)
        .map((medium) => medium.vinylColor)
        .whereType<String>(),
  ),
  LibraryFilterDefinition<Object?>(
    id: 'rpm',
    label: 'RPM',
    anyLabel: 'Any RPM',
    value: (item) => _musicMediaFor(item)
        .map((medium) => medium.rpm?.toString())
        .whereType<String>(),
  ),
  LibraryFilterDefinition<Object?>(
    id: 'recording_year',
    label: 'Recording year',
    anyLabel: 'Any recording year',
    value: (item) => (item.dto is MusicWorkspaceProjection)
        ? (item.dto as MusicWorkspaceProjection)
            .music
            .recordingDate
            ?.year
            .toString()
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    id: 'original_release_year',
    label: 'Original release year',
    anyLabel: 'Any original release year',
    value: (item) => (item.dto is MusicWorkspaceProjection)
        ? (item.dto as MusicWorkspaceProjection)
            .music
            .originalReleaseDate
            ?.year
            .toString()
        : null,
  ),
];

List<MusicRelease> _musicReleasesFor(LibraryProjectionView item) {
  final dto = item.dto;
  if (dto is! MusicWorkspaceProjection) return const <MusicRelease>[];
  final release = dto.release;
  return release == null ? dto.music.releases : [release];
}

List<MusicMedium> _musicMediaFor(LibraryProjectionView item) => [
      for (final release in _musicReleasesFor(item)) ...release.mediums,
    ];

String musicLibraryBucketLabelBuilder(LibraryBucketingContext context) {
  return defaultLibraryBucketLabel(
    context,
    musicLibraryGroupLabels,
    musicLibraryBucketLabelOverrides,
  );
}

final musicLibraryMediaPresentation = LibraryMediaPresentation(
  searchFieldLabels: const LibraryMediaSearchFieldLabels(
    queryHint: 'Enter album, artist, release, or label...',
    emptySearchMessage: 'Enter an album, artist, release, or label.',
  ),
  filterLabels: const LibraryPresentationLabels(
    values: {
      'series': 'Artist',
      'series_any': 'Any artist',
      'publisher': 'Label',
      'publisher_any': 'Any label',
      'year': 'Year',
      'year_any': 'Any year',
    },
  ),
  groupLabels: musicLibraryGroupLabels,
  builder: musicLibraryMediaBuilder,
  bucketLabelBuilder: musicLibraryBucketLabelBuilder,
  cardPresentationBuilder: buildMusicCardPresentation,
  compactBucketIcon: Icons.person_2_outlined,
  previewLabels: musicPreviewLabels,
  statsLabels: musicStatsLabels,
  filterDefinitions: musicLibraryFilterDefinitions,
  referenceLabels: const LibraryPresentationLabels(values: {'item': 'Album'}),
);
