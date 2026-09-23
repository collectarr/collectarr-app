import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/manga/catalog/manga_catalog_fields.dart';
import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/features/library/config/library_duplicate_presentation.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/manga/provider/manga_provider_candidates.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
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
    for (final edition in item.kindCapability
        .mapTransport((transport) => transport)
        .editions) {
      final badge = mangaFormatBadge(
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
  List<LibraryWorkspaceReleaseSummary> buildWorkspaceReleases(
    LibraryWorkspaceSource entry,
  ) {
    final catalog = entry.catalogData;
    if (catalog is! MangaWorkspaceCatalogData) return const [];
    return [
      for (final edition in catalog.metadata.editions)
        LibraryWorkspaceReleaseSummary(
          id: edition.id,
          title: edition.title,
          formatLabel: edition.physicalFormatLabel ?? edition.physicalFormat,
          formatBadge: mangaFormatBadge(
            edition.physicalFormat,
            label: edition.physicalFormatLabel,
          ),
          releaseDate: edition.releaseDate,
          variantCount: edition.variants.length,
          variants: [
            for (final variant in edition.variants)
              LibraryWorkspaceVariantSummary(
                id: variant.id,
                name: variant.name,
                coverImageUrl: variant.coverImageUrl,
                thumbnailImageUrl: variant.thumbnailImageUrl,
                formatLabel:
                    variant.physicalFormatLabel ?? variant.physicalFormat,
                formatBadge: mangaFormatBadge(
                  variant.physicalFormat,
                  label: variant.physicalFormatLabel,
                ),
              ),
          ],
          mediaLabels: [
            for (final disc in edition.discs)
              disc.discName ??
                  (disc.discNumber == null
                      ? 'Media'
                      : 'Disc \${disc.discNumber}'),
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
          formatBadge: mangaFormatBadge(
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
                formatBadge: mangaFormatBadge(
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
  Map<String, dynamic> buildProviderProposalPayload({
    required CatalogSearchCandidate item,
  }) =>
      item.kindCapability
          .mapTransport((transport) => transport.toSyncPayload());

  @override
  CatalogSearchCandidate mergeProviderAddResult({
    required CatalogSearchCandidate ingested,
    required CatalogSearchCandidate edited,
  }) {
    final ingestedMetadata = ingested.mangaCatalogFields;
    final editedMetadata = edited.mangaCatalogFields;
    final merged = CatalogSearchCandidate.fromItem(
        ingested.kindCapability.mapTransport((transport) => transport.copyWith(
              title: edited.summary.primaryLabel,
              displayTitle:
                  editedMetadata.displayTitle ?? ingestedMetadata.displayTitle,
              localizedTitle: editedMetadata.localizedTitle ??
                  ingestedMetadata.localizedTitle,
              originalTitle: editedMetadata.originalTitle ??
                  ingestedMetadata.originalTitle,
              searchAliases: editedMetadata.searchAliases.isNotEmpty
                  ? editedMetadata.searchAliases
                  : ingestedMetadata.searchAliases,
              sortKey: editedMetadata.sortKey ?? ingestedMetadata.sortKey,
              synopsis: editedMetadata.synopsis ?? ingestedMetadata.synopsis,
              coverImageUrl: editedMetadata.coverImageUrl ??
                  ingestedMetadata.coverImageUrl,
              thumbnailImageUrl: editedMetadata.thumbnailImageUrl ??
                  ingestedMetadata.thumbnailImageUrl,
              coverImageData: editedMetadata.coverImageData ??
                  ingestedMetadata.coverImageData,
            )));
    return edited.kindCapability.mapTransport(
      (transport) => CatalogSearchCandidate.fromItem(
        merged.kindCapability.mapTransport(
          (mergedTransport) =>
              mergedTransport.withKindMetadata(transport.kindMetadata),
        ),
      ),
    );
  }

  @override
  CatalogSearchCandidate mergeHydratedAddItem({
    required CatalogSearchCandidate hydrated,
    required CatalogSearchCandidate fallback,
  }) {
    final hydratedMetadata = hydrated.mangaCatalogFields;
    final fallbackMetadata = fallback.mangaCatalogFields;
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
  List<(String, String?)> buildAddPreviewMetadataRowsForCandidate({
    required ProviderSearchCandidate candidate,
    required LibraryMediaPreviewLabels previewLabels,
  }) {
    if (candidate is! MangaProviderCandidate) return const [];
    return [
      if (candidate.series?.seriesTitle != null)
        (
          previewLabels.labelFor('series', fallback: 'Series'),
          candidate.series!.seriesTitle
        ),
      if (candidate.issueNumber != null)
        (
          previewLabels.labelFor('item_number', fallback: 'Number'),
          candidate.issueNumber
        ),
      if (candidate.publisher != null)
        (
          previewLabels.labelFor('publisher', fallback: 'Publisher'),
          candidate.publisher
        ),
      if (candidate.series?.volumeStartYear != null)
        ('Year', candidate.series!.volumeStartYear.toString()),
      if (candidate.variantName != null)
        (
          previewLabels.labelFor('variant', fallback: 'Variant'),
          candidate.variantName
        ),
      if (candidate.issueCount != null)
        (
          previewLabels.labelFor('item_count', fallback: 'Items'),
          candidate.issueCount.toString()
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
    const String? musicReleaseStatus = null;
    const String? ageRating = null;
    const String? audienceRating = null;
    final referenceRelease = _mangaReferenceRelease(item);
    final referenceVariant = referenceRelease.variant;
    final hasVolume = series?.hasVolume ?? false;
    final hasSeason = series?.hasSeason ?? false;
    final hasEpisode = series?.hasEpisode ?? false;
    return LibraryMetadataPresentation(
      labels: metadataLabels,
      identityFacts: [
        if (includeIdentityFacts) ...[
          LibraryDetailField(label: 'Kind', value: singularLabel),
          LibraryDetailField(label: 'ID', value: item.node.workId),
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
        if (musicReleaseStatus != null)
          LibraryDetailField(
              label: 'Release Status', value: musicReleaseStatus),
        if (language != null)
          LibraryDetailField(label: 'Language', value: language),
        if (ageRating != null)
          LibraryDetailField(label: 'Age Rating', value: ageRating),
        if (audienceRating != null)
          LibraryDetailField(label: 'Audience Rating', value: audienceRating),
        if (referenceVariant?.formatLabel case final variantType?
            when variantType.trim().isNotEmpty)
          LibraryDetailField(label: 'Variant Type', value: variantType.trim()),
        if (referenceVariant?.sku case final sku? when sku.trim().isNotEmpty)
          LibraryDetailField(label: 'SKU', value: sku.trim()),
        if (referenceRelease.release != null)
          LibraryDetailField(
              label: 'Primary release',
              value: [
                referenceRelease.release!.title,
                if (referenceVariant?.name.trim().isNotEmpty == true)
                  referenceVariant!.name.trim(),
              ].join(' Â· ')),
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

({
  LibraryWorkspaceReleaseSummary? release,
  LibraryWorkspaceVariantSummary? variant
}) _mangaReferenceRelease(LibraryProjectionView item) {
  final node = item.node;
  if (node is! LibraryReleaseRef || node.release.id != node.releaseId) {
    return (release: null, variant: null);
  }
  LibraryWorkspaceVariantSummary? variant;
  for (final candidate in node.release.variants) {
    if (candidate.isPrimary) {
      variant = candidate;
      break;
    }
  }
  variant ??=
      node.release.variants.isEmpty ? null : node.release.variants.first;
  return (release: node.release, variant: variant);
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
