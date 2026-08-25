import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
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
    required LibraryProjectionRuntime item,
    required bool includeIdentityFacts,
    required LibraryMetadataFactTapResolver tapFor,
  }) {
    final rawMetadata = item.source.catalogItem?.kindMetadata;
    final ComicCatalogMetadata metadata;
    if (rawMetadata is ComicCatalogMetadata) {
      metadata = rawMetadata;
    } else if (rawMetadata != null) {
      metadata = ComicCatalogMetadata.fromJson(rawMetadata.toSyncPayload());
    } else {
      throw StateError('Expected ComicCatalogMetadata for comic presentation');
    }
    final series = metadata.series;
    final publishing = metadata.publishing;
    final referenceRelease = resolveLibraryEntryReferenceRelease(item);
    final referenceVariant = referenceRelease.variant;
    final referencePlatforms = libraryReferencePlatforms(item);
    final hasVolume = series?.hasVolume ?? false;
    final hasSeason = series?.hasSeason ?? false;
    final hasEpisode = series?.hasEpisode ?? false;
    return LibraryMetadataPresentation(
      labels: metadataLabels,
      identityFacts: [
        if (includeIdentityFacts) ...[
          LibraryDetailField(label: 'Kind', value: singularLabel),
          LibraryDetailField(label: 'ID', value: item.node.titleItemId),
          LibraryDetailField(label: 'Title', value: metadata.title),
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
            label: mediaFields.numberLabel,
            value: genericLibraryDash(metadata.issueNumber),
            onTap: tapFor(metadata.issueNumber)),
        LibraryDetailField(
            label: releaseFields.variantLabel,
            value: genericLibraryDash(metadata.variant),
            onTap: tapFor(metadata.variant)),
        LibraryDetailField(
            label: releaseFields.barcodeLabel,
            value: genericLibraryDash(metadata.barcode)),
      ],
      contextFacts: [
        LibraryDetailField(
            label: mediaFields.publisherLabel,
            value: genericLibraryDash(metadata.publisher),
            onTap: tapFor(metadata.publisher)),
        LibraryDetailField(
            label: 'Released',
            value: genericLibraryDash(
              formatPresentationNullableDate(metadata.releaseDate) ??
                  metadata.releaseDate?.year.toString(),
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
        if (publishing?.subtitle != null)
          LibraryDetailField(label: 'Subtitle', value: publishing!.subtitle!),
        LibraryDetailField(label: 'Country', value: metadata.country),
        LibraryDetailField(label: 'Language', value: metadata.language),
        if (metadata.ageRating != null)
          LibraryDetailField(label: 'Age Rating', value: metadata.ageRating!),
        if (referenceVariant?.variantType case final variantType?
            when variantType.trim().isNotEmpty)
          LibraryDetailField(label: 'Variant Type', value: variantType.trim()),
        if (referenceVariant?.sku case final sku? when sku.trim().isNotEmpty)
          LibraryDetailField(label: 'SKU', value: sku.trim()),
        if (referenceRelease.edition != null)
          LibraryDetailField(
              label: 'Primary release',
              value: [
                referenceRelease.edition!.title,
                if (referenceVariant?.name.trim().isNotEmpty == true)
                  referenceVariant!.name.trim(),
              ].join(' · ')),
        if (referencePlatforms.isNotEmpty)
          LibraryDetailField(
              label: referencePlatforms.length == 1 ? 'Platform' : 'Platforms',
              value: referencePlatforms.join(', ')),
        LibraryDetailField(
            label: 'Cover',
            value: metadata.releases.isEmpty ? 'Missing' : 'Ready'),
        LibraryDetailField(
            label: 'Metadata',
            value: metadata.publisher == null || metadata.publisher!.isEmpty
                ? 'Missing'
                : 'Ready'),
      ],
      creators: metadata.creators,
      characters: metadata.characters,
      storyArcs: metadata.storyArcs,
      genres: metadata.genres,
    );
  }

  @override
  List<Widget> buildInspectorSections({
    required BuildContext context,
    required LibraryProjectionRuntime item,
    required Color accent,
    ValueChanged<String>? onFilterByValue,
  }) {
    final rawMetadata = item.source.catalogItem?.kindMetadata;
    final synopsis =
        rawMetadata is ComicCatalogMetadata ? rawMetadata.synopsis : null;
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
