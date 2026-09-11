import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/features/library/config/library_duplicate_presentation.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_edition_dto.dart';
import 'package:collectarr_app/features/catalog/transport/library_add_catalog_transport.dart';
import 'package:collectarr_app/features/providers/transport/provider_candidate.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/kinds/tv/add/tv_add_preview_seasons_section.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_shelf_drilldown.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_dto.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_projector.dart';
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
    required LibraryAddCatalogTransport item,
  }) =>
      item.itemNumber;

  @override
  List<(String id, String label)> buildAddPreviewFormatBadges({
    required LibraryAddCatalogTransport item,
  }) {
    final seen = <String>{};
    final result = <(String, String)>[];
    for (final edition in item.editions) {
      final id = edition.physicalFormat;
      if (id == null || !seen.add(id)) continue;
      final label = edition.physicalFormatLabel?.trim();
      result.add((id, label == null || label.isEmpty ? id : label));
    }
    return result;
  }

  @override
  List<LibraryDuplicateCandidate> buildDuplicateCandidates(
    LibraryWorkspaceSource entry,
  ) {
    final item = entry.catalogTransport;
    final identifier =
        normalizeLibraryDuplicateIdentifier(item?.identifierCode);
    if (item == null || identifier == null) return const [];
    return [
      LibraryDuplicateCandidate(
        key: 'identifier:$identifier',
        label: 'Identifier ${item.identifierCode!.trim()}',
        reason: 'Same identifier',
        confidenceScore: 78,
      ),
    ];
  }

  @override
  List<CatalogEditionDto> buildReleaseEditions({
    required LibraryAddCatalogTransport item,
  }) {
    return item.editions;
  }

  @override
  LibraryAddSearchResultDisplay? buildSearchResultDisplay({
    required LibraryAddCatalogTransport item,
  }) =>
      _buildTvSearchResultDisplay(item);

  @override
  List<(String, String?)> buildAddPreviewMetadataRows({
    required LibraryAddCatalogTransport item,
    required LibraryMediaPreviewLabels previewLabels,
  }) {
    final releaseDate = item.releaseDate;
    return [
      (
        previewLabels.labelFor('publisher', fallback: 'Publisher'),
        item.publisher
      ),
      (
        'Released',
        releaseDate == null
            ? item.releaseYear?.toString()
            : '${releaseDate.year}-${releaseDate.month.toString().padLeft(2, '0')}-${releaseDate.day.toString().padLeft(2, '0')}',
      ),
      if (item.itemNumber != null)
        (
          previewLabels.labelFor('item_number', fallback: 'Number'),
          item.itemNumber
        ),
      if (item.variant != null)
        (previewLabels.labelFor('variant', fallback: 'Variant'), item.variant),
      (
        previewLabels.labelFor('barcode', fallback: 'Barcode'),
        item.identifierCode
      ),
    ];
  }

  @override
  bool canOpenKindDrilldown(LibraryProjectionView item) {
    return item.node.scope == LibraryBrowserScope.title &&
        item.source.mediaKind == CatalogMediaKind.tv;
  }

  @override
  @override
  List<(String, String?)> buildAddPreviewMetadataRowsForCandidate({
    required ProviderCandidate candidate,
    required LibraryMediaPreviewLabels previewLabels,
  }) {
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
      if (runtimeMinutes != null) ('Runtime', '${runtimeMinutes} min'),
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
    final seriesTitle = dto.common.seriesTitle;
    final variant = dto.common.variant;
    final barcode = dto.barcode;
    final publisher = dto.publisher;
    final releaseDate = dto.common.releaseDate;
    final country = dto.common.country;
    final language = dto.common.language;
    return LibraryMetadataPresentation(
      labels: tvMetadataLabels,
      identityFacts: [
        if (includeIdentityFacts) ...[
          LibraryDetailField(label: 'Kind', value: singularLabel),
          LibraryDetailField(label: 'ID', value: item.node.titleItemId),
          LibraryDetailField(label: 'Title', value: dto.title),
        ],
        if (seriesTitle != null)
          LibraryDetailField(
            label: 'Series',
            value: seriesTitle,
            onTap: tapFor(seriesTitle),
          ),
        if (item.node.scope != LibraryBrowserScope.title && variant != null)
          LibraryDetailField(
            label: 'Format / Edition',
            value: variant,
            onTap: tapFor(variant),
          ),
        if (item.node.scope != LibraryBrowserScope.title && barcode != null)
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
    required LibraryWorkspaceProjector projector,
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
  LibraryAddCatalogTransport item,
) {
  final itemNumber = item.itemNumber?.trim();
  final subtitle = [
    if (item.publisher?.trim() case final value? when value.isNotEmpty) value,
    if ((item.releaseYear ?? item.releaseDate?.year) case final year?)
      year.toString(),
    if (item.physicalFormatLabel?.trim() case final value?
        when value.isNotEmpty)
      value,
    if (item.identifierCode?.trim() case final value? when value.isNotEmpty)
      value,
  ].join(' | ');
  return LibraryAddSearchResultDisplay(
    title: itemNumber == null || itemNumber.isEmpty
        ? item.title
        : '${item.title} #$itemNumber',
    secondaryLine: subtitle.isEmpty ? null : subtitle,
    detailLine: null,
  );
}
