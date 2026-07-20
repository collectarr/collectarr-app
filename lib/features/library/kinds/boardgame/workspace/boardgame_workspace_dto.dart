import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

final class BoardGameWorkspaceDto implements LibraryWorkspaceDto {
  const BoardGameWorkspaceDto({
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
    this.variant,
    this.barcode,
    this.grade,
    this.country,
    this.language,
    this.currency,
    this.referenceFormatLabel,
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

  factory BoardGameWorkspaceDto.fromEntry(LibraryWorkspaceEntry entry) {
    return BoardGameWorkspaceDto(
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
    );
  }
}
