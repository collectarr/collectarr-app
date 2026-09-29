import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_fields.dart';

import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_duplicate_presentation.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/kinds/music/inspector/music_inspector_track_list.dart';
import 'package:collectarr_app/features/library/kinds/music/inspector/music_inspector_view_model.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/music_country_name.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_relations.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/music/music_physical_media_formats.dart';
import 'package:collectarr_app/features/library/widgets/format_badge.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:flutter/material.dart';

class MusicLibraryMediaPresentationBuilder
    extends LibraryMediaPresentationBuilder {
  const MusicLibraryMediaPresentationBuilder({
    this.metadataLabels = const LibraryMetadataLabels(),
  });

  final LibraryMetadataLabels metadataLabels;

  @override
  String? buildAddPreviewItemNumber({
    required CatalogSearchCandidate item,
  }) =>
      item.kindCapability.mapTransport((transport) => transport).itemNumber;

  @override
  List<LibraryFormatBadgeDescriptor> buildAddPreviewFormatBadges({
    required CatalogSearchCandidate item,
  }) {
    final seen = <String>{};
    final result = <LibraryFormatBadgeDescriptor>[];
    for (final edition in item.kindCapability
        .mapTransport((transport) => transport)
        .editions) {
      final badge = musicFormatBadge(
        edition.physicalFormat,
        label: edition.physicalFormatLabel,
      );
      if (badge == null || !seen.add(badge.key)) continue;
      result.add(badge);
    }
    return result;
  }

  @override
  List<LibraryDuplicateCandidate> buildDuplicateCandidates(
    LibraryWorkspaceSource entry,
  ) {
    final catalog = entry.catalogData;
    if (catalog is! MusicWorkspaceCatalogData) return const [];
    final item = catalog.music;
    final release = item.primaryRelease;
    final identifier = normalizeLibraryDuplicateIdentifier(
      release?.barcode ?? release?.upc,
    );
    if (identifier == null) return const [];
    return [
      LibraryDuplicateCandidate(
        key: 'identifier:$identifier',
        label: 'Identifier $identifier',
        reason: 'Same identifier',
        confidenceScore: 78,
      ),
    ];
  }

  @override
  List<LibraryWorkspaceReleaseSummary> buildWorkspaceReleases(
    LibraryWorkspaceSource entry,
  ) {
    final catalog = entry.catalogData;
    if (catalog is! MusicWorkspaceCatalogData) return const [];
    return [
      for (final release in catalog.music.releases)
        LibraryWorkspaceReleaseSummary(
          id: release.id.value,
          title: release.title,
          formatBadge: release.mediums.isEmpty
              ? null
              : musicFormatBadge(release.mediums.first.mediumType),
          releaseDate: release.releaseDate,
          mediaLabels: [
            for (final medium in release.mediums)
              medium.title ?? 'Medium ${medium.mediumNumber}',
          ],
        ),
    ];
  }

  @override
  List<LibraryAddReleaseOption> buildReleaseOptions({
    required CatalogSearchCandidate item,
  }) {
    return [
      for (final edition in item.kindCapability
          .mapTransport((transport) => transport)
          .editions)
        LibraryAddReleaseOption(
          id: edition.id,
          title: edition.title,
          formatId: edition.physicalFormat,
          formatLabel: edition.physicalFormatLabel,
          formatBadge: musicFormatBadge(
            edition.physicalFormat,
            label: edition.physicalFormatLabel,
          ),
          releaseDate: edition.releaseDate,
          coverImageUrl: edition.variants.firstOrNull?.coverImageUrl,
          identifierCode: edition.identifierCode,
          variants: [
            for (final variant in edition.variants)
              LibraryAddVariantOption(
                id: variant.id,
                name: variant.name,
                coverImageUrl: variant.coverImageUrl,
                identifierCode: variant.identifierCode,
                formatId: variant.physicalFormat,
                formatLabel: variant.physicalFormatLabel,
                formatBadge: musicFormatBadge(
                  variant.physicalFormat,
                  label: variant.physicalFormatLabel,
                ),
                isPrimary: variant.isPrimary,
              ),
          ],
        ),
    ];
  }

  @override
  CatalogSearchCandidate mergeHydratedAddItem({
    required CatalogSearchCandidate hydrated,
    required CatalogSearchCandidate fallback,
  }) {
    final hydratedMetadata = hydrated.musicCatalogFields;
    final fallbackMetadata = fallback.musicCatalogFields;
    final hydratedEditions =
        hydrated.kindCapability.mapTransport((transport) => transport.editions);
    final fallbackEditions =
        fallback.kindCapability.mapTransport((transport) => transport.editions);
    final editions =
        hydratedEditions.isEmpty ? fallbackEditions : hydratedEditions;
    final coverImageUrl =
        hydratedMetadata.coverImageUrl ?? fallbackMetadata.coverImageUrl;
    final thumbnailImageUrl = hydratedMetadata.coverImageUrl != null
        ? hydratedMetadata.thumbnailImageUrl
        : fallbackMetadata.thumbnailImageUrl ?? fallbackMetadata.coverImageUrl;
    return CatalogSearchCandidate.fromItem(
        hydrated.kindCapability.mapTransport((transport) => transport.copyWith(
              coverImageUrl: coverImageUrl,
              thumbnailImageUrl: thumbnailImageUrl,
              editions: editions,
            )));
  }

  @override
  bool get showAddPreviewDescription => false;

  @override
  List<String> buildCatalogSearchAliases({
    required CatalogSearchCandidate item,
  }) =>
      item.musicCatalogFields.searchAliases;

  @override
  LibraryAddSearchResultDisplay? buildSearchResultDisplay({
    required CatalogSearchCandidate item,
  }) {
    final group = _musicGroupItem(item);
    final release = group?.primaryRelease;
    final medium = release?.mediums.firstOrNull;
    final subtitle = _firstMeaningfulMusicValue([
      release?.subtitle,
      if ((medium?.mediumNumber ?? 0) > 1) 'Medium ${medium!.mediumNumber}',
    ], disallow: {
      item.summary.primaryLabel.trim().toLowerCase(),
    });
    final cleanedTitle =
        _stripTrailingMusicDescriptor(item.summary.primaryLabel, subtitle);
    final artist = group?.artist?.trim();
    final format = medium?.mediumType?.trim();
    final trackCount = group?.trackCount;
    final catalogNumber = release?.catalogNumber?.trim();
    final barcode = (release?.barcode ?? release?.upc)?.trim();
    final detailParts = <String>[
      if (subtitle != null && subtitle.isNotEmpty) subtitle,
      if (format != null && format.isNotEmpty) format,
      if (trackCount != null)
        '$trackCount ${trackCount == 1 ? 'track' : 'tracks'}',
      if (barcode != null && barcode.isNotEmpty) barcode,
      if (catalogNumber != null && catalogNumber.isNotEmpty) catalogNumber,
    ];
    return LibraryAddSearchResultDisplay(
      title: cleanedTitle.isEmpty ? item.summary.primaryLabel : cleanedTitle,
      secondaryLine: artist?.isNotEmpty == true ? artist : subtitle,
      year: item.musicCatalogFields.releaseYear ??
          item.musicCatalogFields.releaseDate?.year,
      detailLine: detailParts.isEmpty ? null : detailParts.join(' - '),
    );
  }

  @override
  List<(String, String?)> buildAddPreviewMetadataRows({
    required CatalogSearchCandidate item,
    required LibraryMediaPreviewLabels previewLabels,
  }) {
    final releaseDate = item.musicCatalogFields.releaseDate;
    return [
      (
        previewLabels.labelFor('publisher', fallback: 'Publisher'),
        item.kindCapability.mapTransport((transport) => transport).publisher
      ),
      (
        'Released',
        releaseDate == null
            ? item.musicCatalogFields.releaseYear?.toString()
            : '${releaseDate.year}-${releaseDate.month.toString().padLeft(2, '0')}-${releaseDate.day.toString().padLeft(2, '0')}',
      ),
      if (item.kindCapability
              .mapTransport((transport) => transport)
              .itemNumber !=
          null)
        (
          previewLabels.labelFor('item_number', fallback: 'Number'),
          item.kindCapability.mapTransport((transport) => transport).itemNumber
        ),
      if (item.kindCapability.mapTransport((transport) => transport).variant !=
          null)
        (
          previewLabels.labelFor('variant', fallback: 'Variant'),
          item.kindCapability.mapTransport((transport) => transport).variant
        ),
      (
        previewLabels.labelFor('barcode', fallback: 'Barcode'),
        item.kindCapability
            .mapTransport((transport) => transport)
            .identifierCode
      ),
    ];
  }

  @override
  LibraryMetadataPresentation buildMetadataPresentation({
    required String singularLabel,
    required LibraryProjectionView item,
    required bool includeIdentityFacts,
    required LibraryMetadataFactTapResolver tapFor,
  }) {
    final dto = item.dto;
    final group = _musicGroup(item);
    final release = group?.primaryRelease;
    final medium = release?.mediums.firstOrNull;
    final artist = group?.artist;
    final barcode = release?.barcode ?? release?.upc;
    final publisher = release?.publisher;
    final releaseDate = release?.releaseDate ?? group?.originalReleaseDate;
    final country = musicCountryName(release?.countryCode);
    final language = release?.language;

    return LibraryMetadataPresentation(
      labels: metadataLabels,
      identityFacts: [
        if (includeIdentityFacts) ...[
          LibraryDetailField(label: 'Kind', value: singularLabel),
          LibraryDetailField(label: 'ID', value: item.node.workId),
          LibraryDetailField(label: 'Title', value: dto.primaryLabel),
        ],
        if (artist != null)
          LibraryDetailField(
              label: 'Artist', value: artist, onTap: tapFor(artist)),
        if (medium != null)
          LibraryDetailField(
              label: 'Disc',
              value: medium.title ?? 'Medium ${medium.mediumNumber}'),
        if (medium?.mediumType != null)
          LibraryDetailField(
              label: 'Format / Edition',
              value: medium!.mediumType!,
              onTap: tapFor(medium.mediumType!)),
        if (barcode != null)
          LibraryDetailField(label: 'Barcode', value: barcode),
        if (release?.catalogNumber != null)
          LibraryDetailField(
            label: 'Catalog #',
            value: release!.catalogNumber!,
          ),
      ],
      contextFacts: [
        if (artist != null)
          LibraryDetailField(
              label: 'Artist', value: artist, onTap: tapFor(artist)),
        LibraryDetailField(label: 'Album', value: dto.primaryLabel),
        if (publisher != null)
          LibraryDetailField(
              label: 'Label', value: publisher, onTap: tapFor(publisher)),
        LibraryDetailField(
            label: 'Released',
            value: genericLibraryDash(
              formatPresentationNullableDate(releaseDate) ??
                  releaseDate?.year.toString(),
            )),
        if (group?.trackCount != null)
          LibraryDetailField(
              label: 'Tracks', value: group!.trackCount.toString()),
        if (release?.mediums.isNotEmpty == true)
          LibraryDetailField(
              label: 'Medium count', value: release!.mediums.length.toString()),
        if (release?.catalogNumber != null)
          LibraryDetailField(
              label: 'Catalog #', value: release!.catalogNumber!),
        if (release?.releaseStatus != null)
          LibraryDetailField(
              label: 'Release Status', value: release!.releaseStatus!),
        if (country != null)
          LibraryDetailField(label: 'Country', value: country),
        if (language != null)
          LibraryDetailField(label: 'Language', value: language),
        if (group?.tracks.isNotEmpty == true)
          LibraryDetailField(label: 'Length', value: _musicDuration(group!)),
        if (medium?.vinylColor != null)
          LibraryDetailField(label: 'Vinyl color', value: medium!.vinylColor!),
        if (medium?.rpm != null)
          LibraryDetailField(label: 'RPM', value: medium!.rpm.toString()),
        LibraryDetailField(
            label: 'Cover',
            value: dto.imageUrl == null || dto.imageUrl!.isEmpty
                ? 'Missing'
                : 'Ready'),
        LibraryDetailField(
            label: 'Metadata',
            value:
                group == null || group.releases.isEmpty ? 'Missing' : 'Ready'),
      ],
      sections: {
        'creators': LibraryMetadataSection(
          values: [
            for (final contribution
                in release?.contributions ?? const <MusicReleaseContribution>[])
              contribution.toJson(),
          ],
          placement: LibraryMetadataSectionPlacement.credits,
          renderer: LibraryMetadataSectionRenderer.credits,
          completenessWeight: 12,
        ),
        'genres': LibraryMetadataSection(
          values: group?.genres ?? const <String>[],
        ),
      },
    );
  }

  @override
  List<Widget> buildInspectorSections({
    required BuildContext context,
    required LibraryProjectionView item,
    required Color accent,
    ValueChanged<String>? onFilterByValue,
  }) {
    final model = MusicInspectorViewModel.from(item);
    if (model.tracks.isNotEmpty) {
      return [
        MusicInspectorTrackList(
          tracks: model.tracks,
          accent: accent,
          onFilterByValue: onFilterByValue,
        ),
      ];
    }
    final trackCount = model.release?.trackCount ?? model.group.trackCount;
    if (trackCount <= 0) return const <Widget>[];
    return [
      MusicInspectorTrackListUnavailable(
        trackCount: trackCount,
        accent: accent,
      ),
    ];
  }
}

