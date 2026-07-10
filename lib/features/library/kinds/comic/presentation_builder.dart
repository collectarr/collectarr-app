import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/details/library_detail_chip.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_row.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_panel_scaffold.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';

class ComicLibraryMediaPresentationBuilder
    extends LibraryMediaPresentationBuilder {
  const ComicLibraryMediaPresentationBuilder({
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
    required LibraryWorkspaceEntry entry,
    required bool includeIdentityFacts,
    required LibraryMetadataFactTapResolver tapFor,
  }) {
    final series = entry.series;
    final publishing = entry.publishing;
    final music = entry.music;
    final referenceRelease = resolveLibraryEntryReferenceRelease(entry);
    final referenceVariant = referenceRelease.variant;
    final referencePlatforms = libraryReferencePlatforms(entry);
    final hasVolume = series?.hasVolume ?? false;
    final hasSeason = series?.hasSeason ?? false;
    final hasEpisode = series?.hasEpisode ?? false;
    return LibraryMetadataPresentation(
      labels: metadataLabels,
      identityFacts: [
        if (includeIdentityFacts) ...[
          LibraryDetailField(label: 'Kind', value: singularLabel),
          LibraryDetailField(label: 'ID', value: entry.id),
          LibraryDetailField(label: 'Title', value: entry.title),
        ],
        if (series?.seriesTitle != null)
          LibraryDetailField(label: 'Series', value: series!.seriesTitle!, onTap: tapFor(series.seriesTitle)),
        if (hasVolume && !hasSeason)
          LibraryDetailField(label: 'Volume', value: series!.volumeName ?? libraryVolumeLabel(series.volumeNumber)),
        if (hasSeason && hasEpisode)
          LibraryDetailField(label: 'Season / Episode', value: 'Season ${series!.seasonNumber}, Ep. ${series.episodeNumber}'),
        if (hasSeason && !hasEpisode)
          LibraryDetailField(label: 'Season', value: 'Season ${series!.seasonNumber}'),
        if (hasEpisode && !hasSeason)
          LibraryDetailField(label: 'Episode', value: 'Ep. ${series!.episodeNumber}'),
        LibraryDetailField(label: mediaFields.numberLabel, value: genericLibraryDash(entry.itemNumber), onTap: tapFor(entry.itemNumber)),
        LibraryDetailField(label: releaseFields.variantLabel, value: genericLibraryDash(entry.variant), onTap: tapFor(entry.variant)),
        LibraryDetailField(label: releaseFields.barcodeLabel, value: genericLibraryDash(entry.barcode)),
      ],
      contextFacts: [
        LibraryDetailField(label: mediaFields.publisherLabel, value: genericLibraryDash(entry.publisher), onTap: tapFor(entry.publisher)),
        LibraryDetailField(label: 'Released', value: genericLibraryDash(
            formatPresentationNullableDate(entry.releaseDate) ??
                entry.releaseYear?.toString(),
          )),
        if (publishing?.pageCount != null)
          LibraryDetailField(label: 'Pages', value: publishing!.pageCount.toString()),
        if (music?.catalogNumber != null)
          LibraryDetailField(label: 'Catalog No.', value: music!.catalogNumber!),
        if (publishing?.coverPriceCents != null)
          LibraryDetailField(label: 'Cover Price', value: formatPresentationMoney(
              publishing!.coverPriceCents,
              publishing.currency,
            )),
        if (publishing?.imprint != null)
          LibraryDetailField(label: 'Imprint', value: publishing!.imprint!, onTap: tapFor(publishing.imprint)),
        if (publishing?.seriesGroup != null)
          LibraryDetailField(label: 'Series Group', value: publishing!.seriesGroup!, onTap: tapFor(publishing.seriesGroup)),
        if (publishing?.subtitle != null)
          LibraryDetailField(label: 'Subtitle', value: publishing!.subtitle!),
        if (entry.country != null)
          LibraryDetailField(label: 'Country', value: entry.country!),
        if (music?.releaseStatus != null)
          LibraryDetailField(label: 'Release Status', value: music!.releaseStatus!),
        if (entry.language != null)
          LibraryDetailField(label: 'Language', value: entry.language!),
        if (entry.ageRating != null)
          LibraryDetailField(label: 'Age Rating', value: entry.ageRating!),
        if (entry.audienceRating != null)
          LibraryDetailField(label: 'Audience Rating', value: entry.audienceRating!),
        if (referenceVariant?.variantType case final variantType?
            when variantType.trim().isNotEmpty)
          LibraryDetailField(label: 'Variant Type', value: variantType.trim()),
        if (referenceVariant?.sku case final sku? when sku.trim().isNotEmpty)
          LibraryDetailField(label: 'SKU', value: sku.trim()),
        if (referencePlatforms.isNotEmpty)
          LibraryDetailField(label: referencePlatforms.length == 1 ? 'Platform' : 'Platforms', value: referencePlatforms.join(', ')),
        LibraryDetailField(label: 'Cover', value: entry.hasMissingCover ? 'Missing' : 'Ready'),
        LibraryDetailField(label: 'Metadata', value: entry.hasMissingMetadata ? 'Missing' : 'Ready'),
      ],
      creators: entry.creators ?? const <Map<String, dynamic>>[],
      characters: entry.characters ?? const <String>[],
      storyArcs: entry.storyArcs ?? const <String>[],
      genres: entry.genres ?? const <String>[],
    );
  }

  @override
  List<Widget> buildInspectorSections({
    required BuildContext context,
    required LibraryWorkspaceEntry entry,
    required Color accent,
    ValueChanged<String>? onFilterByValue,
  }) {
    if (!showSummary ||
        entry.synopsis == null ||
        entry.synopsis!.trim().isEmpty) {
      return const [];
    }
    return [
      LibraryDetailSection(
        title: 'Summary',
        accentColor: accent,
        children: [
          Text(
            entry.synopsis!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    ];
  }
}
