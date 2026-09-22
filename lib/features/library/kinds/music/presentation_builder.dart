import 'dart:math' as math;

import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_duplicate_presentation.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/kinds/music/inspector/music_inspector_track_list.dart';
import 'package:collectarr_app/features/library/kinds/music/inspector/music_inspector_view_model.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_candidates.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_identity.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_image_candidate.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_candidate.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_role.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_relations.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/music/music_physical_media_formats.dart';
import 'package:collectarr_app/features/library/widgets/format_badge.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
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
      item.mapTransport((transport) => transport).itemNumber;

  @override
  List<LibraryFormatBadgeDescriptor> buildAddPreviewFormatBadges({
    required CatalogSearchCandidate item,
  }) {
    final seen = <String>{};
    final result = <LibraryFormatBadgeDescriptor>[];
    for (final edition
        in item.mapTransport((transport) => transport).editions) {
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
      for (final edition
          in item.mapTransport((transport) => transport).editions)
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
      item.primaryLabel.trim().toLowerCase(),
    });
    final cleanedTitle =
        _stripTrailingMusicDescriptor(item.primaryLabel, subtitle);
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
      title: cleanedTitle.isEmpty ? item.primaryLabel : cleanedTitle,
      secondaryLine: artist?.isNotEmpty == true ? artist : subtitle,
      detailLine: detailParts.isEmpty ? null : detailParts.join(' - '),
    );
  }

  @override
  List<ProviderSearchCandidate>
      buildProviderGroupPreviewChildrenForSearchCandidate({
    required ProviderSearchCandidate groupCandidate,
    required AdminProviderPreview preview,
  }) {
    if (groupCandidate case final MusicReleaseGroupCandidate group) {
      if (group.releases.isNotEmpty) {
        return [
          for (final release in group.releases)
            _musicReleaseCandidateFromSummary(
              group: group,
              release: release,
            ),
        ];
      }
      final rawReleases = preview.music?['releases'];
      if (rawReleases is List) {
        return [
          for (final value in rawReleases)
            if (value is Map)
              if (_musicReleaseCandidateFromPreview(
                group: group,
                value: Map<String, dynamic>.from(value),
                preview: preview,
              )
                  case final candidate?)
                candidate,
        ];
      }
      return const [];
    }
    return super.buildProviderGroupPreviewChildrenForSearchCandidate(
      groupCandidate: groupCandidate,
      preview: preview,
    );
  }

  @override
  List<(String, String?)> buildAddPreviewMetadataRows({
    required CatalogSearchCandidate item,
    required LibraryMediaPreviewLabels previewLabels,
  }) {
    final releaseDate = item.editMetadata.releaseDate;
    return [
      (
        previewLabels.labelFor('publisher', fallback: 'Publisher'),
        item.mapTransport((transport) => transport).publisher
      ),
      (
        'Released',
        releaseDate == null
            ? item.editMetadata.releaseYear?.toString()
            : '${releaseDate.year}-${releaseDate.month.toString().padLeft(2, '0')}-${releaseDate.day.toString().padLeft(2, '0')}',
      ),
      if (item.mapTransport((transport) => transport).itemNumber != null)
        (
          previewLabels.labelFor('item_number', fallback: 'Number'),
          item.mapTransport((transport) => transport).itemNumber
        ),
      if (item.mapTransport((transport) => transport).variant != null)
        (
          previewLabels.labelFor('variant', fallback: 'Variant'),
          item.mapTransport((transport) => transport).variant
        ),
      (
        previewLabels.labelFor('barcode', fallback: 'Barcode'),
        item.mapTransport((transport) => transport).identifierCode
      ),
    ];
  }

  @override
  Widget? buildAddPreviewPaneForCoreItem({
    required BuildContext context,
    required Color accent,
    required String singularLabel,
    required LibraryMediaPreviewLabels previewLabels,
    required CatalogSearchCandidate? item,
    required AdminProviderPreview? preview,
    required bool isFetchingPreview,
    required String providerLabel,
  }) {
    return _buildMusicAddPreviewPane(
      accent: accent,
      singularLabel: singularLabel,
      item: item,
      candidate: null,
      preview: preview,
      isFetchingPreview: isFetchingPreview,
      providerLabel: providerLabel,
    );
  }

  @override
  Widget? buildAddPreviewPaneForSearchCandidate({
    required BuildContext context,
    required Color accent,
    required String singularLabel,
    required LibraryMediaPreviewLabels previewLabels,
    required CatalogSearchCandidate? item,
    required ProviderSearchCandidate? candidate,
    required AdminProviderPreview? preview,
    required bool isFetchingPreview,
    required String providerLabel,
  }) {
    if (candidate == null) {
      return buildAddPreviewPaneForCoreItem(
        context: context,
        accent: accent,
        singularLabel: singularLabel,
        previewLabels: previewLabels,
        item: item,
        preview: preview,
        isFetchingPreview: isFetchingPreview,
        providerLabel: providerLabel,
      );
    }
    return _buildMusicAddPreviewPane(
      accent: accent,
      singularLabel: singularLabel,
      item: item,
      candidate: candidate,
      preview: preview,
      isFetchingPreview: isFetchingPreview,
      providerLabel: providerLabel,
    );
  }

  Widget? _buildMusicAddPreviewPane({
    required Color accent,
    required String singularLabel,
    required CatalogSearchCandidate? item,
    required ProviderSearchCandidate? candidate,
    required AdminProviderPreview? preview,
    required bool isFetchingPreview,
    required String providerLabel,
  }) {
    final rawAlbumTitle =
        item?.primaryLabel ?? candidate?.title ?? preview?.title;
    if (rawAlbumTitle == null || rawAlbumTitle.trim().isEmpty) return null;
    final group = _musicGroupItem(item);
    final release = group?.primaryRelease;
    final previewMusicArtist = preview?.music?['artist']?.toString().trim();
    final artist = group?.artist ??
        (previewMusicArtist == null || previewMusicArtist.isEmpty
            ? null
            : previewMusicArtist) ??
        _musicCandidateArtist(candidate);
    final coverUrl = item?.editMetadata.coverImageUrl ??
        preview?.coverImageUrl ??
        candidate?.imageUrl;
    final genres =
        group?.genres ?? preview?.genres ?? _musicCandidateGenres(candidate);
    final albumSubtitle = _musicAlbumSubtitle(item: item, preview: preview);
    final albumTitle = _stripTrailingMusicDescriptor(
      rawAlbumTitle,
      albumSubtitle,
    );
    final releaseLine = _musicReleaseLine(
      albumTitle: albumTitle,
      item: item,
      preview: preview,
      candidate: candidate,
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
    final isReleaseGroup = candidate != null
        ? candidate.searchRole == ProviderSearchRole.releaseGroup
        : _musicItemIsReleaseGroup(item) ||
            preview?.music?['entity_type'] == 'music_release_group';
    final tracks = _musicPreviewTracks(
      item: item,
      preview: preview,
      candidate: candidate,
    );
    final releases = isReleaseGroup
        ? _musicPreviewReleases(
            item: item,
            preview: preview,
            candidate: candidate,
          )
        : const <_MusicPreviewReleaseData>[];
    final trackCount = release?.trackCount ??
        _musicCandidateTrackCount(candidate) ??
        tracks.where((track) => !track.isHeader).length;
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
      itemNumber: item?.mapTransport((transport) => transport).itemNumber ??
          preview?.itemNumber,
      tracks: tracks,
      releases: releases,
      isReleaseGroup: isReleaseGroup,
      trackCount: trackCount,
      isFetchingPreview: isFetchingPreview,
      hasCoreMetadata: item != null,
      providerLabel: item == null ? providerLabel : singularLabel,
    );
  }

  @override
  List<(String, String?)> buildAddPreviewMetadataRowsForSearchCandidate({
    required ProviderSearchCandidate candidate,
    required LibraryMediaPreviewLabels previewLabels,
  }) {
    final artist = _musicCandidateArtist(candidate);
    final publisher = _musicCandidatePublisher(candidate);
    final releaseDate = _musicCandidateReleaseDate(candidate);
    final format = _musicCandidateFormat(candidate);
    final barcode = _musicCandidateBarcode(candidate);
    final catalogNumber = _musicCandidateCatalogNumber(candidate);
    final releaseCount = candidate is MusicReleaseGroupCandidate
        ? candidate.releases.length.toString()
        : null;
    return [
      if (artist != null && artist.trim().isNotEmpty)
        (previewLabels.labelFor('artist', fallback: 'Artist'), artist),
      if (publisher != null && publisher.trim().isNotEmpty)
        (previewLabels.labelFor('publisher', fallback: 'Publisher'), publisher),
      if (releaseDate != null) ('Released', _musicDateLabel(releaseDate)),
      if (format != null && format.trim().isNotEmpty)
        (previewLabels.labelFor('format', fallback: 'Format'), format),
      if (barcode != null && barcode.trim().isNotEmpty)
        (previewLabels.labelFor('barcode', fallback: 'Barcode'), barcode),
      if (catalogNumber != null && catalogNumber.trim().isNotEmpty)
        (
          previewLabels.labelFor('catalog_number', fallback: 'Catalog number'),
          catalogNumber,
        ),
      if (releaseCount != null && releaseCount != '0')
        (
          previewLabels.labelFor('item_count', fallback: 'Releases'),
          releaseCount,
        ),
    ];
  }

  @override
  List<(String, String?)> buildAddPreviewMetadataRowsForFullPreview({
    required AdminProviderPreview preview,
    required LibraryMediaPreviewLabels previewLabels,
  }) {
    final series = preview.series;
    final publishing = preview.publishing;
    final music = preview.music;
    final video = preview.video;
    final game = preview.game;
    final releaseDate = preview.releaseDate;
    final releaseDateText = releaseDate == null
        ? null
        : '${releaseDate.year}-${releaseDate.month.toString().padLeft(2, '0')}-${releaseDate.day.toString().padLeft(2, '0')}';
    final musicCatalogNumber = (music?['catalog_number'] as String?)?.trim();
    final musicReleaseStatus = (music?['release_status'] as String?)?.trim();
    final gamePlatforms = (game?['platforms'] as List<dynamic>?)
        ?.map((value) => value.toString().trim())
        .where((value) => value.isNotEmpty)
        .toList();
    final runtimeMinutes = (video?['runtime_minutes'] as num?)?.toInt();
    final pageCount = publishing?.pageCount?.toString();
    final seriesGroup = publishing?.seriesGroup?.trim();
    return [
      if (series?.seriesTitle != null)
        (
          previewLabels.labelFor('series', fallback: 'Series'),
          series!.seriesTitle
        ),
      if (preview.publisher != null)
        (
          previewLabels.labelFor('publisher', fallback: 'Publisher'),
          preview.publisher
        ),
      if (releaseDateText != null) ('Released', releaseDateText),
      if (series?.volumeStartYear != null)
        ('Year', series!.volumeStartYear.toString()),
      if (preview.itemNumber != null)
        (
          previewLabels.labelFor('item_number', fallback: 'Number'),
          preview.itemNumber
        ),
      if (preview.identifierCode != null)
        (
          previewLabels.labelFor('barcode', fallback: 'Barcode'),
          preview.identifierCode,
        ),
      if (preview.isbn != null) ('ISBN', preview.isbn),
      if (preview.country != null) ('Country', preview.country),
      if (preview.language != null) ('Language', preview.language),
      if (preview.physicalFormatLabel != null)
        ('Format', preview.physicalFormatLabel),
      if (preview.variantName != null)
        (
          previewLabels.labelFor('variant', fallback: 'Variant'),
          preview.variantName
        ),
      if (musicCatalogNumber != null && musicCatalogNumber.isNotEmpty)
        ('Catalog No.', musicCatalogNumber),
      if (gamePlatforms != null && gamePlatforms.isNotEmpty)
        ('Platforms', gamePlatforms.join(', ')),
      if (runtimeMinutes != null) ('Runtime', '$runtimeMinutes min'),
      if (pageCount != null) ('Pages', pageCount),
      if (musicReleaseStatus != null && musicReleaseStatus.isNotEmpty)
        ('Release Status', musicReleaseStatus),
      if (music?['release_group_title'] != null)
        ('Release Group', music!['release_group_title']!.toString()),
      if (music?['releases'] is List)
        ('Releases', (music!['releases'] as List).length.toString()),
      if (seriesGroup != null && seriesGroup.isNotEmpty)
        ('Series Group', seriesGroup),
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
    final country = release?.countryCode;
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

List<String> _providerPreviewMediumTypes(Map<String, dynamic> value) {
  final result = <String>[];
  final rawValues = value['medium_types'] ?? value['formats'];
  if (rawValues is Iterable) {
    for (final raw in rawValues) {
      final text = raw?.toString().trim();
      if (text != null && text.isNotEmpty && !result.contains(text)) {
        result.add(text);
      }
    }
  }
  final format = value['format']?.toString().trim();
  if (format != null && format.isNotEmpty && !result.contains(format)) {
    result.add(format);
  }
  final mediums = value['mediums'];
  if (mediums is Iterable) {
    for (final raw in mediums) {
      if (raw is! Map) continue;
      final text = raw['medium_type']?.toString().trim() ??
          raw['format']?.toString().trim();
      if (text != null && text.isNotEmpty && !result.contains(text)) {
        result.add(text);
      }
    }
  }
  return result;
}

MusicReleaseGroup? _musicGroup(LibraryProjectionView item) {
  final catalog = item.source.catalogData;
  return catalog is MusicWorkspaceCatalogData ? catalog.music : null;
}

MusicReleaseGroup? _musicGroupItem(CatalogSearchCandidate? item) {
  if (item == null) return null;
  return item.mapTransport(MusicCatalogMapper.mapMetadataItemToMusic);
}

bool _musicItemIsReleaseGroup(CatalogSearchCandidate? item) {
  if (item == null) return false;
  return item.mapTransport((transport) {
    final payload = transport.payload;
    final nestedMusic = payload['music'];
    return payload['entity_type'] == 'music_release_group' ||
        (nestedMusic is Map &&
            nestedMusic['entity_type'] == 'music_release_group');
  });
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
    required this.releases,
    required this.isReleaseGroup,
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
  final List<_MusicPreviewReleaseData> releases;
  final bool isReleaseGroup;
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
    final releaseHeading = releases.isNotEmpty
        ? '${releases.length} ${releases.length == 1 ? 'release' : 'releases'}'
        : null;
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
          final compactHeight = !paneConstraints.hasBoundedHeight ||
              paneConstraints.maxHeight < 320;
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
                    releaseHeading: releaseHeading,
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
                          if (releaseHeading != null)
                            Text(
                              releaseHeading,
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            )
                          else if (trackHeading != null)
                            Text(
                              trackHeading,
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          if (releases.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Expanded(
                              child: ListView(
                                children: [
                                  for (final release in releases)
                                    _MusicAddPreviewReleaseRow(
                                      release: release,
                                      accent: accent,
                                    ),
                                ],
                              ),
                            ),
                          ] else if (tracks.isNotEmpty) ...[
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
    required String? releaseHeading,
  }) {
    final palette = appPalette(context);
    final stacked = maxWidth < 560;
    final coverSize =
        math.min(stacked ? 160.0 : 180.0, math.max(0.0, maxWidth));
    final showCover = coverSize >= 72;
    final trackGroups = _groupTracksByDisc(tracks);
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (releaseHeading != null)
          Text(
            releaseHeading,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          )
        else if (trackHeading != null)
          Text(
            trackHeading,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        if (releases.isNotEmpty) ...[
          const SizedBox(height: 4),
          for (final release in releases)
            _MusicAddPreviewReleaseRow(
              release: release,
              accent: accent,
            ),
        ] else if (tracks.isNotEmpty) ...[
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
    if (isReleaseGroup) {
      return isFetchingPreview
          ? 'Fetching release list...'
          : 'Release list unavailable for this release group yet.';
    }
    if (isFetchingPreview) {
      return 'Fetching track list...';
    }
    if (hasCoreMetadata && (trackCount ?? 0) > 0) {
      return 'Collectarr Core returned this release, but the cached track list is not available yet.';
    }
    return 'Track list unavailable for this release yet.';
  }
}

class _MusicPreviewReleaseData {
  const _MusicPreviewReleaseData({
    required this.title,
    this.releaseDate,
    this.country,
    this.format,
    this.barcode,
    this.catalogNumber,
    this.coverUrl,
  });

  final String title;
  final String? releaseDate;
  final String? country;
  final String? format;
  final String? barcode;
  final String? catalogNumber;
  final String? coverUrl;
}

class _MusicAddPreviewReleaseRow extends StatelessWidget {
  const _MusicAddPreviewReleaseRow({
    required this.release,
    required this.accent,
  });

  final _MusicPreviewReleaseData release;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final details = [
      release.releaseDate,
      release.country,
      release.format,
      release.catalogNumber,
      release.barcode,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).join(' / ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 42,
            height: 42,
            child: LibraryCoverImage(
              title: release.title,
              imageUrl: release.coverUrl,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  release.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    details,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.album_outlined, size: 16, color: accent),
        ],
      ),
    );
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
      padding: EdgeInsets.fromLTRB(
        track.indentLevel * 14.0,
        track.isHeader ? 7 : 3,
        0,
        track.isHeader ? 5 : 3,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: track.isHeader ? 20 : 24,
            child: track.isHeader
                ? Icon(
                    Icons.folder_outlined,
                    size: 16,
                    color: accent.withValues(alpha: 0.9),
                  )
                : Text(
                    '${track.position ?? index}',
                    style: TextStyle(
                      color: palette.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.right,
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: track.isHeader ? accent : palette.textPrimary,
                    fontSize: 14,
                    fontWeight:
                        track.isHeader ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
                if (!track.isHeader && track.artist?.trim().isNotEmpty == true)
                  Text(
                    track.artist!.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          if (!track.isHeader && track.durationLabel != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                track.durationLabel!,
                style: TextStyle(
                  color: palette.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
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
    this.artist,
    this.isHeader = false,
    this.indentLevel = 0,
    this.parentHeaderId,
  });

  final String title;
  final int? position;
  final int? durationSeconds;
  final int? discNumber;
  final String? artist;
  final bool isHeader;
  final int indentLevel;
  final String? parentHeaderId;

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
  required CatalogSearchCandidate? item,
  required AdminProviderPreview? preview,
  ProviderSearchCandidate? candidate,
}) {
  final releaseYear = item?.editMetadata.releaseYear ??
      item?.editMetadata.releaseDate?.year ??
      preview?.releaseDate?.year ??
      preview?.series?.volumeStartYear ??
      _musicCandidateReleaseDate(candidate)?.year;
  if (releaseYear == null) {
    return albumTitle;
  }
  return '$albumTitle ($releaseYear)';
}

String? _musicLabelCatalogLine({
  required CatalogSearchCandidate? item,
  required AdminProviderPreview? preview,
  required ProviderSearchCandidate? candidate,
}) {
  final meta = _musicGroupItem(item);
  final release = meta?.primaryRelease;
  final medium = release?.mediums.firstOrNull;
  final parts = <String>[];
  final format = medium?.mediumType ??
      preview?.variantName ??
      _musicCandidateFormat(candidate);
  if (format != null && format.trim().isNotEmpty) {
    parts.add(format.trim());
  }
  final catalogNumber =
      (release?.catalogNumber ?? preview?.music?['catalog_number'])?.toString();
  if (catalogNumber != null && catalogNumber.trim().isNotEmpty) {
    parts.add(catalogNumber.trim());
  }
  final publisher = release?.publisher ??
      preview?.publisher ??
      _musicCandidatePublisher(candidate);
  if (parts.isEmpty && publisher != null && publisher.trim().isNotEmpty) {
    return publisher.trim();
  }
  return parts.isEmpty ? null : parts.join('  ');
}

String? _musicSupportingLine({
  required CatalogSearchCandidate? item,
  required AdminProviderPreview? preview,
  required ProviderSearchCandidate? candidate,
}) {
  final meta = _musicGroupItem(item);
  final release = meta?.primaryRelease;
  final values = <String>[];
  final publisher = release?.publisher ??
      preview?.publisher ??
      _musicCandidatePublisher(candidate);
  if (publisher != null && publisher.trim().isNotEmpty) {
    values.add(publisher.trim());
  }
  final status =
      (release?.releaseStatus ?? preview?.music?['release_status'])?.toString();
  if (status != null && status.trim().isNotEmpty) {
    values.add(status.trim());
  }
  return values.isEmpty ? null : values.join(' / ');
}

String? _musicAlbumSubtitle({
  required CatalogSearchCandidate? item,
  required AdminProviderPreview? preview,
}) {
  final meta = _musicGroupItem(item);
  final release = meta?.primaryRelease;
  final albumTitle = item?.primaryLabel ?? preview?.title;
  final candidates = <String?>[
    release?.subtitle,
    preview?.publishing?.subtitle,
    preview?.series?.volumeName,
  ];
  for (final candidate in candidates) {
    final value = candidate?.trim();
    if (value == null || value.isEmpty) {
      continue;
    }
    if (albumTitle != null &&
        value.toLowerCase() == albumTitle.trim().toLowerCase()) {
      continue;
    }
    return value;
  }
  final volumeNumber = preview?.series?.volumeNumber;
  final volumeInt = int.tryParse(volumeNumber ?? '');
  if (volumeInt != null && volumeInt > 1) {
    return 'Disc $volumeNumber';
  }
  return null;
}

List<_MusicPreviewTrackData> _musicPreviewTracks({
  required CatalogSearchCandidate? item,
  required AdminProviderPreview? preview,
  ProviderSearchCandidate? candidate,
}) {
  final group = _musicGroupItem(item);
  if (group?.releases.any((release) =>
          release.mediums.any((medium) => medium.tracks.isNotEmpty)) ==
      true) {
    return [
      for (final release in group!.releases)
        for (final medium in release.mediums)
          for (final track in medium.tracks)
            _MusicPreviewTrackData(
              title:
                  track.title.trim().isEmpty ? 'Untitled track' : track.title,
              position: int.tryParse(track.position),
              durationSeconds: track.durationSeconds,
              discNumber: medium.mediumNumber,
              artist: track.artist,
              isHeader: track.isHeader,
              indentLevel: track.indentLevel,
              parentHeaderId: track.parentHeaderId,
            ),
    ];
  }
  if (candidate case final MusicReleaseCandidate release) {
    final tracks = [
      for (final medium in release.mediums)
        for (final track in medium.tracks)
          _MusicPreviewTrackData(
            title: track.title.trim().isEmpty ? 'Untitled track' : track.title,
            position: track.position,
            durationSeconds: track.durationMs == null
                ? null
                : (track.durationMs! / 1000).round(),
            discNumber: medium.mediumNumber,
            artist: track.artist,
            isHeader: track.isHeader,
            indentLevel: track.indentLevel,
            parentHeaderId: track.parentHeaderId,
          ),
    ];
    if (tracks.isNotEmpty) return tracks;
  }
  final previewTracks = preview?.tracks;
  if (previewTracks == null || previewTracks.isEmpty) {
    return const [];
  }
  return [
    for (final track in previewTracks)
      _MusicPreviewTrackData(
        title: (track.title == null || track.title!.trim().isEmpty)
            ? 'Untitled track'
            : track.title!,
        position: int.tryParse(track.position ?? ''),
        durationSeconds: track.durationSeconds,
        discNumber: track.discNumber,
        artist: track.artist,
      ),
  ];
}

List<_MusicPreviewReleaseData> _musicPreviewReleases({
  required CatalogSearchCandidate? item,
  required AdminProviderPreview? preview,
  ProviderSearchCandidate? candidate,
}) {
  final group = _musicGroupItem(item);
  if (group != null && group.releases.isNotEmpty) {
    return [
      for (final release in group.releases)
        _MusicPreviewReleaseData(
          title: release.title,
          releaseDate: release.releaseDate?.toIso8601String().split('T').first,
          country: release.countryCode,
          format: release.mediums.firstOrNull?.mediumType ?? release.packaging,
          barcode: release.barcode ?? release.upc,
          catalogNumber: release.catalogNumber,
          coverUrl:
              _musicReleaseCoverUrl(release.coverImageUrl, release.id.value),
        ),
    ];
  }

  if (candidate case final MusicReleaseGroupCandidate groupCandidate) {
    return [
      for (final release in groupCandidate.releases)
        _MusicPreviewReleaseData(
          title: release.title,
          releaseDate: release.releaseDate?.toIso8601String().split('T').first,
          country: release.country,
          format: release.format ?? release.packaging,
          barcode: release.barcode,
          catalogNumber: release.catalogNumber,
          coverUrl: _musicProviderReleaseCoverUrl(
            provider: groupCandidate.identity.provider,
            releaseId: release.providerItemId,
            explicit: release.images.isEmpty
                ? null
                : release.images.first.url.toString(),
          ),
        ),
    ];
  }

  final rawReleases = preview?.music?['releases'];
  if (rawReleases is! List) return const [];
  return [
    for (final value in rawReleases)
      if (value is Map)
        _MusicPreviewReleaseData(
          title: value['title']?.toString().trim() ?? 'Untitled release',
          releaseDate: value['release_date']?.toString(),
          country:
              value['country_code']?.toString() ?? value['country']?.toString(),
          format: value['format']?.toString() ?? value['packaging']?.toString(),
          barcode: value['barcode']?.toString() ?? value['upc']?.toString(),
          catalogNumber: value['catalog_number']?.toString(),
          coverUrl: _musicProviderReleaseCoverUrl(
            provider: preview?.provider,
            releaseId: value['id']?.toString(),
            explicit: value['cover_image_url']?.toString(),
          ),
        ),
  ];
}

String? _musicReleaseCoverUrl(String? explicit, String releaseId) {
  final value = explicit?.trim();
  if (value != null && value.isNotEmpty) return value;
  final normalized = _musicBrainzReleaseId(releaseId);
  return normalized == null
      ? null
      : 'https://coverartarchive.org/release/$normalized/front-250.jpg';
}

String? _musicProviderReleaseCoverUrl({
  required String? provider,
  required String? releaseId,
  required String? explicit,
}) {
  final value = explicit?.trim();
  if (value != null && value.isNotEmpty) return value;
  if (provider?.trim().toLowerCase() != 'musicbrainz') return null;
  final normalized = _musicBrainzReleaseId(releaseId);
  return normalized == null
      ? null
      : 'https://coverartarchive.org/release/$normalized/front-250.jpg';
}

String? _musicBrainzReleaseId(String? raw) {
  final value = raw?.trim();
  if (value == null || value.isEmpty) return null;
  final normalized = value.startsWith('musicbrainz:')
      ? value.substring('musicbrainz:'.length)
      : value;
  return RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  ).hasMatch(normalized)
      ? normalized
      : null;
}

String? _musicCandidateArtist(ProviderSearchCandidate? candidate) =>
    switch (candidate) {
      MusicReleaseCandidate release => release.artist,
      MusicReleaseGroupCandidate group => group.artist,
      _ => null,
    };

String? _musicCandidatePublisher(ProviderSearchCandidate? candidate) =>
    switch (candidate) {
      MusicReleaseCandidate release => release.publisher,
      MusicReleaseGroupCandidate group => group.releases
          .map((release) => release.publisher)
          .whereType<String>()
          .firstOrNull,
      _ => null,
    };

DateTime? _musicCandidateReleaseDate(ProviderSearchCandidate? candidate) =>
    switch (candidate) {
      MusicReleaseCandidate release => release.releaseDate,
      MusicReleaseGroupCandidate group => group.originalReleaseDate,
      _ => null,
    };

String? _musicCandidateFormat(ProviderSearchCandidate? candidate) =>
    switch (candidate) {
      MusicReleaseCandidate release => release.mediums
          .map((medium) => medium.format)
          .whereType<String>()
          .firstOrNull,
      MusicReleaseGroupCandidate group => group.releases
          .map((release) => release.format ?? release.packaging)
          .whereType<String>()
          .firstOrNull,
      _ => null,
    };

String? _musicCandidateBarcode(ProviderSearchCandidate? candidate) =>
    switch (candidate) {
      MusicReleaseCandidate release => release.barcode,
      MusicReleaseGroupCandidate group => group.releases
          .map((release) => release.barcode)
          .whereType<String>()
          .firstOrNull,
      _ => null,
    };

String? _musicCandidateCatalogNumber(ProviderSearchCandidate? candidate) =>
    switch (candidate) {
      MusicReleaseCandidate release => release.catalogNumber,
      MusicReleaseGroupCandidate group => group.releases
          .map((release) => release.catalogNumber)
          .whereType<String>()
          .firstOrNull,
      _ => null,
    };

List<String> _musicCandidateGenres(ProviderSearchCandidate? candidate) =>
    switch (candidate) {
      MusicReleaseCandidate release => release.genres,
      MusicReleaseGroupCandidate group => group.genres,
      _ => const <String>[],
    };

int? _musicCandidateTrackCount(ProviderSearchCandidate? candidate) =>
    switch (candidate) {
      MusicReleaseCandidate release => release.mediums.fold<int>(
          0,
          (total, medium) =>
              total + (medium.trackCount ?? medium.tracks.length),
        ),
      _ => null,
    };

String _musicDateLabel(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

MusicReleaseCandidate _musicReleaseCandidateFromSummary({
  required MusicReleaseGroupCandidate group,
  required MusicReleaseSummaryCandidate release,
}) {
  return MusicReleaseCandidate(
    identity: ProviderEntityIdentity(
      provider: group.provider,
      externalId: release.providerItemId,
      scope: LibraryEntityScope.release,
    ),
    title: release.title,
    releaseGroupId: group.identity.externalId,
    releaseGroupTitle: group.title,
    artist: group.artist,
    releaseDate: release.releaseDate,
    country: release.country,
    barcode: release.barcode,
    publisher: release.publisher,
    catalogNumber: release.catalogNumber,
    releaseStatus: release.status,
    packaging: release.packaging,
    mediums: release.format == null
        ? const <MusicMediumCandidate>[]
        : [MusicMediumCandidate(mediumNumber: 1, format: release.format)],
    provenance: group.provenance,
    images: release.images.isEmpty ? group.images : release.images,
    attribution: group.attribution,
  );
}

MusicReleaseCandidate? _musicReleaseCandidateFromPreview({
  required MusicReleaseGroupCandidate group,
  required Map<String, dynamic> value,
  required AdminProviderPreview preview,
}) {
  final providerItemId = value['id']?.toString().trim() ?? '';
  final title = value['title']?.toString().trim() ?? '';
  if (providerItemId.isEmpty || title.isEmpty) return null;
  final mediumTypes = _providerPreviewMediumTypes(value);
  return MusicReleaseCandidate(
    identity: ProviderEntityIdentity(
      provider: group.provider,
      externalId: providerItemId,
      scope: LibraryEntityScope.release,
    ),
    title: title,
    releaseGroupId: group.identity.externalId,
    releaseGroupTitle: group.title,
    artist: group.artist ?? preview.music?['artist']?.toString().trim(),
    releaseDate: DateTime.tryParse(value['release_date']?.toString() ?? ''),
    country: value['country_code']?.toString().trim(),
    barcode:
        value['barcode']?.toString().trim() ?? value['upc']?.toString().trim(),
    publisher:
        value['publisher']?.toString().trim() ?? preview.publisher?.trim(),
    catalogNumber: value['catalog_number']?.toString().trim(),
    releaseStatus: value['status']?.toString().trim(),
    packaging: value['packaging']?.toString().trim(),
    mediums: [
      for (var index = 0; index < mediumTypes.length; index++)
        MusicMediumCandidate(
            mediumNumber: index + 1, format: mediumTypes[index]),
    ],
    provenance: group.provenance,
    images: _musicPreviewImages(
      provider: group.provider,
      releaseId: providerItemId,
      imageUrl: value['cover_image_url']?.toString(),
      fallback: group.images,
    ),
    attribution: group.attribution,
  );
}

List<ProviderImageCandidate> _musicPreviewImages({
  required String provider,
  required String releaseId,
  required String? imageUrl,
  required List<ProviderImageCandidate> fallback,
}) {
  final text = imageUrl?.trim();
  final uri = text == null || text.isEmpty ? null : Uri.tryParse(text);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) return fallback;
  return [
    ProviderImageCandidate(
      url: uri,
      source: ProviderEntityIdentity(
        provider: provider,
        externalId: releaseId,
        scope: LibraryEntityScope.release,
      ),
      role: 'cover',
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
        label: singleDisc == null ? null : 'Disc $singleDisc',
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
    if (!track.isHeader && track.durationSeconds != null) {
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
