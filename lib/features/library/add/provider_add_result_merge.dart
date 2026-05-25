import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

LibraryMetadataItem mergeProviderAddResult({
  required LibraryMetadataItem ingested,
  required LibraryMetadataItem edited,
}) {
  final mergedPublishing = CatalogPublishingDetails(
    pageCount: ingested.publishing?.pageCount,
    coverPriceCents: ingested.publishing?.coverPriceCents,
    currency: ingested.publishing?.currency,
    imprint: edited.publishing?.imprint,
    subtitle: ingested.publishing?.subtitle,
    seriesGroup: edited.publishing?.seriesGroup,
  );

  return ingested.copyWith(
    title: edited.title,
    itemNumber: edited.itemNumber,
    synopsis: edited.synopsis,
    coverImageUrl: edited.coverImageUrl ?? ingested.coverImageUrl,
    thumbnailImageUrl: edited.thumbnailImageUrl ?? ingested.thumbnailImageUrl,
    editionTitle: edited.editionTitle,
    physicalFormat: edited.physicalFormat,
    physicalFormatLabel: edited.physicalFormatLabel,
    publisher: edited.publisher,
    releaseDate: edited.releaseDate,
    releaseYear: edited.releaseYear,
    barcode: edited.barcode,
    variant: edited.variant,
    series: edited.series ?? ingested.series,
    publishing: mergedPublishing.hasData ? mergedPublishing : null,
    creators: edited.creators ?? ingested.creators,
    characters: edited.characters ?? ingested.characters,
    storyArcs: edited.storyArcs ?? ingested.storyArcs,
    genres: edited.genres ?? ingested.genres,
    country: edited.country ?? ingested.country,
    language: edited.language ?? ingested.language,
    ageRating: edited.ageRating ?? ingested.ageRating,
  );
}