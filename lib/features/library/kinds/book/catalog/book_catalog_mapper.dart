import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_release.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

class BookCatalogMapper {
  const BookCatalogMapper._();

  /// Maps Core API / Cache transport DTO [CatalogItemDto] to domain [BookCatalogItem].
  static BookCatalogItem mapDtoToBook(CatalogItemDto dto) {
    final seriesDetails = dto.series;
    final pub = dto.publishing;

    BookSeriesRef? series;
    if (seriesDetails != null &&
        seriesDetails.seriesId != null &&
        seriesDetails.seriesTitle != null) {
      series = BookSeriesRef(
        seriesId: seriesDetails.seriesId!,
        seriesTitle: seriesDetails.seriesTitle!,
        volumeNumber: seriesDetails.volumeNumber != null
            ? double.tryParse(seriesDetails.volumeNumber!)
            : null,
        seriesGroup: pub?.seriesGroup,
      );
    }

    final creators = dto.creators
            ?.map((creator) => BookCreatorCredit(
                  name: (creator['name'] ?? creator['display_name'] ?? '')
                      .toString(),
                  role: (creator['role'] ?? creator['type'] ?? '').toString(),
                ))
            .toList() ??
        const <BookCreatorCredit>[];

    final work = BookWorkMetadata(
      title: dto.title,
      subtitle: pub?.subtitle,
      originalTitle: dto.originalTitle,
      synopsis: dto.synopsis,
      originalCountry: pub?.originalCountry ?? dto.country,
      originalLanguage: pub?.originalLanguage ?? dto.language,
      originalPublicationDate: pub?.originalPublicationDate,
      originalPublicationPlace: pub?.originalPublicationPlace,
      originalPublisher: pub?.originalPublisher,
      series: series,
      creators: creators,
      subjects: pub?.subjects ?? const [],
      genres: dto.genres ?? const [],
      characters: dto.characters ?? const [],
      storyArcs: dto.storyArcs ?? const [],
    );

    final publishing = BookPublishingMetadata(
      pageCount: pub?.pageCount,
      imprint: pub?.imprint,
      publicationPlace: pub?.publicationPlace,
      paperType: pub?.paperType,
      printedBy: pub?.printedBy,
      dustJacket: pub?.dustJacket,
      dustJacketCondition: pub?.dustJacketCondition,
      firstEdition: pub?.firstEdition,
      audiobookAbridged: pub?.audiobookAbridged,
      coverPriceCents: pub?.coverPriceCents,
      currency: pub?.currency,
      dewey: pub?.dewey,
    );

    final releases = dto.editions
        .map((e) => _mapEditionDtoToRelease(
              e,
              dto.coverImageUrl,
              dto.thumbnailImageUrl,
              dto.editionTitle ?? dto.variant,
              dto.physicalFormatLabel ?? dto.physicalFormat,
            ))
        .toList();

    if (releases.isEmpty) {
      releases.add(BookRelease(
        id: '${dto.id}-release',
        title: dto.editionTitle ?? dto.variant ?? dto.title,
        publisher: dto.publisher,
        coverImageUrl: dto.coverImageUrl,
        releaseDate: dto.releaseDate,
        physicalFormat: dto.physicalFormat,
        physicalFormatLabel: dto.physicalFormatLabel,
        upc: dto.barcode,
      ));
    }

    return BookCatalogItem(
      id: dto.id,
      work: work,
      publishing: publishing,
      releases: releases,
    );
  }

  /// Maps projected item directly to domain [BookCatalogItem].

  /// Maps [LibraryMetadataItem] directly to domain [BookCatalogItem].
  static BookCatalogItem mapMetadataItemToBook(LibraryMetadataItem item) {
    return mapDtoToBook(item.toCatalogItem());
  }

  static BookRelease _mapEditionDtoToRelease(
    CatalogEditionDto edition, [
    String? parentCoverUrl,
    String? parentThumbnailUrl,
    String? parentEditionTitle,
    String? parentPhysicalFormatLabel,
  ]) {
    String? primaryCover;
    String? primaryThumbnail;
    final variantRefs = <BookVariantRef>[];

    for (final v in edition.variants) {
      if (v.coverImageUrl != null && v.coverImageUrl!.isNotEmpty) {
        primaryCover ??= v.coverImageUrl;
      }
      if (v.thumbnailImageUrl != null && v.thumbnailImageUrl!.isNotEmpty) {
        primaryThumbnail ??= v.thumbnailImageUrl;
      }
      variantRefs.add(BookVariantRef(
        id: v.id,
        name: v.name,
        variantType: v.variantType,
        sku: v.sku,
        barcode: v.barcode,
        isbn: v.isbn,
        region: v.region,
        coverImageUrl: v.coverImageUrl,
        thumbnailImageUrl: v.thumbnailImageUrl,
        physicalFormat: v.physicalFormat,
        physicalFormatLabel: v.physicalFormatLabel,
        isPrimary: v.isPrimary,
      ));
    }
    primaryCover ??= parentCoverUrl;
    primaryThumbnail ??= parentThumbnailUrl;

    final releaseTitle = (edition.title.isEmpty || edition.title == 'Edition')
        ? (parentEditionTitle ??
            (variantRefs.isNotEmpty && variantRefs.first.name != 'Variant'
                ? variantRefs.first.name
                : edition.title))
        : edition.title;

    return BookRelease(
      id: edition.id,
      title: releaseTitle,
      publisher: edition.publisher,
      distributor: edition.distributor,
      isbn: edition.isbn,
      upc: edition.upc,
      language: edition.language,
      region: edition.region,
      releaseDate: edition.releaseDate,
      physicalFormat: edition.physicalFormat,
      physicalFormatLabel: (edition.physicalFormatLabel != null &&
              edition.physicalFormatLabel != edition.physicalFormat)
          ? edition.physicalFormatLabel
          : (parentPhysicalFormatLabel ??
              edition.physicalFormatLabel ??
              edition.physicalFormat),
      coverImageUrl: primaryCover,
      thumbnailImageUrl: primaryThumbnail,
      dimensions: edition.metadata?['dimensions'] as String?,
      firstEdition: edition.metadata?['first_edition'] as bool?,
      variants: variantRefs,
    );
  }
}
