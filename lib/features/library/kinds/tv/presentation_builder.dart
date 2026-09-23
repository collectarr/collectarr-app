import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/tv/catalog/tv_catalog_fields.dart';
import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/features/library/config/library_duplicate_presentation.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/tv/provider/tv_provider_candidates.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/kinds/tv/add/tv_add_preview_seasons_section.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_shelf_drilldown.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_physical_media_formats.dart';
import 'package:collectarr_app/features/library/widgets/format_badge.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/features/library/workspace/config/library_entity_workspace_projector.dart';
import 'package:flutter/material.dart';

const tvMetadataLabels = LibraryMetadataLabels(
  identitySectionTitle: 'Series identity',
  contextSectionTitle: 'Broadcast context',
  creditsSectionTitle: 'Cast & Crew',
  values: {'creators': 'Cast & Crew'},
);

class TvLibraryMediaPresentationBuilder
    extends LibraryMediaPresentationBuilder {
  const TvLibraryMediaPresentationBuilder();

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
      final badge = tvFormatBadge(
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
    if (catalog is! TvWorkspaceCatalogData) return const [];
    final item = catalog.video;
    final identifier =
        normalizeLibraryDuplicateIdentifier(item.primaryRelease?.barcode);
    if (identifier == null) return const [];
    return [
      LibraryDuplicateCandidate(
        key: 'identifier:$identifier',
        label: 'Identifier ${item.primaryRelease!.barcode!.trim()}',
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
    if (catalog is! TvWorkspaceCatalogData) return const [];
    return [
      for (final release in catalog.video.releases)
        LibraryWorkspaceReleaseSummary(
          id: release.id,
          title: release.title,
          formatLabel: release.formatLabel,
          formatBadge: tvFormatBadge(release.formatLabel),
          releaseDate: release.releaseDate,
          mediaLabels: [
            for (var index = 0; index < release.media.length; index += 1)
              release.media[index].title ?? 'Media \${index + 1}',
          ],
          runtimeMinutes: release.videoDetails?.runtimeMinutes,
        ),
    ];
  }

  @override
  List<LibraryWorkspaceLinkSummary> buildWorkspaceLinks(
    LibraryWorkspaceSource entry,
  ) {
    final catalog = entry.catalogData;
    if (catalog is! TvWorkspaceCatalogData) return const [];
    return [
      for (final value in catalog.video.trailerUrls)
        if (value is Map<Object?, Object?>)
          if (value['url']?.toString().trim() case final url?
              when url.isNotEmpty)
            LibraryWorkspaceLinkSummary(
              url: url,
              label: value['title']?.toString(),
              source: value['source']?.toString(),
              isTrailer: value['kind']?.toString() != 'external' &&
                  value['kind']?.toString() != 'link',
              isAutomatic: value['is_automatic'] != false,
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
          formatBadge: tvFormatBadge(
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
                formatBadge: tvFormatBadge(
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
      item.mapTransport((transport) => transport.toSyncPayload());

  @override
  CatalogSearchCandidate mergeProviderAddResult({
    required CatalogSearchCandidate ingested,
    required CatalogSearchCandidate edited,
  }) {
    final ingestedMetadata = ingested.tvCatalogFields;
    final editedMetadata = edited.tvCatalogFields;
    final merged = CatalogSearchCandidate.fromItem(
        ingested.mapTransport((transport) => transport.copyWith(
              title: edited.primaryLabel,
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
    return edited.mapTransport(
      (transport) => CatalogSearchCandidate.fromItem(
        merged.mapTransport(
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
    final hydratedMetadata = hydrated.tvCatalogFields;
    final fallbackMetadata = fallback.tvCatalogFields;
    final hydratedEditions =
        hydrated.mapTransport((transport) => transport.editions);
    final fallbackEditions =
        fallback.mapTransport((transport) => transport.editions);
    final editions =
        hydratedEditions.isEmpty ? fallbackEditions : hydratedEditions;
    final coverImageUrl =
        hydratedMetadata.coverImageUrl ?? fallbackMetadata.coverImageUrl;
    final thumbnailImageUrl = hydratedMetadata.coverImageUrl != null
        ? hydratedMetadata.thumbnailImageUrl
        : fallbackMetadata.thumbnailImageUrl ?? fallbackMetadata.coverImageUrl;
    return CatalogSearchCandidate.fromItem(
        hydrated.mapTransport((transport) => transport.copyWith(
              coverImageUrl: coverImageUrl,
              thumbnailImageUrl: thumbnailImageUrl,
              editions: editions,
            )));
  }

  @override
  String? buildAddPreviewSynopsis({required CatalogSearchCandidate item}) =>
      item.tvCatalogFields.synopsis;

  @override
  List<String> buildCatalogSearchAliases({
    required CatalogSearchCandidate item,
  }) =>
      item.tvCatalogFields.searchAliases;

  @override
  LibraryAddSearchResultDisplay? buildSearchResultDisplay({
    required CatalogSearchCandidate item,
  }) =>
      _buildTvSearchResultDisplay(item);

  @override
  List<(String, String?)> buildAddPreviewMetadataRows({
    required CatalogSearchCandidate item,
    required LibraryMediaPreviewLabels previewLabels,
  }) {
    final releaseDate = item.tvCatalogFields.releaseDate;
    return [
      (
        previewLabels.labelFor('publisher', fallback: 'Publisher'),
        item.mapTransport((transport) => transport).publisher
      ),
      (
        'Released',
        releaseDate == null
            ? item.tvCatalogFields.releaseYear?.toString()
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
  bool canOpenKindDrilldown(LibraryProjectionView item) {
    return item.node.scope == LibraryEntityScope.work &&
        item.source.mediaKind == CatalogMediaKind.tv;
  }

  @override
  List<(String, String?)> buildAddPreviewMetadataRowsForCandidate({
    required ProviderSearchCandidate candidate,
    required LibraryMediaPreviewLabels previewLabels,
  }) {
    if (candidate is! TvProviderCandidate) return const [];
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
    if (dto is! TvWorkspaceDto) {
      throw StateError('Expected TvWorkspaceDto for TV presentation');
    }
    final seriesTitle = dto.seriesTitle;
    final variant = dto.variant;
    final barcode = dto.barcode;
    final publisher = dto.publisher;
    final releaseDate = dto.releaseDate;
    final country = dto.country;
    final language = dto.language;
    return LibraryMetadataPresentation(
      labels: tvMetadataLabels,
      identityFacts: [
        if (includeIdentityFacts) ...[
          LibraryDetailField(label: 'Kind', value: singularLabel),
          LibraryDetailField(label: 'ID', value: item.node.workId),
          LibraryDetailField(label: 'Title', value: dto.primaryLabel),
        ],
        if (seriesTitle != null)
          LibraryDetailField(
            label: 'Series',
            value: seriesTitle,
            onTap: tapFor(seriesTitle),
          ),
        if (item.node.scope != LibraryEntityScope.work && variant != null)
          LibraryDetailField(
            label: 'Format / Edition',
            value: variant,
            onTap: tapFor(variant),
          ),
        if (item.node.scope != LibraryEntityScope.work && barcode != null)
          LibraryDetailField(label: 'UPC / Barcode', value: barcode),
      ],
      contextFacts: [
        if (publisher != null)
          LibraryDetailField(
            label: 'Studio',
            value: publisher,
            onTap: tapFor(publisher),
          ),
        LibraryDetailField(
          label: 'Released',
          value: genericLibraryDash(
            formatPresentationNullableDate(releaseDate),
          ),
        ),
        if (country != null)
          LibraryDetailField(label: 'Country', value: country),
        if (language != null)
          LibraryDetailField(label: 'Language', value: language),
      ],
      sections: {
        'creators': LibraryMetadataSection(
          values: publisher == null
              ? const []
              : <Map<String, dynamic>>[
                  {'name': publisher},
                ],
          placement: LibraryMetadataSectionPlacement.credits,
          renderer: LibraryMetadataSectionRenderer.credits,
          completenessWeight: 12,
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
    final dto = item.dto;
    if (dto is! TvWorkspaceDto ||
        dto.common.synopsis?.trim().isNotEmpty != true) {
      return const [];
    }
    return [
      LibraryDetailSection(
        title: 'Summary',
        accentColor: accent,
        children: [
          SelectableText(
            dto.common.synopsis!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.4,
                ),
          ),
        ],
      ),
    ];
  }

  @override
  List<Widget> buildAddPreviewSections({
    required Color accent,
    required CatalogMediaKind kind,
    required String provider,
    required String providerItemId,
  }) {
    return [
      TvAddPreviewSeasonsSection(
        kind: kind,
        provider: provider,
        providerItemId: providerItemId,
        accent: accent,
      ),
    ];
  }

  @override
  Widget? buildKindDrilldown({
    required BuildContext context,
    required LibraryProjectionView selectedItem,
    required Color accent,
    required double coverSize,
    required VoidCallback onBack,
    required Future<void> Function() onRefreshFromCore,
    required VoidCallback onOpenTitleDetails,
    required List<OwnedItemSummary> ownedCopies,
    required List<WishlistItem> wishlistItems,
    required String? selectedReleaseId,
    required void Function(String releaseId) onSelectRelease,
    required LibraryEntityWorkspaceProjector projector,
  }) {
    return TvShelfSeasonDrilldown(
      titleItem: selectedItem,
      coverSize: coverSize,
      accent: accent,
      onBack: onBack,
      onRefreshFromCore: onRefreshFromCore,
      onOpenTitleDetails: onOpenTitleDetails,
    );
  }
}

LibraryAddSearchResultDisplay _buildTvSearchResultDisplay(
  CatalogSearchCandidate item,
) {
  final itemNumber =
      item.mapTransport((transport) => transport).itemNumber?.trim();
  final subtitle = [
    if (item.mapTransport((transport) => transport).publisher?.trim()
        case final value? when value.isNotEmpty)
      value,
    if ((item.tvCatalogFields.releaseYear ??
            item.tvCatalogFields.releaseDate?.year)
        case final year?)
      year.toString(),
    if (item.mapTransport((transport) => transport).physicalFormatLabel?.trim()
        case final value? when value.isNotEmpty)
      value,
    if (item.mapTransport((transport) => transport).identifierCode?.trim()
        case final value? when value.isNotEmpty)
      value,
  ].join(' | ');
  return LibraryAddSearchResultDisplay(
    title: itemNumber == null || itemNumber.isEmpty
        ? item.primaryLabel
        : '${item.primaryLabel} #$itemNumber',
    secondaryLine: subtitle.isEmpty ? null : subtitle,
    year: item.tvCatalogFields.releaseYear ??
        item.tvCatalogFields.releaseDate?.year,
    detailLine: null,
  );
}
