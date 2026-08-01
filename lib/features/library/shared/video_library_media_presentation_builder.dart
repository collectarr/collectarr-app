import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/details/library_detail_chip.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_row.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_panel_scaffold.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:flutter/material.dart';

class VideoLibraryMediaPresentationBuilder
    extends LibraryMediaPresentationBuilder {
  const VideoLibraryMediaPresentationBuilder({
    this.showSummary = false,
    this.metadataLabels = const LibraryMetadataLabels(),
  });

  final bool showSummary;
  final LibraryMetadataLabels metadataLabels;

  @override
  LibraryMetadataPresentation buildMetadataPresentation({
    required String singularLabel,
    required MediaEditFields mediaFields,
    required ReleaseEditFields releaseFields,
    required LibraryProjectionRuntime item,
    required bool includeIdentityFacts,
    required LibraryMetadataFactTapResolver tapFor,
  }) {
    final dto = item.dto;
    final cat = item.source.catalogItem;
    return LibraryMetadataPresentation(
      labels: metadataLabels,
      identityFacts: [
        if (includeIdentityFacts) ...[
          LibraryDetailField(label: 'Kind', value: singularLabel),
          LibraryDetailField(label: 'ID', value: item.node.titleItemId),
          LibraryDetailField(label: 'Title', value: dto.title),
        ],
        if (dto.seriesTitle != null)
          LibraryDetailField(label: 'Series', value: dto.seriesTitle!, onTap: tapFor(dto.seriesTitle)),
        if (item.node.browseScope != LibraryBrowserScope.title &&
            dto.variant != null)
          LibraryDetailField(label: releaseFields.variantLabel, value: dto.variant!, onTap: tapFor(dto.variant)),
        if (item.node.browseScope != LibraryBrowserScope.title &&
            dto.barcode != null)
          LibraryDetailField(label: releaseFields.barcodeLabel, value: dto.barcode!),
      ],
      contextFacts: [
        if (dto.publisher != null)
          LibraryDetailField(label: mediaFields.publisherLabel, value: dto.publisher!, onTap: tapFor(dto.publisher)),
        LibraryDetailField(label: 'Released', value: genericLibraryDash(
            formatPresentationNullableDate(dto.releaseDate),
          )),
        if (dto.country != null)
          LibraryDetailField(label: 'Country', value: dto.country!),
        if (dto.language != null)
          LibraryDetailField(label: 'Language', value: dto.language!),
      ],
      creators: dto.creator != null ? [<String, dynamic>{'name': dto.creator}] : const [],
      characters: cat?.genres ?? const [],
      storyArcs: const [],
      genres: cat?.genres ?? const [],
    );
  }

  @override
  List<Widget> buildInspectorSections({
    required BuildContext context,
    required LibraryProjectionRuntime item,
    required Color accent,
    ValueChanged<String>? onFilterByValue,
  }) {
    final synopsis = item.dto.synopsis ?? item.source.catalogItem?.synopsis;
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

