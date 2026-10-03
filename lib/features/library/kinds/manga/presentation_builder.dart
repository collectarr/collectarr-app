import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/manga/catalog/manga_catalog_fields.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/config/library_duplicate_presentation.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_physical_media_formats.dart';
import 'package:collectarr_app/features/library/widgets/format_badge.dart';

class MangaLibraryMediaPresentationBuilder
    extends LibraryMediaPresentationBuilder {
  const MangaLibraryMediaPresentationBuilder({
    this.showSummary = false,
    this.metadataLabels = const LibraryMetadataLabels(),
    this.itemNumberLabel = 'Number',
    this.publisherLabel = 'Publisher',
    this.variantLabel = 'Variant',
    this.barcodeLabel = 'Barcode',
  });

  final bool showSummary;
  final LibraryMetadataLabels metadataLabels;
  final String itemNumberLabel;
  final String publisherLabel;
  final String variantLabel;
  final String barcodeLabel;

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
    final format = item.kindCapability.mapTransport(
      (transport) => MangaMetadata.fromJson(transport.kindData),
    );
    final badge = mangaFormatBadge(
      format.physicalFormat,
      label: format.physicalFormatLabel,
    );
    if (badge != null && seen.add(badge.key)) result.add(badge);
    return result;
  }

  @override
  List<LibraryDuplicateCandidate> buildDuplicateCandidates(
    LibraryWorkspaceSource entry,
  ) {
    final catalog = entry.catalogData;
    if (catalog is! MangaWorkspaceCatalogData) return const [];
    final item = catalog.metadata;
    final candidates = <LibraryDuplicateCandidate>[];
    final entryLabel = [
      item.title,
      if (item.itemNumber?.trim() case final value? when value.isNotEmpty)
        '#$value',
    ].join(' ');
    final identifier =
        normalizeLibraryDuplicateIdentifier(item.barcode ?? item.isbn);
    if (identifier != null) {
      candidates.add(
        LibraryDuplicateCandidate(
          key: 'barcode:$identifier',
          label: 'Barcode ${identifier.trim()}',
          reason: 'Same barcode',
          confidenceScore: 78,
          entryLabel: entryLabel,
        ),
      );
    }
    final title = normalizeLibraryDuplicateToken(item.title);
    final issue = normalizeLibraryDuplicateToken(item.itemNumber);
    if (title == null || issue == null) return candidates;
    final publisher = normalizeLibraryDuplicateToken(item.publisher) ?? '';
    final year = (item.localizedReleaseDate ?? item.originalPublicationDate)
            ?.year
            .toString() ??
        '';
    final variant = normalizeLibraryDuplicateToken(item.variant) ?? '';
    final labelParts = [
      item.title,
      '#${item.itemNumber!.trim()}',
      if (item.publisher?.trim() case final value? when value.isNotEmpty) value,
      if (year.isNotEmpty) year,
      if (item.variant?.trim() case final value? when value.isNotEmpty) value,
    ];
    var confidenceScore = 52;
    if (publisher.isNotEmpty) confidenceScore += 4;
    if (year.isNotEmpty) confidenceScore += 3;
    if (variant.isNotEmpty) confidenceScore += 2;
    candidates.add(
      LibraryDuplicateCandidate(
        key: 'issue:$title|$issue|$publisher|$year|$variant',
        label: labelParts.join(' - '),
        reason: 'Same issue metadata',
        confidenceScore: confidenceScore,
        entryLabel: entryLabel,
      ),
    );
    return candidates;
  }

  @override
  CatalogSearchCandidate mergeHydratedAddItem({
    required CatalogSearchCandidate hydrated,
    required CatalogSearchCandidate fallback,
  }) {
    final hydratedMetadata = hydrated.mangaCatalogFields;
    final fallbackMetadata = fallback.mangaCatalogFields;
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
      item.mangaCatalogFields.synopsis;

  @override
  List<String> buildCatalogSearchAliases({
    required CatalogSearchCandidate item,
  }) =>
      item.mangaCatalogFields.searchAliases;

  @override
  LibraryAddSearchResultDisplay? buildSearchResultDisplay({
    required CatalogSearchCandidate item,
  }) =>
      _buildMangaSearchResultDisplay(item);

  @override
  List<(String, String?)> buildAddPreviewMetadataRows({
    required CatalogSearchCandidate item,
    required LibraryMediaPreviewLabels previewLabels,
  }) {
    final releaseDate = item.mangaCatalogFields.releaseDate;
    return [
      (
        previewLabels.labelFor('publisher', fallback: 'Publisher'),
        item.kindCapability.mapTransport((transport) => transport).publisher
      ),
      (
        'Released',
        releaseDate == null
            ? item.mangaCatalogFields.releaseYear?.toString()
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
    final adapter = dto is MangaWorkspaceDto ? dto : null;
    final mangaDto = dto is MangaWorkspaceDto ? dto : null;
    final itemNumber = adapter?.itemNumber;
    final variant = adapter?.variant;
    final barcode = mangaDto?.barcode;
    final publisher = mangaDto?.publisher;
    final releaseDate = adapter?.releaseDate;
    final country = adapter?.country;
    final language = adapter?.language;
    final catalog = item.source.catalogData;
    final metadata =
        catalog is MangaWorkspaceCatalogData ? catalog.metadata : null;
    final series = metadata?.series;
    const CatalogPublishingDetailsDto? publishing = null;
    const String? musicCatalogNumber = null;
    const String? musicAlbumStatus = null;
    const String? ageRating = null;
    const String? audienceRating = null;
    final hasVolume = series?.hasVolume ?? false;
    final hasSeason = series?.hasSeason ?? false;
    final hasEpisode = series?.hasEpisode ?? false;
    return LibraryMetadataPresentation(
      labels: metadataLabels,
      identityFacts: [
        if (includeIdentityFacts) ...[
          LibraryDetailField(label: 'Kind', value: singularLabel),
          LibraryDetailField(label: 'ID', value: item.node.catalogItemId),
          LibraryDetailField(label: 'Title', value: dto.primaryLabel),
        ],
        if (series?.seriesTitle != null)
          LibraryDetailField(
              label: 'Series',
              value: series!.seriesTitle!,
              onTap: tapFor(series.seriesTitle)),
        if (hasVolume && !hasSeason)
          LibraryDetailField(
              label: 'Volume',
              value: series!.volumeName ??
                  _mangaVolumeLabel(series.volumeNumber != null
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
            label: itemNumberLabel,
            value: genericLibraryDash(itemNumber),
            onTap: tapFor(itemNumber)),
        LibraryDetailField(
            label: variantLabel,
            value: genericLibraryDash(variant),
            onTap: tapFor(variant)),
        LibraryDetailField(
            label: barcodeLabel, value: genericLibraryDash(barcode)),
      ],
      contextFacts: [
        LibraryDetailField(
            label: publisherLabel,
            value: genericLibraryDash(publisher),
            onTap: tapFor(publisher)),
        LibraryDetailField(
            label: 'Released',
            value: genericLibraryDash(
              formatPresentationNullableDate(releaseDate) ??
                  releaseDate?.year.toString(),
            )),
        if (publishing?.pageCount != null)
          LibraryDetailField(
              label: 'Pages', value: publishing!.pageCount.toString()),
        if (musicCatalogNumber != null)
          LibraryDetailField(label: 'Catalog No.', value: musicCatalogNumber),
        if (publishing?.coverPriceCents != null)
          LibraryDetailField(
              label: 'Cover Price',
              value: formatPresentationMoney(
                publishing!.coverPriceCents,
                publishing.currency,
              )),
        if (publishing?.imprint != null)
          LibraryDetailField(
              label: 'Imprint',
              value: publishing!.imprint!,
              onTap: tapFor(publishing.imprint)),
        if (publishing?.seriesGroup != null)
          LibraryDetailField(
              label: 'Series Group',
              value: publishing!.seriesGroup!,
              onTap: tapFor(publishing.seriesGroup)),
        if (publishing?.subtitle != null)
          LibraryDetailField(label: 'Subtitle', value: publishing!.subtitle!),
        if (country != null)
          LibraryDetailField(label: 'Country', value: country),
        if (musicAlbumStatus != null)
          LibraryDetailField(label: 'Release Status', value: musicAlbumStatus),
        if (language != null)
          LibraryDetailField(label: 'Language', value: language),
        if (ageRating != null)
          LibraryDetailField(label: 'Age Rating', value: ageRating),
        if (audienceRating != null)
          LibraryDetailField(label: 'Audience Rating', value: audienceRating),
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
        'characters': LibraryMetadataSection(
          values: const <String>[],
          placement: LibraryMetadataSectionPlacement.credits,
          completenessWeight: 6,
        ),
        'story_arcs': LibraryMetadataSection(
          values: const <String>[],
          placement: LibraryMetadataSectionPlacement.credits,
          inlineLabelKey: 'story_arcs_inline',
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

String _mangaVolumeLabel(double? volumeNumber) {
  if (volumeNumber == null) return 'Vol. -';
  final rounded = volumeNumber.roundToDouble();
  final value = (volumeNumber - rounded).abs() < 1e-9
      ? rounded.toInt().toString()
      : volumeNumber.toString();
  return 'Vol. $value';
}

LibraryAddSearchResultDisplay _buildMangaSearchResultDisplay(
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
    if ((item.mangaCatalogFields.releaseYear ??
            item.mangaCatalogFields.releaseDate?.year)
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
    year: item.mangaCatalogFields.releaseYear ??
        item.mangaCatalogFields.releaseDate?.year,
    detailLine: null,
  );
}
