import 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_fields.dart';
import 'package:collectarr_app/features/library/config/library_duplicate_presentation.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_physical_media_formats.dart';
import 'package:collectarr_app/features/library/widgets/format_badge.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_group_mode_categories.dart';
import 'package:collectarr_app/features/library/config/library_group_mode_category_models.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';

class ComicLibraryCatalogItemPresentationBuilder
    extends LibraryMediaPresentationBuilder {
  const ComicLibraryCatalogItemPresentationBuilder({
    this.showSummary = false,
    this.metadataLabels = const LibraryMetadataLabels(),
  });

  final bool showSummary;
  final LibraryMetadataLabels metadataLabels;

  @override
  String? buildAddPreviewItemNumber({
    required CatalogSearchCandidate item,
  }) =>
      item.comicCatalogFields.itemNumber;

  @override
  List<LibraryFormatBadgeDescriptor> buildAddPreviewFormatBadges({
    required CatalogSearchCandidate item,
  }) {
    final seen = <String>{};
    final result = <LibraryFormatBadgeDescriptor>[];
    final transport = item.kindCapability.mapTransport((value) => value);
    final badge = comicFormatBadge(
      transport.physicalFormat,
      label: transport.physicalFormat,
    );
    if (badge != null && seen.add(badge.key)) result.add(badge);
    return result;
  }

  @override
  List<LibraryDuplicateCandidate> buildDuplicateCandidates(
    LibraryWorkspaceSource entry,
  ) {
    final catalog = entry.catalogData;
    if (catalog is! ComicWorkspaceCatalogData) return const [];
    final item = catalog.comic;
    final candidates = <LibraryDuplicateCandidate>[];
    final entryLabel = [
      item.title,
      if (item.issueNumber?.trim() case final value? when value.isNotEmpty)
        '#$value',
    ].join(' ');
    final identifier = normalizeLibraryDuplicateIdentifier(item.barcode);
    if (identifier != null) {
      candidates.add(
        LibraryDuplicateCandidate(
          key: 'barcode:$identifier',
          label: 'Barcode ${item.barcode!.trim()}',
          reason: 'Same barcode',
          confidenceScore: 78,
          entryLabel: entryLabel,
        ),
      );
    }
    final title = normalizeLibraryDuplicateToken(item.title);
    final issue = normalizeLibraryDuplicateToken(item.issueNumber);
    if (title == null || issue == null) return candidates;
    final publisher = normalizeLibraryDuplicateToken(item.publisher) ?? '';
    final year = item.releaseDate?.year.toString() ?? '';
    final variant = normalizeLibraryDuplicateToken(item.variant) ?? '';
    final labelParts = [
      item.title,
      '#${item.issueNumber!.trim()}',
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
  List<LibraryWorkspaceLinkSummary> buildWorkspaceLinks(
    LibraryWorkspaceSource entry,
  ) {
    final catalog = entry.catalogData;
    if (catalog is! ComicWorkspaceCatalogData) return const [];
    return [
      for (final link in catalog.comic.links)
        LibraryWorkspaceLinkSummary(
          url: link.url,
          label: link.title,
          source: link.source,
          isTrailer: link.isTrailerLink,
          isAutomatic: link.isAutomatic,
        ),
    ];
  }

  @override
  CatalogSearchCandidate mergeHydratedAddItem({
    required CatalogSearchCandidate hydrated,
    required CatalogSearchCandidate fallback,
  }) {
    final hydratedMetadata = hydrated.comicCatalogFields;
    final fallbackMetadata = fallback.comicCatalogFields;
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
      item.comicCatalogFields.synopsis;

  @override
  List<String> buildCatalogSearchAliases({
    required CatalogSearchCandidate item,
  }) =>
      item.comicCatalogFields.searchAliases;

  @override
  LibraryAddSearchResultDisplay? buildSearchResultDisplay({
    required CatalogSearchCandidate item,
  }) =>
      _buildComicSearchResultDisplay(item);

  @override
  List<(String, String?)> buildAddPreviewMetadataRows({
    required CatalogSearchCandidate item,
    required LibraryMediaPreviewLabels previewLabels,
  }) {
    final releaseDate = item.comicCatalogFields.releaseDate;
    return [
      (
        previewLabels.labelFor('publisher', fallback: 'Publisher'),
        item.kindCapability.mapTransport((transport) => transport).publisher
      ),
      (
        'Released',
        releaseDate == null
            ? item.comicCatalogFields.releaseYear?.toString()
            : '${releaseDate.year}-${releaseDate.month.toString().padLeft(2, '0')}-${releaseDate.day.toString().padLeft(2, '0')}',
      ),
      if (item.comicCatalogFields.itemNumber != null)
        (
          previewLabels.labelFor('item_number', fallback: 'Number'),
          item.comicCatalogFields.itemNumber
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
  List<LibraryGroupModeCategory> buildGroupModeCategories(
    List<String> modes,
  ) {
    return buildComicGroupModeCategories(modes);
  }

  @override
  LibraryMetadataPresentation buildMetadataPresentation({
    required String singularLabel,
    required LibraryProjectionView item,
    required bool includeIdentityFacts,
    required LibraryMetadataFactTapResolver tapFor,
  }) {
    final workspace = item.dto;
    if (workspace is! ComicWorkspaceDto) {
      throw StateError('Expected ComicWorkspaceDto for comic presentation');
    }
    final dto = workspace;
    final metadata = dto.comic;
    final referenceFormat = metadata.physicalFormat ?? metadata.variant;
    return LibraryMetadataPresentation(
      labels: metadataLabels,
      identityFacts: [
        if (includeIdentityFacts) ...[
          LibraryDetailField(label: 'Kind', value: singularLabel),
          LibraryDetailField(label: 'ID', value: item.node.catalogItemId),
          LibraryDetailField(label: 'Title', value: metadata.title),
        ],
        if (metadata.seriesTitle != null)
          LibraryDetailField(
              label: 'Series',
              value: metadata.seriesTitle!,
              onTap: tapFor(metadata.seriesTitle)),
        if (metadata.volumeName != null || metadata.volumeNumber != null)
          LibraryDetailField(
              label: 'Volume',
              value: metadata.volumeName ?? metadata.volumeNumber ?? ''),
        LibraryDetailField(
            label: 'No. / Vol.',
            value: genericLibraryDash(metadata.issueNumber),
            onTap: tapFor(metadata.issueNumber)),
        LibraryDetailField(
            label: 'Edition / Variant / Format',
            value: genericLibraryDash(metadata.variant),
            onTap: tapFor(metadata.variant)),
        LibraryDetailField(
            label: 'Barcode / UPC / ISBN',
            value: genericLibraryDash(metadata.barcode)),
      ],
      contextFacts: [
        LibraryDetailField(
            label: 'Publisher / Studio / Creator',
            value: genericLibraryDash(metadata.publisher),
            onTap: tapFor(metadata.publisher)),
        LibraryDetailField(
            label: 'Released',
            value: genericLibraryDash(
              formatPresentationNullableDate(metadata.releaseDate) ??
                  metadata.releaseDate?.year.toString(),
            )),
        if (metadata.pageCount != null)
          LibraryDetailField(
              label: 'Pages', value: metadata.pageCount.toString()),
        if (metadata.coverPriceCents != null)
          LibraryDetailField(
              label: 'Cover Price',
              value: formatPresentationMoney(
                metadata.coverPriceCents,
                metadata.currency,
              )),
        if (metadata.imprint != null)
          LibraryDetailField(
              label: 'Imprint',
              value: metadata.imprint!,
              onTap: tapFor(metadata.imprint)),
        if (metadata.subtitle != null)
          LibraryDetailField(label: 'Subtitle', value: metadata.subtitle!),
        LibraryDetailField(label: 'Country', value: metadata.country),
        LibraryDetailField(label: 'Language', value: metadata.language),
        if (metadata.ageRating != null)
          LibraryDetailField(label: 'Age Rating', value: metadata.ageRating!),
        if (referenceFormat?.trim().isNotEmpty == true)
          LibraryDetailField(label: 'Format', value: referenceFormat!.trim()),
        LibraryDetailField(
            label: 'Cover',
            value: metadata.coverImageUrl == null ? 'Missing' : 'Ready'),
        LibraryDetailField(
            label: 'Metadata',
            value: metadata.publisher == null || metadata.publisher!.isEmpty
                ? 'Missing'
                : 'Ready'),
      ],
      sections: {
        'creators': LibraryMetadataSection(
          values: [...metadata.contributors, ...metadata.creators]
              .map((creator) => creator.toJson())
              .toList(growable: false),
          placement: LibraryMetadataSectionPlacement.credits,
          renderer: LibraryMetadataSectionRenderer.credits,
          completenessWeight: 12,
        ),
        'characters': LibraryMetadataSection(
          values: metadata.characters
              .map((character) => character.name)
              .whereType<String>()
              .toList(growable: false),
          placement: LibraryMetadataSectionPlacement.credits,
          completenessWeight: 6,
        ),
        'story_arcs': LibraryMetadataSection(
          values: metadata.storyArcs
              .map((arc) => arc.name)
              .whereType<String>()
              .toList(growable: false),
          placement: LibraryMetadataSectionPlacement.credits,
          inlineLabelKey: 'story_arcs_inline',
        ),
        'genres': LibraryMetadataSection(
          values: metadata.genres,
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
    final workspace = item.dto;
    if (workspace is! ComicWorkspaceDto) {
      return const [];
    }
    final dto = workspace;
    final synopsis = dto.comic.synopsis;
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

LibraryAddSearchResultDisplay _buildComicSearchResultDisplay(
  CatalogSearchCandidate item,
) {
  final itemNumber = item.comicCatalogFields.itemNumber?.trim();
  final subtitle = [
    if (item.kindCapability
            .mapTransport((transport) => transport)
            .publisher
            ?.trim()
        case final value? when value.isNotEmpty)
      value,
    if ((item.comicCatalogFields.releaseYear ??
            item.comicCatalogFields.releaseDate?.year)
        case final year?)
      year.toString(),
    if (item.kindCapability
            .mapTransport((transport) => transport)
            .physicalFormat
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
    year: item.comicCatalogFields.releaseYear ??
        item.comicCatalogFields.releaseDate?.year,
    detailLine: null,
  );
}
