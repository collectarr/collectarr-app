import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_release.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

class BookCatalogMapper {
  const BookCatalogMapper._();

  /// Maps Core API / Cache transport DTO [CatalogItemDto] to domain [BookCatalogItem].
  static BookCatalogItem mapDtoToBook(CatalogItemDto dto) {
    final payload = dto.toSyncPayload();
    final seriesDetails = (payload['series'] as Map?) ?? payload;
    final pub = (payload['publishing'] as Map?) ?? payload;

    BookSeriesRef? series;
    final seriesId =
        (seriesDetails['series_id'] ?? seriesDetails['seriesId'])?.toString();
    final seriesTitle =
        (seriesDetails['series_title'] ?? seriesDetails['seriesTitle'])
            ?.toString();
    final volumeNumber =
        (seriesDetails['volume_number'] ?? seriesDetails['volumeNumber'])
            ?.toString();
    if (seriesId != null && seriesTitle != null) {
      series = BookSeriesRef(
        seriesId: seriesId,
        seriesTitle: seriesTitle,
        volumeNumber:
            volumeNumber != null ? double.tryParse(volumeNumber) : null,
        seriesGroup: (pub['series_group'] ?? pub['seriesGroup'])?.toString(),
      );
    }

    final rawCreators =
        (payload['creators'] as List?)?.cast<Map<String, dynamic>>();
    final creators = rawCreators
            ?.map((creator) => BookCreatorCredit(
                  name: (creator['name'] ?? creator['display_name'] ?? '')
                      .toString(),
                  role: (creator['role'] ?? creator['type'] ?? '').toString(),
                ))
            .toList() ??
        const <BookCreatorCredit>[];

    final subjects =
        (pub['subjects'] as List?)?.map((e) => e.toString()).toList() ??
            const [];
    final genres =
        (payload['genres'] as List?)?.map((e) => e.toString()).toList() ??
            const [];
    final characters =
        (payload['characters'] as List?)?.map((e) => e.toString()).toList() ??
            const [];
    final storyArcs =
        (payload['story_arcs'] as List?)?.map((e) => e.toString()).toList() ??
            const [];

    final origPubDate = pub['original_publication_date'] != null
        ? DateTime.tryParse(pub['original_publication_date'].toString())
        : null;

    final work = BookWorkMetadata(
      title: dto.title,
      subtitle: pub['subtitle']?.toString(),
      originalTitle: dto.originalTitle,
      synopsis: dto.synopsis,
      originalCountry:
          (pub['original_country'] ?? payload['country'])?.toString(),
      originalLanguage:
          (pub['original_language'] ?? payload['language'])?.toString(),
      originalPublicationDate: origPubDate,
      originalPublicationPlace: pub['original_publication_place']?.toString(),
      originalPublisher:
          (pub['original_publisher'] ?? payload['publisher'])?.toString(),
      series: series,
      creators: creators,
      subjects: subjects,
      genres: genres,
      characters: characters,
      storyArcs: storyArcs,
    );

    final publishing = BookPublishingMetadata(
      pageCount:
          pub['page_count'] is num ? (pub['page_count'] as num).toInt() : null,
      imprint: pub['imprint']?.toString(),
      publicationPlace: pub['publication_place']?.toString(),
      paperType: pub['paper_type']?.toString(),
      printedBy: pub['printed_by']?.toString(),
      dustJacket: pub['dust_jacket'] is bool
          ? pub['dust_jacket'] as bool
          : (pub['dust_jacket'] != null
              ? bool.tryParse(pub['dust_jacket'].toString())
              : null),
      dustJacketCondition: pub['dust_jacket_condition']?.toString(),
      firstEdition: pub['first_edition'] as bool?,
      audiobookAbridged: pub['audiobook_abridged'] as bool?,
      coverPriceCents: pub['cover_price_cents'] is num
          ? (pub['cover_price_cents'] as num).toInt()
          : null,
      currency: pub['currency']?.toString(),
      dewey: pub['dewey']?.toString(),
    );

    final editionTitle =
        (payload['edition_title'] ?? payload['variant'])?.toString();
    final physicalFormatLabel =
        (payload['physical_format_label'] ?? payload['physical_format'])
            ?.toString();

    final releases = dto.editions
        .map((e) => _mapEditionDtoToRelease(
              e,
              dto.coverImageUrl,
              dto.thumbnailImageUrl,
              editionTitle,
              physicalFormatLabel,
            ))
        .toList();

    if (releases.isEmpty) {
      releases.add(BookRelease(
        id: '${dto.id}-release',
        title: editionTitle ?? dto.title,
        publisher:
            (payload['publisher'] ?? pub['original_publisher'])?.toString(),
        coverImageUrl: dto.coverImageUrl,
        releaseDate: dto.releaseDate,
        physicalFormat: payload['physical_format']?.toString(),
        physicalFormatLabel: physicalFormatLabel,
        upc: payload['barcode']?.toString(),
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
    final rawMetadata = item.kindMetadata;
    final BookCatalogMetadata metadata;
    if (rawMetadata is BookCatalogMetadata) {
      metadata = rawMetadata;
    } else {
      metadata = BookCatalogMetadata.fromJson(rawMetadata.toSyncPayload());
    }

    final seriesDetails = metadata.series;
    final publishing = metadata.publishing;
    final series = seriesDetails == null ||
            seriesDetails.seriesId == null ||
            seriesDetails.seriesTitle == null
        ? null
        : BookSeriesRef(
            seriesId: seriesDetails.seriesId!,
            seriesTitle: seriesDetails.seriesTitle!,
            volumeNumber: seriesDetails.volumeNumber == null
                ? null
                : double.tryParse(seriesDetails.volumeNumber!),
            seriesGroup: publishing?.seriesGroup,
          );
    final creators = metadata.creators
        .map((creator) => BookCreatorCredit(
              name:
                  (creator['name'] ?? creator['display_name'] ?? '').toString(),
              role: (creator['role'] ?? creator['type'] ?? '').toString(),
            ))
        .toList();
    final work = BookWorkMetadata(
      title: metadata.title,
      subtitle: publishing?.subtitle ?? metadata.subtitle,
      originalTitle: metadata.originalTitle,
      synopsis: metadata.synopsis,
      originalCountry: publishing?.originalCountry ?? metadata.country,
      originalLanguage: publishing?.originalLanguage ?? metadata.language,
      originalPublicationDate: publishing?.originalPublicationDate,
      originalPublicationPlace: publishing?.originalPublicationPlace,
      originalPublisher: publishing?.originalPublisher,
      series: series,
      creators: creators,
      subjects: publishing?.subjects ?? metadata.subjects,
      genres: metadata.genres,
      characters: const [],
      storyArcs: const [],
    );
    final publishingMetadata = BookPublishingMetadata(
      pageCount: publishing?.pageCount,
      imprint: publishing?.imprint,
      publicationPlace: publishing?.publicationPlace,
      paperType: publishing?.paperType,
      printedBy: publishing?.printedBy,
      dustJacket: publishing?.dustJacket,
      dustJacketCondition: publishing?.dustJacketCondition,
      firstEdition: publishing?.firstEdition,
      audiobookAbridged: publishing?.audiobookAbridged,
      coverPriceCents: publishing?.coverPriceCents,
      currency: publishing?.currency,
      dewey: publishing?.dewey,
    );
    final releases = metadata.editions
        .map(
          (edition) => BookRelease(
            id: edition.id,
            title: edition.title,
            publisher: edition.publisher,
            isbn: edition.isbn,
            releaseDate: edition.publicationDate,
            physicalFormat: edition.format,
            physicalFormatLabel: edition.format,
            firstEdition: edition.firstEdition,
          ),
        )
        .toList();
    if (releases.isEmpty) {
      releases.add(BookRelease(
        id: '${item.id}-release',
        title: metadata.editionTitle ?? metadata.variant ?? metadata.title,
        publisher: metadata.publisher,
        releaseDate: metadata.publishing?.originalPublicationDate,
        physicalFormat: metadata.physicalFormat,
        physicalFormatLabel: metadata.physicalFormatLabel,
        upc: metadata.barcode,
      ));
    }
    return BookCatalogItem(
      id: item.id,
      work: work,
      publishing: publishingMetadata,
      releases: releases,
    );
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
