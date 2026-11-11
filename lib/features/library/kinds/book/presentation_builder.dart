import 'package:collectarr_app/ui/app_formatted_text.dart';
import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/fields.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_library_entry_projection.dart';
import 'package:collectarr_app/features/library/config/duplicate_presentation.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/config/media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/entry_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/data.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/dto.dart';
import 'package:collectarr_app/features/library/details/models.dart';
import 'package:collectarr_app/features/library/details/section.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/book/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/widgets/format_badge.dart';
import 'package:flutter/material.dart';
import 'tracking/book_tracking_profile.dart';

class BookLibraryMediaPresentationBuilder
    extends LibraryMediaPresentationBuilder {
  const BookLibraryMediaPresentationBuilder({
    this.showPersonalDetails = true,
    this.metadataLabels = const LibraryMetadataLabels(),
  });

  final bool showPersonalDetails;
  final LibraryMetadataLabels metadataLabels;

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
              formatNullableDate(releaseDate) ?? releaseDate?.year.toString(),
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
    final metadata = _bookMetadata(item);
    if (metadata == null) return const [];
    final sections = <Widget>[];
    void list(String title, List<String> values) {
      final clean = values.where((value) => value.trim().isNotEmpty).toList();
      if (clean.isEmpty) return;
      sections.add(LibraryDetailSection(title: title, chips: [
        LibraryDetailChipGroup(values: clean, onValueTap: onFilterByValue),
      ]));
    }

    list('Genre', metadata.genres);
    list('Subject', metadata.subjects);
    final plot = metadata.description ??
        metadata.synopsis ??
        metadata.plotDescription ??
        metadata.plotSummary;
    if (plot?.trim().isNotEmpty == true) {
      sections.add(LibraryDetailSection(
          title: 'Plot', children: [AppFormattedText(plot!)]));
    }
    final credits = [...metadata.creators, ...metadata.contributors]
        .where((credit) => credit.role?.toLowerCase() != 'author')
        .map((credit) => LibraryDetailField(
              label: credit.role ?? 'Contributor',
              value: credit.name,
              onTap: onFilterByValue == null
                  ? null
                  : () => onFilterByValue(credit.name),
            ))
        .toList();
    if (credits.isNotEmpty) {
      sections.add(LibraryDetailSection(title: 'Credits', fields: credits));
    }
    final details = <LibraryDetailField>[];
    void detail(String label, Object? value) {
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) {
        details.add(LibraryDetailField(label: label, value: text));
      }
    }

    detail('Original Title', metadata.originalTitle);
    detail('Original Subtitle', metadata.originalSubtitle);
    detail(
        'Original Publication Date',
        metadata.originalPublicationDateParts != null
            ? AppFormats.current
                .formatPartialDate(metadata.originalPublicationDateParts)
            : formatNullableDate(metadata.originalPublicationDate));
    detail('Original Country', metadata.originalCountry);
    detail('Original Publication Place', metadata.originalPublicationPlace);
    detail('Original Language', metadata.originalLanguage);
    detail('Original Publisher', metadata.originalPublisher);
    detail('Extras', metadata.extras.join(', '));
    if (metadata.audioLengthMinutes case final minutes?) {
      detail('Audiobook Length',
          '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}');
    }
    if (metadata.audioAbridged case final abridged?) {
      detail('Audiobook Abridged', abridged ? 'Yes' : 'No');
    }
    detail('Printed By', metadata.printedBy);
    detail('Number Line', metadata.numberLine);
    detail('Paper Type', metadata.paperType);
    detail('Printing', metadata.printingNumber);
    if (metadata.firstEdition case final first?) {
      detail('First Edition', first ? 'Yes' : 'No');
    }
    if (details.isNotEmpty) {
      sections.add(LibraryDetailSection(title: 'Details', fields: details));
    }
    final entry = BookLibraryEntryProjection.fromDispatch(
        item.source.libraryEntryDispatch);
    if (showPersonalDetails && entry != null) {
      final personal = entry.personal;
      final facts = <LibraryDetailField>[
        if (personal.indexNumber != null)
          LibraryDetailField(
              label: 'Index', value: personal.indexNumber.toString()),
        if (personal.ownerLabel?.isNotEmpty == true)
          LibraryDetailField(label: 'Owner', value: personal.ownerLabel!),
        if (item.source.locationPath?.isNotEmpty == true)
          LibraryDetailField(
              label: 'Location', value: item.source.locationPath!),
        if (item.source.trackingSummary case final tracking?) ...[
          LibraryDetailField(
              label: 'Read',
              value: bookTrackingProfile
                      .normalizeStorageValue(tracking.statusStorageValue) ??
                  tracking.statusLabel),
          if (tracking.startedAt != null)
            LibraryDetailField(
                label: 'Started',
                value: formatNullableDate(tracking.startedAt)!),
          if (tracking.completedAt != null)
            LibraryDetailField(
                label: 'Finished',
                value: formatNullableDate(tracking.completedAt)!),
        ],
        if (entry.createdAt != null)
          LibraryDetailField(
              label: 'Added Date',
              value: AppFormats.current.formatDateTime(entry.createdAt!)),
        LibraryDetailField(
            label: 'Modified Date',
            value: AppFormats.current.formatDateTime(entry.updatedAt)),
      ];
      if (facts.isNotEmpty) {
        sections.add(LibraryDetailSection(title: 'Personal', fields: facts));
      }
      final value = <LibraryDetailField>[
        if (personal.details.retailPriceCents != null)
          LibraryDetailField(
              label: 'Retail Price',
              value: AppFormats.current.formatMoney(
                  personal.details.retailPriceCents, personal.currency)),
        if (personal.marketValueCents != null)
          LibraryDetailField(
              label: 'Value',
              value: AppFormats.current
                  .formatMoney(personal.marketValueCents, personal.currency)),
        if (personal.pricePaidCents != null)
          LibraryDetailField(
              label: 'Purchase Price',
              value: AppFormats.current
                  .formatMoney(personal.pricePaidCents, personal.currency)),
        if (personal.sellPriceCents != null)
          LibraryDetailField(
              label: 'Sold Price',
              value: AppFormats.current
                  .formatMoney(personal.sellPriceCents, personal.currency)),
        if (personal.purchaseDate != null)
          LibraryDetailField(
              label: 'Purchase Date',
              value: formatNullableDate(personal.purchaseDate)!),
        if (personal.purchaseStore?.isNotEmpty == true)
          LibraryDetailField(
              label: 'Purchase Store', value: personal.purchaseStore!),
        if (personal.soldAt != null)
          LibraryDetailField(
              label: 'Sold Date', value: formatNullableDate(personal.soldAt)!),
        if (personal.soldTo?.isNotEmpty == true)
          LibraryDetailField(label: 'Sold To', value: personal.soldTo!),
        if (personal.condition?.isNotEmpty == true)
          LibraryDetailField(
              label: 'Book Condition', value: personal.condition!),
        if (personal.details.dustJacketPresent)
          const LibraryDetailField(label: 'Dust Jacket', value: 'Yes'),
        if (personal.details.dustJacketCondition?.isNotEmpty == true)
          LibraryDetailField(
              label: 'Dust Jacket Condition',
              value: personal.details.dustJacketCondition!),
        if (personal.details.signedBy?.isNotEmpty == true)
          LibraryDetailField(
              label: 'Signed by', value: personal.details.signedBy!),
      ];
      if (value.isNotEmpty) {
        sections.add(LibraryDetailSection(title: 'Value', fields: value));
      }
      if (personal.personalNotes?.trim().isNotEmpty == true) {
        sections.add(LibraryDetailSection(
            title: 'Notes',
            children: [AppFormattedText(personal.personalNotes!)]));
      }
      list('Tags', personal.tags);
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
