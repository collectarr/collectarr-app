import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_entry_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_card_presentation.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_catalog_workspace_fields.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/config/workspace_presentation_support.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';

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
  if (MusicFieldIdentities.artist.filterable)
    LibraryFilterDefinition<Object?>(
      metadata: MusicFieldIdentities.artist,
      id: MusicFieldIdentities.artistId,
      label: MusicFieldIdentities.artist.label,
      anyLabel: 'Any artist',
      value: (item) => _musicWorkspaceFieldValue<Iterable<String>>(
        MusicCatalogWorkspaceFields.artist.getValue,
        item,
      ),
    ),
  LibraryFilterDefinition<Object?>(
    metadata: LibraryEntryFieldMetadata.location,
    id: 'location',
    label: 'Location',
    anyLabel: 'Any location',
  ),
  LibraryFilterDefinition<Object?>(
    metadata: LibraryEntryFieldMetadata.tag,
    id: 'tag',
    label: 'Tag',
    anyLabel: 'Any tag',
    inputKind: LibraryFilterInputKind.autocomplete,
    value: (item) => MusicLibraryEntryProjection.fromDispatch(
      item.source.libraryEntryDispatch,
    )?.personal.tags?.split(','),
  ),
  if (MusicFieldIdentities.publisher.filterable)
    LibraryFilterDefinition<Object?>(
      metadata: MusicFieldIdentities.publisher,
      id: MusicFieldIdentities.publisherId,
      label: MusicFieldIdentities.publisherLabel,
      anyLabel: 'Any label',
      value: (item) => _musicWorkspaceFieldValue<String?>(
        MusicCatalogWorkspaceFields.publisher.getValue,
        item,
      ),
    ),
  LibraryFilterDefinition<Object?>(
    metadata: MusicWorkspaceFieldMetadata.releaseYear,
    id: 'year',
    label: 'Year',
    anyLabel: 'Any year',
    value: (item) => _musicWorkspaceFieldValue<DateTime?>(
      MusicCatalogWorkspaceFields.releaseDate.getValue,
      item,
    )?.year.toString(),
  ),
  LibraryFilterDefinition<Object?>(
    metadata: LibraryEntryFieldMetadata.condition,
    id: 'condition',
    label: 'Condition',
    anyLabel: 'Any condition',
    value: (item) => MusicLibraryEntryProjection.fromDispatch(
      item.source.libraryEntryDispatch,
    )?.personal.condition,
  ),
  if (MusicFieldIdentities.country.filterable)
    LibraryFilterDefinition<Object?>(
      metadata: MusicFieldIdentities.country,
      id: MusicFieldIdentities.countryId,
      label: MusicFieldIdentities.countryLabel,
      anyLabel: 'Any country',
      value: (item) => _musicWorkspaceFieldValue<String?>(
        MusicCatalogWorkspaceFields.country.getValue,
        item,
      ),
    ),
  if (MusicFieldIdentities.discFormat.filterable)
    LibraryFilterDefinition<Object?>(
      metadata: MusicFieldIdentities.discFormat,
      id: MusicFieldIdentities.discFormatId,
      label: MusicFieldIdentities.discFormatLabel,
      anyLabel: 'Any disc format',
      value: (item) => _musicWorkspaceFieldValue<Iterable<String>>(
        MusicCatalogWorkspaceFields.discFormat.getValue,
        item,
      ),
    ),
  if (MusicFieldIdentities.packaging.filterable)
    LibraryFilterDefinition<Object?>(
      metadata: MusicFieldIdentities.packaging,
      id: MusicFieldIdentities.packagingId,
      label: MusicFieldIdentities.packagingLabel,
      anyLabel: 'Any packaging',
      value: (item) => _musicWorkspaceFieldValue<String?>(
        MusicCatalogWorkspaceFields.packaging.getValue,
        item,
      ),
    ),
  if (MusicFieldIdentities.genre.filterable)
    LibraryFilterDefinition<Object?>(
      metadata: MusicFieldIdentities.genre,
      id: MusicFieldIdentities.genreId,
      label: MusicFieldIdentities.genreLabel,
      anyLabel: 'Any genre',
      value: (item) => _musicWorkspaceFieldValue<Iterable<String>>(
        MusicCatalogWorkspaceFields.genre.getValue,
        item,
      ),
    ),
  LibraryFilterDefinition<Object?>(
    metadata: MusicWorkspaceFieldMetadata.recordingLocations,
    id: 'recording_location',
    label: 'Recording Location',
    anyLabel: 'Any recording location',
    value: (item) => (item.dto is MusicWorkspaceProjection)
        ? (item.dto as MusicWorkspaceProjection).facts.recordingLocations
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    metadata: MusicWorkspaceFieldMetadata.isLive,
    id: 'is_live',
    label: 'Live recording',
    anyLabel: 'Any live status',
    value: (item) => (item.dto is MusicWorkspaceProjection)
        ? <String>{
            if ((item.dto as MusicWorkspaceProjection).facts.hasLiveDisc) 'Yes',
            if ((item.dto as MusicWorkspaceProjection).facts.hasStudioDisc)
              'No',
          }
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    metadata: MusicWorkspaceFieldMetadata.sound,
    id: 'sound',
    label: 'Sound',
    anyLabel: 'Any sound type',
    value: (item) => (item.dto is MusicWorkspaceProjection)
        ? (item.dto as MusicWorkspaceProjection).facts.discSoundTypes
        : const <String>[],
  ),
  LibraryFilterDefinition<Object?>(
    metadata: MusicWorkspaceFieldMetadata.spars,
    id: 'spars',
    label: 'SPARS',
    anyLabel: 'Any SPARS code',
    value: (item) => (item.dto is MusicWorkspaceProjection)
        ? (item.dto as MusicWorkspaceProjection).facts.discSparsCodes
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    metadata: MusicWorkspaceFieldMetadata.vinylColor,
    id: 'vinyl_color',
    label: 'Vinyl color',
    anyLabel: 'Any vinyl color',
    value: (item) => (item.dto is MusicWorkspaceProjection)
        ? (item.dto as MusicWorkspaceProjection).facts.discColors
        : const <String>[],
  ),
  LibraryFilterDefinition<Object?>(
    metadata: MusicWorkspaceFieldMetadata.rpm,
    id: 'rpm',
    label: 'RPM',
    anyLabel: 'Any RPM',
    value: (item) => (item.dto is MusicWorkspaceProjection)
        ? (item.dto as MusicWorkspaceProjection).facts.discRpms
        : const <String>[],
  ),
  LibraryFilterDefinition<Object?>(
    metadata: MusicWorkspaceFieldMetadata.recordingYear,
    id: 'recording_year',
    label: 'Recording year',
    anyLabel: 'Any recording year',
    value: (item) => (item.dto is MusicWorkspaceProjection)
        ? (item.dto as MusicWorkspaceProjection)
            .facts
            .discRecordingYears
            .map((year) => year.toString())
        : null,
  ),
  LibraryFilterDefinition<Object?>(
    metadata: MusicWorkspaceFieldMetadata.originalReleaseYear,
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

TValue? _musicWorkspaceFieldValue<TValue>(
  TValue Function(LibraryProjectionContext<MusicWorkspaceProjection> context)
      getValue,
  LibraryProjectionView item,
) {
  final dto = item.dto;
  if (dto is! MusicWorkspaceProjection) return null;
  return getValue(
    LibraryProjectionContext<MusicWorkspaceProjection>(
        item: item.source.item, personal: item.source.personal, dto: dto),
  );
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
