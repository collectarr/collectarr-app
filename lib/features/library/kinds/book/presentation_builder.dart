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
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_data.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_dto.dart';
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
      item.kindCapability.mapTransport(
        (transport) =>
            BookCatalogMetadata.fromJson(transport.kindData).itemNumber,
      );

  @override
  List<LibraryFormatBadgeDescriptor> buildAddPreviewFormatBadges({
    required CatalogSearchCandidate item,
  }) {
    final metadata = item.kindCapability.mapTransport(
      (transport) => BookCatalogMetadata.fromJson(transport.kindData),
    );
    final badge = bookFormatBadge(
      metadata.physicalFormat,
      label: metadata.physicalFormat,
    );
    return badge == null ? const [] : [badge];
  }

  @override
  List<LibraryDuplicateCandidate> buildDuplicateCandidates(
    LibraryWorkspaceContext entry,
  ) {
    final catalog = entry.kindPresentationData;
    if (catalog is! BookWorkspaceData) return const [];
    final metadata = catalog.metadata;
    final identifier = normalizeLibraryDuplicateIdentifier(
      metadata.isbn ?? metadata.isbn13 ?? metadata.isbn10 ?? metadata.barcode,
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
    final hydratedMetadata = hydrated.bookCatalogFields;
    final fallbackMetadata = fallback.bookCatalogFields;
    final coverImageUrl =
        hydratedMetadata.coverImageUrl ?? fallbackMetadata.coverImageUrl;
    final thumbnailImageUrl = hydratedMetadata.coverImageUrl != null
        ? hydratedMetadata.thumbnailImageUrl
        : fallbackMetadata.thumbnailImageUrl ?? fallbackMetadata.coverImageUrl;
    return CatalogSearchCandidate.fromItem(
      hydrated.kindCapability.mapTransport((transport) {
        final metadata = BookCatalogMetadata.fromJson(transport.kindData);
        final updated = BookCatalogMetadata.fromJson(applyJsonFieldPatch(
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
    final fields = item.bookCatalogFields;
    final metadata = fields.metadata;
    final releaseDate = fields.releaseDate;
    return [
      (
        previewLabels.labelFor('publisher', fallback: 'Publisher'),
        metadata?.publisher
      ),
      (
        'Released',
        releaseDate == null
            ? item.bookCatalogFields.releaseYear?.toString()
            : '${releaseDate.year}-${releaseDate.month.toString().padLeft(2, '0')}-${releaseDate.day.toString().padLeft(2, '0')}',
      ),
      if (item.bookCatalogFields.itemNumber != null)
        (
          previewLabels.labelFor('item_number', fallback: 'Number'),
          item.bookCatalogFields.itemNumber
        ),
      if (metadata?.variant != null)
        (
          previewLabels.labelFor('variant', fallback: 'Variant'),
          metadata?.variant
        ),
      (
        previewLabels.labelFor('barcode', fallback: 'Barcode'),
        metadata?.barcode
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
    return LibraryMetadataPresentation(
      labels: metadataLabels,
      identityFacts: [
        if (includeIdentityFacts) ...[
          LibraryDetailField(label: 'Kind', value: singularLabel),
          LibraryDetailField(label: 'ID', value: item.target.id),
          LibraryDetailField(label: 'Title', value: dto.primaryLabel),
        ],
        if (metadata?.seriesTitle != null)
          LibraryDetailField(
              label: 'Series',
              value: metadata!.seriesTitle!,
              onTap: tapFor(metadata.seriesTitle)),
        if (metadata?.volumeName != null || metadata?.volumeNumber != null)
          LibraryDetailField(
              label: 'Volume',
              value: metadata!.volumeName ?? metadata.volumeNumber ?? ''),
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
        if (metadata?.pageCount != null)
          LibraryDetailField(
              label: 'Pages', value: metadata!.pageCount.toString()),
        if (metadata?.imprint != null)
          LibraryDetailField(
              label: 'Imprint',
              value: metadata!.imprint!,
              onTap: tapFor(metadata.imprint)),
        if (metadata?.seriesGroup != null)
          LibraryDetailField(
              label: 'Series Group',
              value: metadata!.seriesGroup!,
              onTap: tapFor(metadata.seriesGroup)),
        if (metadata?.subtitle != null)
          LibraryDetailField(label: 'Subtitle', value: metadata!.subtitle!),
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
          values: metadata?.creators ?? const <BookCatalogCredit>[],
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
          itemId: item.target.id,
          kind: CatalogMediaKind.book,
        ),
      );
    }
    final dto = item.dto;
    final metadata = _bookMetadata(item);
    final sectionSpecs = <LibraryDetailSectionSpec>[];

    final originalFacts = <LibraryDetailField>[
      if (metadata?.seriesTitle?.trim().isNotEmpty == true)
        LibraryDetailField(
            label: 'Series', value: metadata!.seriesTitle!.trim()),
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
      for (final creator in metadata?.creators ?? const <BookCatalogCredit>[])
        if (creator.name.trim().isNotEmpty) creator.name.trim(),
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
      if (entry?.personal.condition?.trim().isNotEmpty == true)
        LibraryDetailField(
          label: 'Condition',
          value: entry!.personal.condition!.trim(),
        ),
      if (entry?.personal.grade?.trim().isNotEmpty == true)
        LibraryDetailField(
          label: 'Grade',
          value: entry!.personal.grade!.trim(),
        ),
      if (entry?.personal.collectionStatus?.trim().isNotEmpty == true)
        LibraryDetailField(
            label: 'Collection Status',
            value: entry!.personal.collectionStatus!.trim()),
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
      if (entry?.personal.tags?.trim().isNotEmpty == true)
        LibraryDetailField(
          label: 'Tags',
          value: entry!.personal.tags!.trim(),
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
  final metadata = item.kindCapability.mapTransport(
    (transport) => BookCatalogMetadata.fromJson(transport.kindData),
  );
  final itemNumber = metadata.itemNumber?.trim();
  final subtitle = [
    if (metadata.publisher?.trim() case final value? when value.isNotEmpty)
      value,
    if ((item.bookCatalogFields.releaseYear ??
            item.bookCatalogFields.releaseDate?.year)
        case final year?)
      year.toString(),
    if (metadata.physicalFormat?.trim() case final value? when value.isNotEmpty)
      value,
    if ((metadata.isbn ??
                metadata.isbn13 ??
                metadata.isbn10 ??
                metadata.barcode)
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
  final catalog = item.source.kindPresentationData;
  return catalog is BookWorkspaceData ? catalog.metadata : null;
}
