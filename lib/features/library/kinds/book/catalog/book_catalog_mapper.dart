import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_release.dart';

class BookCatalogMapper {
  const BookCatalogMapper._();

  static BookCatalogItem mapDtoToBook(CatalogItemDto dto) {
    final seriesDetails = dto.series;
    BookSeriesRef? series;
    if (seriesDetails != null &&
        seriesDetails.seriesId != null &&
        seriesDetails.seriesTitle != null) {
      series = BookSeriesRef(
        seriesId: seriesDetails.seriesId!,
        seriesTitle: seriesDetails.seriesTitle!,
        volumeNumber: seriesDetails.volumeNumber,
      );
    }

    final creators = dto.creators
            ?.map((creator) => BookCreatorCredit(
                  name: (creator['name'] ?? creator['display_name'] ?? '').toString(),
                  role: (creator['role'] ?? creator['type'] ?? '').toString(),
                ))
            .toList() ??
        const <BookCreatorCredit>[];

    final pub = dto.publishing;
    final work = BookWorkMetadata(
      title: dto.title,
      subtitle: pub?.subtitle,
      originalTitle: dto.originalTitle,
      synopsis: dto.synopsis,
      originalCountry: pub?.originalCountry,
      originalLanguage: pub?.originalLanguage,
      originalPublicationDate: pub?.originalPublicationDate,
      originalPublisher: pub?.originalPublisher,
      series: series,
      creators: creators,
      subjects: pub?.subjects ?? const [],
      genres: dto.genres ?? const [],
    );

    final publishing = BookPublishingMetadata(
      pageCount: pub?.pageCount,
      imprint: pub?.imprint,
      publicationPlace: pub?.publicationPlace,
      paperType: pub?.paperType,
      printedBy: pub?.printedBy,
      dustJacket: pub?.dustJacket,
      firstEdition: pub?.firstEdition,
    );

    final releases = dto.editions.map((edition) {
      String? variantCover;
      for (final v in edition.variants) {
        if (v.coverImageUrl != null && v.coverImageUrl!.isNotEmpty) {
          variantCover = v.coverImageUrl;
          break;
        }
      }
      return BookRelease(
        id: edition.id,
        title: edition.title,
        publisher: edition.publisher,
        isbn: edition.isbn,
        language: edition.language,
        releaseDate: edition.releaseDate,
        physicalFormat: edition.physicalFormat,
        physicalFormatLabel: edition.physicalFormatLabel,
        coverImageUrl: variantCover ?? dto.coverImageUrl,
      );
    }).toList();

    return BookCatalogItem(
      id: dto.id,
      work: work,
      publishing: publishing,
      releases: releases,
    );
  }
}
