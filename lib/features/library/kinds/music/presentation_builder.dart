import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_fields.dart';

import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_duplicate_presentation.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/kinds/music/inspector/music_inspector_track_list.dart';
import 'package:collectarr_app/features/library/kinds/music/inspector/music_inspector_view_model.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_catalog_candidate_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/music/music_country_name.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album_relations.dart';
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
      null;

  @override
  List<LibraryFormatBadgeDescriptor> buildAddPreviewFormatBadges({
    required CatalogSearchCandidate item,
  }) {
    final format = musicCatalogItemFromCandidate(item).format;
    final badge = musicFormatBadge(format?.toLowerCase(), label: format);
    return badge == null ? const [] : [badge];
  }

  @override
  List<LibraryDuplicateCandidate> buildDuplicateCandidates(
    LibraryWorkspaceSource entry,
  ) {
    final catalog = entry.catalogData;
    if (catalog is! MusicWorkspaceCatalogData) return const [];
    final item = catalog.music;
    final identifier = normalizeLibraryDuplicateIdentifier(
      item.barcode ?? item.upc,
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
  CatalogSearchCandidate mergeHydratedAddItem({
    required CatalogSearchCandidate hydrated,
    required CatalogSearchCandidate fallback,
  }) {
    final hydratedMetadata = hydrated.musicCatalogFields;
    final fallbackMetadata = fallback.musicCatalogFields;
    final coverImageUrl =
        hydratedMetadata.coverImageUrl ?? fallbackMetadata.coverImageUrl;
    final thumbnailImageUrl = hydratedMetadata.coverImageUrl != null
        ? hydratedMetadata.thumbnailImageUrl
        : fallbackMetadata.thumbnailImageUrl ?? fallbackMetadata.coverImageUrl;
    return CatalogSearchCandidate.fromItem(
      hydrated.kindCapability.mapTransport((transport) {
        final metadata = MusicAlbum.fromJson({
          ...transport.kindData,
          'id': transport.id,
          'kind': transport.kind,
        });
        final updated = MusicAlbum.fromJson({
          ...applyJsonFieldPatch(metadata, {
            'cover_image_url': coverImageUrl,
            'thumbnail_image_url': thumbnailImageUrl,
          }),
          'id': transport.id,
          'kind': transport.kind,
        });
        return transport.replacingKindData(updated);
      }),
    );
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
    final album = musicCatalogItemFromCandidate(item);
    final artist = album.artist?.trim();
    final format = album.format?.trim();
    final trackCount = album.mediums.isEmpty ? null : album.trackCount;
    final country = album.countryCode?.trim();
    final label = album.publisher?.trim();
    final catalogNumber = album.catalogNumber?.trim();
    final barcode = album.barcode?.trim();
    final detailParts = <String>[
      if (format != null && format.isNotEmpty) format,
      if (country != null && country.isNotEmpty) country,
      if (label != null && label.isNotEmpty) label,
      if (trackCount != null)
        '$trackCount ${trackCount == 1 ? 'track' : 'tracks'}',
      if (barcode != null && barcode.isNotEmpty) barcode,
      if (catalogNumber != null && catalogNumber.isNotEmpty) catalogNumber,
    ];
    return LibraryAddSearchResultDisplay(
      title: album.title,
      secondaryLine: artist?.isNotEmpty == true ? artist : null,
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
    final album = musicCatalogItemFromCandidate(item);
    return [
      (
        previewLabels.labelFor('label', fallback: 'Label'),
        album.publisher,
      ),
      (
        'Released',
        album.releaseDateParts?.isoString ??
            album.releaseDate?.year.toString() ??
            item.musicCatalogFields.releaseYear?.toString(),
      ),
      ('Format', album.format),
      ('Country', album.countryCode),
      ('Cat No', album.catalogNumber),
      (
        previewLabels.labelFor('barcode', fallback: 'Barcode'),
        album.barcode,
      ),
      if (album.mediums.isNotEmpty)
        (
          'Tracks',
          album.trackCount.toString(),
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
    final album = _musicCatalogItem(item);
    final medium = album?.mediums.firstOrNull;
    final artist = album?.artist;
    final barcode = album?.barcode ?? album?.upc;
    final publisher = album?.publisher;
    final releaseDate = album?.releaseDate;
    final country = musicCountryName(album?.countryCode);
    final language = album?.language;

    return LibraryMetadataPresentation(
      labels: metadataLabels,
      identityFacts: [
        if (includeIdentityFacts) ...[
          LibraryDetailField(label: 'Kind', value: singularLabel),
          LibraryDetailField(label: 'ID', value: item.node.catalogItemId),
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
        if (album?.catalogNumber != null)
          LibraryDetailField(
            label: 'Catalog #',
            value: album!.catalogNumber!,
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
        if (album?.trackCount != null)
          LibraryDetailField(
              label: 'Tracks', value: album!.trackCount.toString()),
        if (album?.mediums.isNotEmpty == true)
          LibraryDetailField(
              label: 'Disc count', value: album!.mediums.length.toString()),
        if (album?.catalogNumber != null)
          LibraryDetailField(label: 'Catalog #', value: album!.catalogNumber!),
        if (album?.releaseStatus != null)
          LibraryDetailField(
              label: 'Release Status', value: album!.releaseStatus!),
        if (country != null)
          LibraryDetailField(label: 'Country', value: country),
        if (language != null)
          LibraryDetailField(label: 'Language', value: language),
        if (album?.tracks.isNotEmpty == true)
          LibraryDetailField(label: 'Length', value: _musicDuration(album!)),
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
            label: 'Metadata', value: album == null ? 'Missing' : 'Ready'),
      ],
      sections: {
        'creators': LibraryMetadataSection(
          values: [
            for (final contribution
                in album?.contributions ?? const <MusicAlbumContribution>[])
              contribution.toJson(),
          ],
          placement: LibraryMetadataSectionPlacement.credits,
          renderer: LibraryMetadataSectionRenderer.credits,
          completenessWeight: 12,
        ),
        'genres': LibraryMetadataSection(
          values: album?.genres ?? const <String>[],
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
    final trackCount = model.music.trackCount;
    if (trackCount <= 0) return const <Widget>[];
    return [
      MusicInspectorTrackListUnavailable(
        trackCount: trackCount,
        accent: accent,
      ),
    ];
  }
}

MusicAlbum? _musicCatalogItem(LibraryProjectionView item) {
  final catalog = item.source.catalogData;
  return catalog is MusicWorkspaceCatalogData ? catalog.music : null;
}

String _musicDuration(MusicAlbum item) {
  final totalSeconds = item.tracks.fold<int>(
    0,
    (total, track) => total + (track.durationMs ?? 0) ~/ 1000,
  );
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
