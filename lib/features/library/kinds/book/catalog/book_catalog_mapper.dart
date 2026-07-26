import 'package:collectarr_app/core/api/dto/catalog/catalog_edition_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_publishing_details_dto.dart';

import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_release.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

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
                  name: (creator['name'] ?? creator['display_name'] ?? '').toString(),
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
    );

    final releases = dto.editions.map(_mapEditionDtoToRelease).toList();

    return BookCatalogItem(
      id: dto.id,
      work: work,
      publishing: publishing,
      releases: releases,
    );
  }

  /// Maps [LibraryWorkspaceEntry] directly to domain [BookCatalogItem].
  ///
  /// Transitional: Preference is to construct domain models from DTOs rather than workspace entries.
  @Deprecated('Transitional workspace entry mapper. Prefer building BookCatalogItem from DTOs.')
  static BookCatalogItem mapWorkspaceEntryToBook(LibraryWorkspaceEntry entry) {
    final seriesDetails = entry.series;
    final pub = entry.publishing;

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

    final creators = entry.creators
            ?.map((Map<String, dynamic> creator) => BookCreatorCredit(
                  name: (creator['name'] ?? creator['display_name'] ?? '').toString(),
                  role: (creator['role'] ?? creator['type'] ?? '').toString(),
                ))
            .toList() ??
        const <BookCreatorCredit>[];

    final work = BookWorkMetadata(
      title: entry.title,
      subtitle: pub?.subtitle,
      originalTitle: entry.originalTitle,
      synopsis: entry.synopsis,
      originalCountry: pub?.originalCountry ?? entry.country,
      originalLanguage: pub?.originalLanguage ?? entry.language,
      originalPublicationDate: pub?.originalPublicationDate,
      originalPublicationPlace: pub?.originalPublicationPlace,
      originalPublisher: pub?.originalPublisher,
      series: series,
      creators: creators,
      subjects: pub?.subjects ?? const [],
      genres: entry.genres ?? const [],
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
    );

    final releases = entry.editions.map(_mapEditionDtoToRelease).toList();

    return BookCatalogItem(
      id: entry.id,
      work: work,
      publishing: publishing,
      releases: releases,
    );
  }

  /// Maps [LibraryMetadataItem] directly to domain [BookCatalogItem].
  static BookCatalogItem mapMetadataItemToBook(LibraryMetadataItem item) {
    final seriesDetails = item.series;
    final pub = item.publishing;

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

    final creators = item.creators
            ?.map((Map<String, dynamic> creator) => BookCreatorCredit(
                  name: (creator['name'] ?? creator['display_name'] ?? '').toString(),
                  role: (creator['role'] ?? creator['type'] ?? '').toString(),
                ))
            .toList() ??
        const <BookCreatorCredit>[];

    final work = BookWorkMetadata(
      title: item.title,
      subtitle: pub?.subtitle,
      originalTitle: item.originalTitle,
      synopsis: item.synopsis,
      originalCountry: pub?.originalCountry ?? item.country,
      originalLanguage: pub?.originalLanguage ?? item.language,
      originalPublicationDate: pub?.originalPublicationDate,
      originalPublicationPlace: pub?.originalPublicationPlace,
      originalPublisher: pub?.originalPublisher,
      series: series,
      creators: creators,
      subjects: pub?.subjects ?? const [],
      genres: item.genres ?? const [],
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
    );

    final releases = item.editions.map(_mapEditionDtoToRelease).toList();

    return BookCatalogItem(
      id: item.id,
      work: work,
      publishing: publishing,
      releases: releases,
    );
  }

  static BookRelease _mapEditionDtoToRelease(CatalogEditionDto edition) {
    String? primaryCover;
    final variantRefs = <BookVariantRef>[];

    for (final v in edition.variants) {
      if (v.coverImageUrl != null && v.coverImageUrl!.isNotEmpty) {
        primaryCover ??= v.coverImageUrl;
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
        physicalFormat: v.physicalFormat,
        physicalFormatLabel: v.physicalFormatLabel,
        isPrimary: v.isPrimary,
      ));
    }

    return BookRelease(
      id: edition.id,
      title: edition.title,
      publisher: edition.publisher,
      distributor: edition.distributor,
      isbn: edition.isbn,
      upc: edition.upc,
      language: edition.language,
      region: edition.region,
      releaseDate: edition.releaseDate,
      physicalFormat: edition.physicalFormat,
      physicalFormatLabel: edition.physicalFormatLabel,
      coverImageUrl: primaryCover,
      variants: variantRefs,
    );
  }
}
