import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_card_presentation.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_field_identities.dart';
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
    'item_count': 'Albums',
    'item_number': 'Disc / Volume',
    'publisher': 'Label',
    'variant': 'Format / Edition',
    'barcode': 'Barcode',
    'export_title': 'Album',
  },
);

const musicStatsLabels = LibraryMediaStatsLabels(
  values: {'top_series': 'Top Artists', 'top_publisher': 'Top Labels'},
);

const musicLibraryGroupLabels = LibraryPresentationLabels(
  values: {
    'media_scope': 'Albums',
    'series': 'Artist',
    'series_plural': 'Artists',
    'unknown_series': 'Unknown artist',
    'publisher': 'Label',
    'publisher_plural': 'Labels',
    'unknown_publisher': 'Unknown label',
    'export_title': 'Album',
  },
);

const musicLibraryBucketLabelOverrides = LibraryPresentationLabels();

final musicLibraryFilterDefinitions = <LibraryFilterDefinition<Object?>>[
  LibraryFilterDefinition<Object?>(
    id: MusicFieldIdentities.artistId,
    label: MusicFieldIdentities.artistLabel,
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
    value: (item) => MusicLibraryEntryProjection.fromDispatch(
      item.source.libraryEntryDispatch,
    )?.personal.tags?.split(','),
  ),
  LibraryFilterDefinition<Object?>(
    id: MusicFieldIdentities.publisherId,
    label: MusicFieldIdentities.publisherLabel,
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
    value: (item) => MusicLibraryEntryProjection.fromDispatch(
      item.source.libraryEntryDispatch,
    )?.personal.condition,
  ),
  LibraryFilterDefinition<Object?>(
    id: MusicFieldIdentities.countryId,
    label: MusicFieldIdentities.countryLabel,
    anyLabel: 'Any country',
    value: (item) => (item.dto is MusicWorkspaceProjection)
        ? (item.dto as MusicWorkspaceProjection).country
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    id: MusicFieldIdentities.formatId,
    label: MusicFieldIdentities.formatLabel,
    anyLabel: 'Any format',
    value: (item) => (item.dto is MusicWorkspaceProjection)
        ? (item.dto as MusicWorkspaceProjection).format
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    id: MusicFieldIdentities.packagingId,
    label: MusicFieldIdentities.packagingLabel,
    anyLabel: 'Any packaging',
    value: (item) => _musicAlbumsFor(item)
        .map((release) => release.packaging)
        .whereType<String>(),
  ),
  LibraryFilterDefinition<Object?>(
    id: MusicFieldIdentities.genreId,
    label: MusicFieldIdentities.genreLabel,
    anyLabel: 'Any genre',
    value: (item) => (item.dto is MusicWorkspaceProjection)
        ? (item.dto as MusicWorkspaceProjection).genres
        : const <String>[],
  ),
  LibraryFilterDefinition<Object?>(
    id: 'studios',
    label: 'Studio',
    anyLabel: 'Any studio',
    value: (item) => (item.dto is MusicWorkspaceProjection)
        ? (item.dto as MusicWorkspaceProjection).music.studios
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
    value: (item) => (item.dto is MusicWorkspaceProjection)
        ? [
            for (final d in (item.dto as MusicWorkspaceProjection).music.discs)
              ...d.soundTypes
          ]
        : const <String>[],
  ),
  LibraryFilterDefinition<Object?>(
    id: 'spars',
    label: 'SPARS',
    anyLabel: 'Any SPARS code',
    value: (item) => (item.dto is MusicWorkspaceProjection)
        ? (item.dto as MusicWorkspaceProjection).music.sparsCode
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    id: 'vinyl_color',
    label: 'Vinyl color',
    anyLabel: 'Any vinyl color',
    value: (item) => (item.dto is MusicWorkspaceProjection)
        ? [
            for (final d in (item.dto as MusicWorkspaceProjection).music.discs)
              if (d.color != null && d.color!.isNotEmpty) d.color!
          ]
        : const <String>[],
  ),
  LibraryFilterDefinition<Object?>(
    id: 'rpm',
    label: 'RPM',
    anyLabel: 'Any RPM',
    value: (item) => (item.dto is MusicWorkspaceProjection)
        ? [
            for (final d in (item.dto as MusicWorkspaceProjection).music.discs)
              if (d.rpm != null && d.rpm!.isNotEmpty) d.rpm!
          ]
        : const <String>[],
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

List<MusicAlbum> _musicAlbumsFor(LibraryProjectionView item) {
  final dto = item.dto;
  if (dto is! MusicWorkspaceProjection) return const <MusicAlbum>[];
  return [dto.music];
}

String musicLibraryBucketLabelBuilder(LibraryBucketingContext context) {
  return defaultLibraryBucketLabel(
    context,
    musicLibraryGroupLabels,
    musicLibraryBucketLabelOverrides,
  );
}

final musicLibraryMediaPresentation = LibraryMediaPresentation(
  searchFieldLabels: const LibraryMediaSearchFieldLabels(
    queryHint: 'Enter album, artist, format, or label...',
    emptySearchMessage: 'Enter an album, artist, format, or label.',
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
