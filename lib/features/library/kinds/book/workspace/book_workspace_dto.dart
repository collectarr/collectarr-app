import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_mapper.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

final class BookWorkspaceDto implements LibraryWorkspaceDto {
  const BookWorkspaceDto({
    required this.title,
    required this.seriesTitle,
    required this.itemNumber,
    required this.publisher,
    required this.releaseDate,
    required this.isOwned,
    required this.isWishlisted,
    required this.condition,
    required this.locationPath,
    required this.rating,
    required this.pricePaidCents,
    required this.addedAt,
    required this.updatedAt,
    required this.tags,
    required this.collectionStatus,
    required this.variant,
    required this.barcode,
    required this.grade,
    required this.country,
    required this.language,
    required this.currency,
    required this.referenceFormatLabel,
    required this.coverImageUrl,
    required this.book,
  });

  @override
  final String title;
  @override
  final String? seriesTitle;
  @override
  final String? itemNumber;
  @override
  final String? publisher;
  @override
  final DateTime? releaseDate;
  @override
  final bool isOwned;
  @override
  final bool isWishlisted;

  @override
  final String? condition;
  @override
  final String? locationPath;
  @override
  final int? rating;
  @override
  final int? pricePaidCents;
  @override
  final DateTime? addedAt;
  @override
  final DateTime updatedAt;
  @override
  final String? tags;
  @override
  final String? collectionStatus;

  @override
  final String? variant;
  @override
  final String? barcode;
  @override
  final String? grade;
  @override
  final String? country;
  @override
  final String? language;
  @override
  final String? currency;
  @override
  final String? referenceFormatLabel;
  @override
  final String? coverImageUrl;

  final BookCatalogItem book;

  int get pageCount => book.publishing.pageCount ?? 0;
  String? get imprint => book.publishing.imprint;
  String? get author => book.work.creators.firstOrNull?.name;

  factory BookWorkspaceDto.fromEntry(LibraryWorkspaceEntry entry) {
    // Construct transport DTO first
    final dto = CatalogItemDto(
      id: entry.id,
      title: entry.title,
      displayTitle: entry.displayTitle,
      localizedTitle: entry.localizedTitle,
      originalTitle: entry.originalTitle,
      synopsis: entry.synopsis,
      coverImageUrl: entry.coverImageUrl,
      thumbnailImageUrl: entry.thumbnailImageUrl,
      publisher: entry.publisher,
      coverDate: entry.coverDate,
      releaseDate: entry.releaseDate,
      releaseYear: entry.releaseYear,
      barcode: entry.barcode,
      variant: entry.variant,
      creators: entry.creators,
      storyArcs: entry.storyArcs,
      genres: entry.genres,
      country: entry.country,
      language: entry.language,
      ageRating: entry.ageRating,
      audienceRating: entry.audienceRating,
      publishing: entry.publishing,
      series: entry.series,
      editions: entry.editions,
    );

    // Map to Book domain model using composition
    final bookCatalogItem = BookCatalogMapper.mapDtoToBook(dto);

    return BookWorkspaceDto(
      title: entry.resolvedTitle,
      seriesTitle: entry.series?.seriesTitle,
      itemNumber: entry.itemNumber,
      publisher: entry.publisher,
      releaseDate: entry.releaseDate,
      isOwned: entry.isOwned,
      isWishlisted: entry.isWishlisted,
      condition: entry.condition,
      locationPath: entry.locationPath,
      rating: entry.rating,
      pricePaidCents: entry.pricePaidCents,
      addedAt: entry.addedAt,
      updatedAt: entry.updatedAt,
      tags: entry.tags,
      collectionStatus: entry.collectionStatus,
      variant: entry.variant,
      barcode: entry.barcode,
      grade: entry.grade,
      country: entry.country,
      language: entry.language,
      currency: entry.currency,
      referenceFormatLabel: entry.referenceFormatLabel,
      coverImageUrl: entry.coverImageUrl,
      book: bookCatalogItem,
    );
  }
}
