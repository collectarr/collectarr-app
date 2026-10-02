import 'package:collectarr_app/features/library/kinds/movie/catalog/movie_catalog_fields.dart';
import 'package:collectarr_app/features/library/config/library_duplicate_presentation.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_physical_media_formats.dart';
import 'package:collectarr_app/features/library/widgets/format_badge.dart';

class MovieLibraryMediaPresentationBuilder
    extends LibraryMediaPresentationBuilder {
  const MovieLibraryMediaPresentationBuilder({
    this.showSummary = false,
    this.metadataLabels = const LibraryMetadataLabels(),
  });

  final bool showSummary;
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
    final transport =
        item.kindCapability.mapTransport((transport) => transport);
    final badge = movieFormatBadge(
      transport.physicalFormat,
      label: transport.physicalFormatLabel,
    );
    return badge == null ? const [] : [badge];
  }

  @override
  List<LibraryDuplicateCandidate> buildDuplicateCandidates(
    LibraryWorkspaceSource entry,
  ) {
    final catalog = entry.catalogData;
    if (catalog is! MovieWorkspaceCatalogData) return const [];
    final item = catalog.movie;
    final identifier = normalizeLibraryDuplicateIdentifier(item.barcode);
    if (identifier == null) return const [];
    return [
      LibraryDuplicateCandidate(
        key: 'identifier:$identifier',
        label: 'Identifier ${item.barcode!.trim()}',
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
    if (catalog is! MovieWorkspaceCatalogData) return const [];
    // This Catalog Item already represents the concrete Movie edition.
    // Disc/media rows are contained children, not another release level.
    return const [];
  }

  @override
  List<LibraryWorkspaceLinkSummary> buildWorkspaceLinks(
    LibraryWorkspaceSource entry,
  ) {
    final catalog = entry.catalogData;
    if (catalog is! MovieWorkspaceCatalogData) return const [];
    return [
      for (final link in catalog.movie.externalLinks)
        if (link['url']?.toString().trim() case final url? when url.isNotEmpty)
          LibraryWorkspaceLinkSummary(
            url: url,
            label: (link['title'] ?? link['label'])?.toString(),
            source: (link['site'] ?? link['source'])?.toString(),
            isTrailer:
                link['link_type'] != 'external' && link['link_type'] != 'link',
          ),
      for (final link in catalog.movie.trailerUrls)
        if (link['url']?.toString().trim() case final url? when url.isNotEmpty)
          LibraryWorkspaceLinkSummary(
            url: url,
            label: link['title']?.toString(),
            source: link['site']?.toString(),
          ),
    ];
  }

  @override
  List<LibraryAddReleaseOption> buildReleaseOptions({
    required CatalogSearchCandidate item,
  }) {
    final itemDto = item.kindCapability.mapTransport((transport) => transport);
    return [
      LibraryAddReleaseOption(
        id: itemDto.id,
        title: itemDto.title,
        formatId: itemDto.physicalFormat,
        formatLabel: itemDto.physicalFormatLabel,
        formatBadge: movieFormatBadge(
          itemDto.physicalFormat,
          label: itemDto.physicalFormatLabel,
        ),
        releaseDate: itemDto.releaseDate,
        coverImageUrl: itemDto.coverImageUrl,
        identifierCode: itemDto.barcode,
      ),
    ];
  }

  @override
  CatalogSearchCandidate mergeHydratedAddItem({
    required CatalogSearchCandidate hydrated,
    required CatalogSearchCandidate fallback,
  }) {
    final hydratedMetadata = hydrated.movieCatalogFields;
    final fallbackMetadata = fallback.movieCatalogFields;
    final coverImageUrl =
        hydratedMetadata.coverImageUrl ?? fallbackMetadata.coverImageUrl;
    final thumbnailImageUrl = hydratedMetadata.coverImageUrl != null
        ? hydratedMetadata.thumbnailImageUrl
        : fallbackMetadata.thumbnailImageUrl ?? fallbackMetadata.coverImageUrl;
    return CatalogSearchCandidate.fromItem(
        hydrated.kindCapability.mapTransport((transport) => transport.copyWith(
              coverImageUrl: coverImageUrl,
              thumbnailImageUrl: thumbnailImageUrl,
            )));
  }

  @override
  String? buildAddPreviewSynopsis({required CatalogSearchCandidate item}) =>
      item.movieCatalogFields.synopsis;

  @override
  List<String> buildCatalogSearchAliases({
    required CatalogSearchCandidate item,
  }) =>
      item.movieCatalogFields.searchAliases;

  @override
  LibraryAddSearchResultDisplay? buildSearchResultDisplay({
    required CatalogSearchCandidate item,
  }) =>
      _buildMovieSearchResultDisplay(item);

  @override
  List<(String, String?)> buildAddPreviewMetadataRows({
    required CatalogSearchCandidate item,
    required LibraryMediaPreviewLabels previewLabels,
  }) {
    final releaseDate = item.movieCatalogFields.releaseDate;
    return [
      (
        previewLabels.labelFor('publisher', fallback: 'Publisher'),
        item.kindCapability.mapTransport((transport) => transport).publisher
      ),
      (
        'Released',
        releaseDate == null
            ? item.movieCatalogFields.releaseYear?.toString()
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
    final adapter = dto is MovieWorkspaceDto ? dto : null;
    final movieDto = dto is MovieWorkspaceDto ? dto : null;
    final itemNumber = adapter?.itemNumber;
    final variant = adapter?.variant;
    final barcode = movieDto?.barcode;
    final publisher = movieDto?.publisher;
    final releaseDate = adapter?.releaseDate;
    final country = adapter?.country;
    final language = adapter?.language;

    final metadata = item.source.catalogData is MovieWorkspaceCatalogData
        ? (item.source.catalogData! as MovieWorkspaceCatalogData).metadata
        : null;
    final series = metadata?.series;
    final video = metadata?.video;
    final hasVolume = series?.hasVolume ?? false;
    final hasSeason = series?.hasSeason ?? false;
    final hasEpisode = series?.hasEpisode ?? false;
    final runtime = metadata?.runtimeMinutes ??
        (video?['runtime_minutes'] as num?)?.toInt();
    final screenRatio = (video?['screen_ratio'] as String?)?.trim();
    final audioTracks = (video?['audio_tracks'] as String?)?.trim();
    final subtitles = (video?['subtitles'] as String?)?.trim();
    return LibraryMetadataPresentation(
      labels: metadataLabels,
      identityFacts: [
        if (includeIdentityFacts) ...[
          LibraryDetailField(label: 'Kind', value: singularLabel),
          LibraryDetailField(label: 'ID', value: item.node.catalogItemId),
          LibraryDetailField(label: 'Title', value: dto.primaryLabel),
        ],
        if (metadata?.editionTitle != null)
          LibraryDetailField(label: 'Edition', value: metadata!.editionTitle!),
        if (metadata?.originalTitle != null)
          LibraryDetailField(
              label: 'Original Title', value: metadata!.originalTitle!),
        if (metadata?.sortTitle != null)
          LibraryDetailField(label: 'Sort Title', value: metadata!.sortTitle!),
        if (series?.seriesTitle != null)
          LibraryDetailField(
              label: 'Series',
              value: series!.seriesTitle!,
              onTap: tapFor(series.seriesTitle)),
        if (hasVolume && !hasSeason)
          LibraryDetailField(
              label: 'Volume',
              value: series!.volumeName ??
                  _movieVolumeLabel(series.volumeNumber != null
                      ? double.tryParse(series.volumeNumber!)
                      : null)),
        if (hasSeason && hasEpisode)
          LibraryDetailField(
              label: 'Season / Episode',
              value:
                  'Season ${series!.seasonNumber}, Ep. ${series.episodeNumber}'),
        if (hasSeason && !hasEpisode)
          LibraryDetailField(
              label: 'Season', value: 'Season ${series!.seasonNumber}'),
        if (hasEpisode && !hasSeason)
          LibraryDetailField(
              label: 'Episode', value: 'Ep. ${series!.episodeNumber}'),
        LibraryDetailField(
            label: 'Edition no.',
            value: genericLibraryDash(itemNumber),
            onTap: tapFor(itemNumber)),
        LibraryDetailField(
            label: 'Format / Edition',
            value: genericLibraryDash(variant),
            onTap: tapFor(variant)),
        LibraryDetailField(
            label: 'UPC / Barcode', value: genericLibraryDash(barcode)),
      ],
      contextFacts: [
        LibraryDetailField(
            label: 'Studio',
            value: genericLibraryDash(publisher),
            onTap: tapFor(publisher)),
        LibraryDetailField(
            label: 'Released',
            value: genericLibraryDash(
              formatPresentationNullableDate(releaseDate) ??
                  releaseDate?.year.toString(),
            )),
        if (runtime != null)
          LibraryDetailField(label: 'Runtime', value: '$runtime min'),
        if (screenRatio != null && screenRatio.isNotEmpty)
          LibraryDetailField(label: 'Aspect Ratio', value: screenRatio),
        if (audioTracks != null && audioTracks.isNotEmpty)
          LibraryDetailField(label: 'Audio', value: audioTracks),
        if (subtitles != null && subtitles.isNotEmpty)
          LibraryDetailField(label: 'Subtitles', value: subtitles),
        if (country != null)
          LibraryDetailField(
              label: 'Country', value: country, onTap: tapFor(country)),
        if (language != null)
          LibraryDetailField(
              label: 'Language', value: language, onTap: tapFor(language)),
        if (metadata?.ageRating != null)
          LibraryDetailField(
              label: 'Age Rating',
              value: metadata!.ageRating!,
              onTap: tapFor(metadata.ageRating)),
        if (metadata?.audienceRating != null)
          LibraryDetailField(
              label: 'Audience Rating',
              value: metadata!.audienceRating!,
              onTap: tapFor(metadata.audienceRating)),
        LibraryDetailField(
            label: 'Cover',
            value: dto.imageUrl == null || dto.imageUrl!.isEmpty
                ? 'Missing'
                : 'Ready'),
        LibraryDetailField(
            label: 'Metadata',
            value:
                publisher == null || publisher.isEmpty ? 'Missing' : 'Ready'),
      ],
      sections: {
        'creators': LibraryMetadataSection(
          values: metadata?.creators ?? const <Map<String, dynamic>>[],
          placement: LibraryMetadataSectionPlacement.credits,
          renderer: LibraryMetadataSectionRenderer.credits,
          completenessWeight: 12,
        ),
        'genres': LibraryMetadataSection(
          values: metadata?.genres ?? const <String>[],
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
    final synopsis = libraryWorkspaceCatalogSynopsis(item.source.catalogData);
    if (!showSummary || synopsis == null || synopsis.trim().isEmpty) {
      return const [];
    }
    return [
      LibraryDetailSection(
        title: 'Summary',
        accentColor: accent,
        children: [
          Text(
            synopsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    ];
  }
}

String _movieVolumeLabel(double? volumeNumber) {
  if (volumeNumber == null) return 'Vol. -';
  final rounded = volumeNumber.roundToDouble();
  final value = (volumeNumber - rounded).abs() < 1e-9
      ? rounded.toInt().toString()
      : volumeNumber.toString();
  return 'Vol. $value';
}

LibraryAddSearchResultDisplay _buildMovieSearchResultDisplay(
  CatalogSearchCandidate item,
) {
  final itemNumber = item.kindCapability
      .mapTransport((transport) => transport)
      .itemNumber
      ?.trim();
  final subtitle = [
    if (item.kindCapability
            .mapTransport((transport) => transport)
            .publisher
            ?.trim()
        case final value? when value.isNotEmpty)
      value,
    if ((item.movieCatalogFields.releaseYear ??
            item.movieCatalogFields.releaseDate?.year)
        case final year?)
      year.toString(),
    if (item.kindCapability
            .mapTransport((transport) => transport)
            .physicalFormatLabel
            ?.trim()
        case final value? when value.isNotEmpty)
      value,
    if (item.kindCapability
            .mapTransport((transport) => transport)
            .identifierCode
            ?.trim()
        case final value? when value.isNotEmpty)
      value,
  ].join(' | ');
  return LibraryAddSearchResultDisplay(
    title: itemNumber == null || itemNumber.isEmpty
        ? item.summary.primaryLabel
        : '${item.summary.primaryLabel} #$itemNumber',
    secondaryLine: subtitle.isEmpty ? null : subtitle,
    year: item.movieCatalogFields.releaseYear ??
        item.movieCatalogFields.releaseDate?.year,
    detailLine: null,
  );
}
