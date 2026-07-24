class WorkspaceCommonProjection {
  const WorkspaceCommonProjection({
    required this.title,
    this.seriesTitle,
    this.itemNumber,
    this.publisher,
    this.releaseDate,
    this.variant,
    this.barcode,
    this.grade,
    this.country,
    this.language,
    this.currency,
    this.referenceFormatLabel,
    this.coverImageUrl,
  });

  final String title;
  final String? seriesTitle;
  final String? itemNumber;
  final String? publisher;
  final DateTime? releaseDate;
  final String? variant;
  final String? barcode;
  final String? grade;
  final String? country;
  final String? language;
  final String? currency;
  final String? referenceFormatLabel;
  final String? coverImageUrl;
}

class PersonalCopyProjection {
  const PersonalCopyProjection({
    this.isOwned = false,
    this.isWishlisted = false,
    this.condition,
    this.locationPath,
    this.rating,
    this.pricePaidCents,
    this.addedAt,
    required this.updatedAt,
    this.tags,
    this.collectionStatus,
  });

  final bool isOwned;
  final bool isWishlisted;
  final String? condition;
  final String? locationPath;
  final int? rating;
  final int? pricePaidCents;
  final DateTime? addedAt;
  final DateTime updatedAt;
  final String? tags;
  final String? collectionStatus;
}
