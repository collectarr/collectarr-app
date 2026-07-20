import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

final class MusicWorkspaceDto implements LibraryWorkspaceDto {
  const MusicWorkspaceDto({
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
    required this.catalogNumber,
    required this.discCount,
    required this.trackCount,
    required this.length,
    required this.vinylColor,
    required this.rpm,
    required this.pageCount,
    required this.imprint,
    required this.variant,
    required this.barcode,
    required this.grade,
    required this.country,
    required this.language,
    required this.currency,
    required this.referenceFormatLabel,
    this.coverImageUrl,
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



  final String? catalogNumber;
  final int? discCount;
  final int? trackCount;
  final String? length;
  final String? vinylColor;
  final String? rpm;
  final int pageCount;
  final String? imprint;

  factory MusicWorkspaceDto.fromEntry(LibraryWorkspaceEntry entry) {
    return MusicWorkspaceDto(
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
      catalogNumber: entry.music?.catalogNumber,
      discCount: entry.music?.discCount,
      trackCount: entry.music?.trackCount,
      length: entry.music?.length,
      vinylColor: entry.music?.vinylColor,
      rpm: entry.music?.rpm,
      pageCount: entry.publishing?.pageCount ?? 0,
      imprint: entry.publishing?.imprint,
      variant: entry.variant,
      barcode: entry.barcode,
      grade: entry.grade,
      country: entry.country,
      language: entry.language,
      currency: entry.currency,
      referenceFormatLabel: entry.referenceFormatLabel,
      coverImageUrl: entry.coverImageUrl,
    );
  }


}

