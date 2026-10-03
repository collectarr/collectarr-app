import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_fields.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_library_entry_projection.dart';
import 'package:collectarr_app/features/library/config/library_duplicate_presentation.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/features/library/hierarchy/ui/hierarchy_children_section.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/book/book_physical_media_formats.dart';
import 'package:collectarr_app/features/library/widgets/format_badge.dart';
import 'package:flutter/material.dart';

class BookLibraryMediaPresentationBuilder
    extends LibraryMediaPresentationBuilder {
  const BookLibraryMediaPresentationBuilder({
    this.showSummary = false,
    this.showVolumeHierarchy = false,
    this.showPersonalDetails = true,
    this.metadataLabels = const LibraryMetadataLabels(),
  });

  final bool showSummary;
  final bool showVolumeHierarchy;
  final bool showPersonalDetails;
  final LibraryMetadataLabels metadataLabels;

  @override
  LibraryCardPresentation buildCardPresentation(
    LibraryProjectionView item, {
    bool coverFocused = false,
  }) {
    final dto =
        item.dto is BookWorkspaceDto ? item.dto as BookWorkspaceDto : null;
    return LibraryCardPresentation(
      itemNumber: dto?.itemNumber,
      variant: dto?.variant,
      releaseDate: dto?.releaseDate,
      format: dto?.format,
      synopsis: dto?.synopsis,
      seriesTitle: dto?.seriesTitle,
      identifierCode: dto?.identifierCode,
      currency: dto?.currency,
      contextFacts: [
        dto?.author,
        dto?.publisher,
      ].whereType<String>().where((value) => value.trim().isNotEmpty).toList(),
    );
  }

  @override
  String? buildAddPreviewItemNumber({
    required CatalogSearchCandidate item,
  }) =>
      item.kindCapability.mapTransport((transport) => transport).itemNumber;

  @override
  List<LibraryFormatBadgeDescriptor> buildAddPreviewFormatBadges({
    required CatalogSearchCandidate item,
  }) {
    final transport = item.kindCapability.mapTransport((value) => value);
    final badge = bookFormatBadge(
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
    if (catalog is! BookWorkspaceCatalogData) return const [];
    final item = catalog.book;
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
  CatalogSearchCandidate mergeHydratedAddItem({
    required CatalogSearchCandidate hydrated,
    required CatalogSearchCandidate fallback,
  }) {
    final hydratedMetadata = hydrated.bookCatalogFields;
    final fallbackMetadata = fallback.bookCatalogFields;
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
      item.bookCatalogFields.synopsis;

  @override
  List<String> buildCatalogSearchAliases({
    required CatalogSearchCandidate item,
  }) =>
      item.bookCatalogFields.searchAliases;

  @override
  LibraryAddSearchResultDisplay? buildSearchResultDisplay({
    required CatalogSearchCandidate item,
  }) =>
      _buildBookSearchResultDisplay(item);

  @override
  List<(String, String?)> buildAddPreviewMetadataRows({
    required CatalogSearchCandidate item,
    required LibraryMediaPreviewLabels previewLabels,
  }) {
    final releaseDate = item.bookCatalogFields.releaseDate;
    return [
      (
        previewLabels.labelFor('publisher', fallback: 'Publisher'),
        item.kindCapability.mapTransport((transport) => transport).publisher
      ),
      (
        'Released',
        releaseDate == null
            ? item.bookCatalogFields.releaseYear?.toString()
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
    final adapter = dto is BookWorkspaceDto ? dto : null;
    final bookDto = dto is BookWorkspaceDto ? dto : null;
    final itemNumber = adapter?.itemNumber;
    final variant = adapter?.variant;
    final barcode = bookDto?.barcode;
    final publisher = bookDto?.publisher;
    final releaseDate = adapter?.releaseDate;
    final country = adapter?.country;
    final language = adapter?.language;

    final metadata = _bookMetadata(item);
    final series = metadata?.series;
    final publishing = metadata?.publishing;
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
              value: series!.volumeName ?? (series.volumeNumber ?? '')),
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
            label: 'Volume',
            value: genericLibraryDash(itemNumber),
            onTap: tapFor(itemNumber)),
        LibraryDetailField(
            label: 'Edition / Binding',
            value: genericLibraryDash(variant),
            onTap: tapFor(variant)),
        LibraryDetailField(
            label: 'ISBN / Barcode', value: genericLibraryDash(barcode)),
      ],
      contextFacts: [
        LibraryDetailField(
            label: 'Publisher',
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
        if (language != null)
          LibraryDetailField(label: 'Language', value: language),
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
    final sections = <Widget>[];
    if (showVolumeHierarchy) {
      sections.add(
        HierarchyChildrenSection(
          itemId: item.node.catalogItemId,
          kind: CatalogMediaKind.book,
        ),
      );
    }
    final dto = item.dto;
    final metadata = _bookMetadata(item);
    final series = metadata?.series;
    final sectionSpecs = <LibraryDetailSectionSpec>[];

    final originalFacts = <LibraryDetailField>[
      if (series?.seriesTitle?.trim().isNotEmpty == true)
        LibraryDetailField(label: 'Series', value: series!.seriesTitle!.trim()),
      if (metadata?.synopsis != null && metadata!.synopsis!.trim().isNotEmpty)
        LibraryDetailField(label: 'Summary', value: metadata.synopsis!.trim()),
    ];
    if (originalFacts.isNotEmpty) {
      sectionSpecs.add(
        LibraryDetailSectionSpec(
          slot: LibraryDetailSectionSlot.identity,
          title: 'Original Details',
          children: [LibraryDetailFieldTable(fields: originalFacts)],
        ),
      );
    }

    final adapter = dto is BookWorkspaceDto ? dto : null;
    final bookDto = dto is BookWorkspaceDto ? dto : null;
    final productFacts = <LibraryDetailField>[
      if (adapter?.referenceFormatLabel?.trim().isNotEmpty == true)
        LibraryDetailField(
            label: 'Format', value: adapter!.referenceFormatLabel!.trim()),
      if (bookDto?.publisher?.trim().isNotEmpty == true)
        LibraryDetailField(
            label: 'Publisher', value: bookDto!.publisher!.trim()),
      if (bookDto?.barcode?.trim().isNotEmpty == true)
        LibraryDetailField(
            label: 'ISBN / Barcode', value: bookDto!.barcode!.trim()),
      if (adapter?.country?.trim().isNotEmpty == true)
        LibraryDetailField(label: 'Country', value: adapter!.country!.trim()),
      if (adapter?.language?.trim().isNotEmpty == true)
        LibraryDetailField(label: 'Language', value: adapter!.language!.trim()),
    ];
    if (productFacts.isNotEmpty) {
      sectionSpecs.add(
        LibraryDetailSectionSpec(
          slot: LibraryDetailSectionSlot.metadata,
          title: 'Product Details',
          children: [LibraryDetailFieldTable(fields: productFacts)],
        ),
      );
    }

    final creatorNames = <String>[
      for (final creator
          in metadata?.creators ?? const <Map<String, dynamic>>[])
        if (creator['name']?.toString().trim().isNotEmpty == true)
          creator['name']!.toString().trim(),
    ];
    sectionSpecs.add(
      LibraryDetailSectionSpec(
        slot: LibraryDetailSectionSlot.relations,
        title: 'Contributors',
        chips: [
          LibraryDetailChipGroup(
            values: creatorNames,
            onValueTap: onFilterByValue,
          ),
        ],
      ),
    );

    final imageFacts = <LibraryDetailField>[
      if (dto.imageUrl?.trim().isNotEmpty == true)
        LibraryDetailField(label: 'Cover', value: dto.imageUrl!.trim()),
    ];
    if (imageFacts.isNotEmpty) {
      sectionSpecs.add(
        LibraryDetailSectionSpec(
          slot: LibraryDetailSectionSlot.media,
          title: 'Images',
          children: [LibraryDetailFieldTable(fields: imageFacts)],
        ),
      );
    }

    final identifierValues = <String>[
      if (bookDto?.barcode?.trim().isNotEmpty == true) bookDto!.barcode!.trim(),
    ];
    if (identifierValues.isNotEmpty) {
      sectionSpecs.add(
        LibraryDetailSectionSpec(
          slot: LibraryDetailSectionSlot.source,
          title: 'Identifiers',
          chips: [
            LibraryDetailChipGroup(
              values: identifierValues,
              onValueTap: onFilterByValue,
            ),
          ],
        ),
      );
    }

    final source = item.source;
    final typedEntry =
        BookLibraryEntryProjection.fromDispatch(source.libraryEntryDispatch);
    final entry = typedEntry is BookLibraryEntry ? typedEntry : null;
    final rating = source.trackingSummary?.rating;
    final personalFacts = <LibraryDetailField>[
      if (entry?.condition?.trim().isNotEmpty == true)
        LibraryDetailField(
          label: 'Condition',
          value: entry!.condition!.trim(),
        ),
      if (entry?.grade?.trim().isNotEmpty == true)
        LibraryDetailField(
          label: 'Grade',
          value: entry!.grade!.trim(),
        ),
      if (entry?.collectionStatus?.trim().isNotEmpty == true)
        LibraryDetailField(
            label: 'Collection Status', value: entry!.collectionStatus!.trim()),
      if (rating != null)
        LibraryDetailField(label: 'Rating', value: rating.toString()),
      if (source.locationPath?.trim().isNotEmpty == true)
        LibraryDetailField(
            label: 'Location', value: source.locationPath!.trim()),
      if (source.pricePaidCents != null)
        LibraryDetailField(
            label: 'Price Paid', value: source.pricePaidCents!.toString()),
      if (source.libraryEntrySummary?.notes?.trim().isNotEmpty == true)
        LibraryDetailField(
          label: 'Notes',
          value: source.libraryEntrySummary!.notes!.trim(),
        ),
      if (entry?.tags?.trim().isNotEmpty == true)
        LibraryDetailField(
          label: 'Tags',
          value: entry!.tags!.trim(),
        ),
    ];
    if (showPersonalDetails && personalFacts.isNotEmpty) {
      sectionSpecs.add(
        LibraryDetailSectionSpec(
          slot: LibraryDetailSectionSlot.personal,
          title: 'Personal Details',
          children: [LibraryDetailFieldTable(fields: personalFacts)],
        ),
      );
    }

    for (final spec in sectionSpecs) {
      sections.add(
        LibraryDetailSection(
          title: spec.title,
          accentColor: accent,
          children: spec.children,
        ),
      );
    }
    return sections;
  }
}

LibraryAddSearchResultDisplay _buildBookSearchResultDisplay(
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
    if ((item.bookCatalogFields.releaseYear ??
            item.bookCatalogFields.releaseDate?.year)
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
    year: item.bookCatalogFields.releaseYear ??
        item.bookCatalogFields.releaseDate?.year,
    detailLine: null,
  );
}

BookCatalogMetadata? _bookMetadata(LibraryProjectionView item) {
  final catalog = item.source.catalogData;
  return catalog is BookWorkspaceCatalogData ? catalog.metadata : null;
}
