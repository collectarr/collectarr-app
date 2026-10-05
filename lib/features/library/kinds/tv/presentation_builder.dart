import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/tv/catalog/tv_catalog_fields.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/config/library_duplicate_presentation.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_shelf_drilldown.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_data.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_physical_media_formats.dart';
import 'package:collectarr_app/features/library/widgets/format_badge.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/domain/library_target_ref.dart';
import 'package:collectarr_app/features/library/workspace/config/library_target_workspace_projector.dart';
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
      item.tvCatalogFields.itemNumber;

  @override
  List<LibraryFormatBadgeDescriptor> buildAddPreviewFormatBadges({
    required CatalogSearchCandidate item,
  }) {
    final seen = <String>{};
    final result = <LibraryFormatBadgeDescriptor>[];
    final fields = item.tvCatalogFields;
    final badge = tvFormatBadge(
      fields.physicalFormat,
      label: fields.physicalFormatLabel,
    );
    if (badge != null && seen.add(badge.key)) result.add(badge);
    return result;
  }

  @override
  List<LibraryDuplicateCandidate> buildDuplicateCandidates(
    LibraryWorkspaceContext entry,
  ) {
    final catalog = entry.kindPresentationData;
    if (catalog is! TvWorkspaceData) return const [];
    final identifier = normalizeLibraryDuplicateIdentifier(
      catalog.metadata.barcode,
    );
    if (identifier == null) return const [];
    return [
      LibraryDuplicateCandidate(
        key: 'identifier:$identifier',
        label: 'Identifier ${catalog.metadata.barcode!.trim()}',
        reason: 'Same identifier',
        confidenceScore: 78,
      ),
    ];
  }

  @override
  List<LibraryWorkspaceLinkSummary> buildWorkspaceLinks(
    LibraryWorkspaceContext entry,
  ) {
    final catalog = entry.kindPresentationData;
    if (catalog is! TvWorkspaceData) return const [];
    return [
      for (final value in catalog.metadata.links)
        if (value.url.trim().isNotEmpty)
          LibraryWorkspaceLinkSummary(
            url: value.url,
            label: value.title,
            source: value.source,
            isTrailer: value.isTrailerLink,
            isAutomatic: value.isAutomatic,
          ),
    ];
  }

  @override
  CatalogSearchCandidate mergeHydratedAddItem({
    required CatalogSearchCandidate hydrated,
    required CatalogSearchCandidate fallback,
  }) {
    final hydratedMetadata = hydrated.tvCatalogFields;
    final fallbackMetadata = fallback.tvCatalogFields;
    final coverImageUrl =
        hydratedMetadata.coverImageUrl ?? fallbackMetadata.coverImageUrl;
    final thumbnailImageUrl = hydratedMetadata.coverImageUrl != null
        ? hydratedMetadata.thumbnailImageUrl
        : fallbackMetadata.thumbnailImageUrl ?? fallbackMetadata.coverImageUrl;
    return CatalogSearchCandidate.fromItem(
      hydrated.kindCapability.mapTransport((transport) {
        final metadata = TvMetadata.fromJson(transport.kindData);
        final updated = TvMetadata.fromJson(applyJsonFieldPatch(
          metadata,
          {
            'cover_image_url': coverImageUrl,
            'thumbnail_image_url': thumbnailImageUrl,
          },
        ));
        return transport.replacingKindData(updated);
      }),
    );
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
        item.tvCatalogFields.publisher
      ),
      (
        'Released',
        releaseDate == null
            ? item.tvCatalogFields.releaseYear?.toString()
            : '${releaseDate.year}-${releaseDate.month.toString().padLeft(2, '0')}-${releaseDate.day.toString().padLeft(2, '0')}',
      ),
      if (item.tvCatalogFields.itemNumber != null)
        (
          previewLabels.labelFor('item_number', fallback: 'Number'),
          item.tvCatalogFields.itemNumber
        ),
      if (item.tvCatalogFields.variant != null)
        (
          previewLabels.labelFor('variant', fallback: 'Variant'),
          item.tvCatalogFields.variant
        ),
      (
        previewLabels.labelFor('barcode', fallback: 'Barcode'),
        item.tvCatalogFields.barcode
      ),
    ];
  }

  @override
  bool canOpenKindDrilldown(LibraryProjectionView item) {
    return item.target is CatalogTargetRef &&
        item.source.mediaKind == CatalogMediaKind.tv;
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
          LibraryDetailField(label: 'ID', value: item.target.id),
          LibraryDetailField(label: 'Title', value: dto.primaryLabel),
        ],
        if (seriesTitle != null)
          LibraryDetailField(
            label: 'Series',
            value: seriesTitle,
            onTap: tapFor(seriesTitle),
          ),
        if (item.target is EntryTargetRef && variant != null)
          LibraryDetailField(
            label: 'Format / Edition',
            value: variant,
            onTap: tapFor(variant),
          ),
        if (item.target is EntryTargetRef && barcode != null)
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
  Widget? buildKindDrilldown({
    required BuildContext context,
    required LibraryProjectionView selectedItem,
    required Color accent,
    required double coverSize,
    required VoidCallback onBack,
    required Future<void> Function() onRefreshFromCore,
    required VoidCallback onOpenTitleDetails,
    required List<LibraryEntrySummary> libraryEntries,
    required List<WishlistItem> wishlistItems,
    required LibraryTargetWorkspaceProjector projector,
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
  final itemNumber = item.tvCatalogFields.itemNumber?.trim();
  final subtitle = [
    if (item.tvCatalogFields.publisher?.trim() case final value?
        when value.isNotEmpty)
      value,
    if ((item.tvCatalogFields.releaseYear ??
            item.tvCatalogFields.releaseDate?.year)
        case final year?)
      year.toString(),
    if (item.tvCatalogFields.physicalFormatLabel?.trim() case final value?
        when value.isNotEmpty)
      value,
    if (item.tvCatalogFields.barcode?.trim() case final value?
        when value.isNotEmpty)
      value,
  ].join(' | ');
  return LibraryAddSearchResultDisplay(
    title: itemNumber == null || itemNumber.isEmpty
        ? item.summary.primaryLabel
        : '${item.summary.primaryLabel} #$itemNumber',
    secondaryLine: subtitle.isEmpty ? null : subtitle,
    year: item.tvCatalogFields.releaseYear ??
        item.tvCatalogFields.releaseDate?.year,
    detailLine: null,
  );
}
