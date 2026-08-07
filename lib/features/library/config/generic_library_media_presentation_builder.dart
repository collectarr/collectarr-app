import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation_builder_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';

class GenericLibraryMediaPresentationBuilder
    extends LibraryMediaPresentationBuilder {
  const GenericLibraryMediaPresentationBuilder({
    this.metadataLabels = const LibraryMetadataLabels(),
  });

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
    final catalogItem = item.source.catalogItem;
    final series = catalogItem?.series;
    final publishing = catalogItem?.publishing;
    final music = catalogItem?.music;
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
          LibraryDetailField(label: 'Title', value: dto.title),
        ],
        if (series?.seriesTitle != null)
          LibraryDetailField(
              label: 'Series',
              value: series!.seriesTitle!,
              onTap: tapFor(series.seriesTitle)),
        if (hasVolume && !hasSeason)
          LibraryDetailField(
              label: 'Volume',
              value: series!.volumeName ??
                  libraryVolumeLabel(series.volumeNumber != null
                      ? double.tryParse(series.volumeNumber!)
                      : null)),
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
            value: genericLibraryDash(dto.itemNumber),
            onTap: tapFor(dto.itemNumber)),
        LibraryDetailField(
            label: releaseFields.variantLabel,
            value: genericLibraryDash(dto.variant),
            onTap: tapFor(dto.variant)),
        LibraryDetailField(
            label: releaseFields.barcodeLabel,
            value: genericLibraryDash(dto.barcode)),
      ],
      contextFacts: [
        LibraryDetailField(
            label: mediaFields.publisherLabel,
            value: genericLibraryDash(dto.publisher),
            onTap: tapFor(dto.publisher)),
        LibraryDetailField(
            label: 'Released',
            value: genericLibraryDash(
              formatPresentationNullableDate(dto.releaseDate) ??
                  dto.releaseDate?.year.toString(),
            )),
        if (publishing?.pageCount != null)
          LibraryDetailField(
              label: 'Pages', value: publishing!.pageCount.toString()),
        if (music?.catalogNumber != null)
          LibraryDetailField(
              label: 'Catalog No.', value: music!.catalogNumber!),
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
        if (dto.country != null)
          LibraryDetailField(
              label: 'Country',
              value: dto.country!,
              onTap: tapFor(dto.country)),
        if (music?.releaseStatus != null)
          LibraryDetailField(
              label: 'Release Status',
              value: music!.releaseStatus!,
              onTap: tapFor(music.releaseStatus)),
        if (dto.language != null)
          LibraryDetailField(
              label: 'Language',
              value: dto.language!,
              onTap: tapFor(dto.language)),
        if (catalogItem?.ageRating != null)
          LibraryDetailField(
              label: 'Age Rating',
              value: catalogItem!.ageRating!,
              onTap: tapFor(catalogItem.ageRating)),
        if (catalogItem?.audienceRating != null)
          LibraryDetailField(
              label: 'Audience Rating',
              value: catalogItem!.audienceRating!,
              onTap: tapFor(catalogItem.audienceRating)),
        if (referenceVariant?.variantType case final variantType?
            when variantType.trim().isNotEmpty)
          LibraryDetailField(label: 'Variant Type', value: variantType.trim()),
        if (referenceVariant?.sku case final sku? when sku.trim().isNotEmpty)
          LibraryDetailField(label: 'SKU', value: sku.trim()),
        if (referencePlatforms.isNotEmpty)
          LibraryDetailField(
              label: referencePlatforms.length == 1 ? 'Platform' : 'Platforms',
              value: referencePlatforms.join(', '),
              onTap: tapFor(referencePlatforms.join(', '))),
        LibraryDetailField(
            label: 'Cover',
            value: dto.coverImageUrl == null || dto.coverImageUrl!.isEmpty
                ? 'Missing'
                : 'Ready'),
        LibraryDetailField(
            label: 'Metadata',
            value: dto.publisher == null || dto.publisher!.isEmpty
                ? 'Missing'
                : 'Ready'),
      ],
      creators: catalogItem?.creators ?? const <Map<String, dynamic>>[],
      characters: catalogItem?.characters ?? const <String>[],
      storyArcs: catalogItem?.storyArcs ?? const <String>[],
      genres: catalogItem?.genres ?? const <String>[],
    );
  }
}
