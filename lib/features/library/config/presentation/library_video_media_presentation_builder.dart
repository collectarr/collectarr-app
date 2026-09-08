import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:flutter/material.dart';

class LibraryVideoMediaPresentationBuilder
    extends LibraryMediaPresentationBuilder {
  const LibraryVideoMediaPresentationBuilder({
    this.showSummary = false,
    this.metadataLabels = const LibraryMetadataLabels(),
    this.itemNumberLabel = 'Number',
    this.publisherLabel = 'Publisher',
    this.variantLabel = 'Variant',
    this.barcodeLabel = 'Barcode',
    this.shelfDrilldownEntryTypes = const {},
  });

  final bool showSummary;
  final LibraryMetadataLabels metadataLabels;
  final String itemNumberLabel;
  final String publisherLabel;
  final String variantLabel;
  final String barcodeLabel;
  final Set<String> shelfDrilldownEntryTypes;

  @override
  bool canOpenKindDrilldown(LibraryProjectionView item) {
    final kind = item.source.catalogItem?.kind.trim().toLowerCase();
    return item.node.scope == LibraryBrowserScope.title &&
        kind != null &&
        shelfDrilldownEntryTypes.contains(kind);
  }

  @override
  LibraryMetadataPresentation buildMetadataPresentation({
    required String singularLabel,
    required LibraryProjectionView item,
    required bool includeIdentityFacts,
    required LibraryMetadataFactTapResolver tapFor,
  }) {
    final dto = item.dto;
    final adapter = dto is WorkspaceDtoAdapter ? dto : null;
    final seriesTitle = adapter?.seriesTitle;
    final variant = adapter?.variant;
    final payload = item.source.catalogItem?.toSyncPayload() ?? const {};
    final barcodeVal = (payload['barcode'] ?? payload['upc'])?.toString();
    final publisherVal =
        (payload['publisher'] ?? payload['studio'] ?? payload['network'])
            ?.toString();
    final releaseDate = adapter?.releaseDate;
    final country = adapter?.country;
    final language = adapter?.language;

    return LibraryMetadataPresentation(
      labels: metadataLabels,
      identityFacts: [
        if (includeIdentityFacts) ...[
          LibraryDetailField(label: 'Kind', value: singularLabel),
          LibraryDetailField(label: 'ID', value: item.node.titleItemId),
          LibraryDetailField(label: 'Title', value: dto.title),
        ],
        if (seriesTitle != null)
          LibraryDetailField(
              label: 'Series', value: seriesTitle, onTap: tapFor(seriesTitle)),
        if (item.node.scope != LibraryBrowserScope.title && variant != null)
          LibraryDetailField(
              label: variantLabel, value: variant, onTap: tapFor(variant)),
        if (item.node.scope != LibraryBrowserScope.title && barcodeVal != null)
          LibraryDetailField(label: barcodeLabel, value: barcodeVal),
      ],
      contextFacts: [
        if (publisherVal != null)
          LibraryDetailField(
              label: publisherLabel,
              value: publisherVal,
              onTap: tapFor(publisherVal)),
        LibraryDetailField(
            label: 'Released',
            value: genericLibraryDash(
              formatPresentationNullableDate(releaseDate),
            )),
        if (country != null)
          LibraryDetailField(label: 'Country', value: country),
        if (language != null)
          LibraryDetailField(label: 'Language', value: language),
      ],
      sections: {
        'creators': LibraryMetadataSection(
          values: publisherVal != null
              ? [
                  <String, dynamic>{'name': publisherVal}
                ]
              : const [],
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
    final synopsis = item.source.catalogItem?.synopsis;
    if (!showSummary || synopsis == null || synopsis.trim().isEmpty) {
      return const [];
    }
    return [
      LibraryDetailSection(
        title: 'Summary',
        accentColor: accent,
        children: [
          SelectableText(
            synopsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.4,
                ),
          ),
        ],
      ),
    ];
  }
}