MusicReleaseGroup? _musicGroup(LibraryProjectionView item) {
  final catalog = item.source.catalogData;
  return catalog is MusicWorkspaceCatalogData ? catalog.music : null;
}

MusicReleaseGroup? _musicGroupItem(CatalogSearchCandidate? item) {
  if (item == null) return null;
  return item.kindCapability
      .mapTransport(MusicCatalogMapper.mapMetadataItemToMusic);
}

String _musicDuration(MusicReleaseGroup group) {
  final totalSeconds = group.tracks.fold<int>(
    0,
    (total, entry) => total + (entry.track.durationMs ?? 0) ~/ 1000,
  );
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

String _stripTrailingMusicDescriptor(String title, String? descriptor) {
  final trimmedTitle = title.trim();
  final trimmedDescriptor = descriptor?.trim();
  if (trimmedDescriptor == null || trimmedDescriptor.isEmpty) {
    return trimmedTitle;
  }
  final lowerTitle = trimmedTitle.toLowerCase();
  final lowerDescriptor = trimmedDescriptor.toLowerCase();
  for (final separator in [' - ', ' – ', ' — ', ': ', ' ']) {
    final suffix = '$separator$trimmedDescriptor';
    if (lowerTitle.endsWith(suffix.toLowerCase())) {
      return trimmedTitle
          .substring(0, trimmedTitle.length - suffix.length)
          .trimRight();
    }
  }
  if (lowerTitle == lowerDescriptor) {
    return title;
  }
  return trimmedTitle;
}

String? _firstMeaningfulMusicValue(
  Iterable<String?> values, {
  Set<String> disallow = const <String>{},
}) {
  for (final value in values) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      continue;
    }
    if (disallow.contains(trimmed.toLowerCase())) {
      continue;
    }
    return trimmed;
  }
  return null;
}
