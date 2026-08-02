class CatalogPublishingDetailsDto {
  const CatalogPublishingDetailsDto({
    this.pageCount,
    this.coverPriceCents,
    this.currency,
    this.imprint,
    this.subtitle,
    this.seriesGroup,
    this.publicationPlace,
    this.originalCountry,
    this.originalLanguage,
    this.originalPublicationDate,
    this.originalPublicationPlace,
    this.originalPublisher,
    this.paperType,
    this.printedBy,
    this.subjects = const [],
    this.dustJacketCondition,
    this.dustJacket,
    this.audiobookAbridged,
    this.firstEdition,
    this.dewey,
  });

  final int? pageCount;
  final int? coverPriceCents;
  final String? currency;
  final String? imprint;
  final String? subtitle;
  final String? seriesGroup;
  final String? publicationPlace;
  final String? originalCountry;
  final String? originalLanguage;
  final DateTime? originalPublicationDate;
  final String? originalPublicationPlace;
  final String? originalPublisher;
  final String? paperType;
  final String? printedBy;
  final List<String> subjects;
  final String? dustJacketCondition;
  final bool? dustJacket;
  final bool? audiobookAbridged;
  final bool? firstEdition;
  final String? dewey;

  bool get hasData =>
      pageCount != null ||
      coverPriceCents != null ||
      (currency != null && currency!.isNotEmpty) ||
      (imprint != null && imprint!.isNotEmpty) ||
      (subtitle != null && subtitle!.isNotEmpty) ||
      (seriesGroup != null && seriesGroup!.isNotEmpty) ||
      (publicationPlace != null && publicationPlace!.isNotEmpty) ||
      (originalCountry != null && originalCountry!.isNotEmpty) ||
      (originalLanguage != null && originalLanguage!.isNotEmpty) ||
      originalPublicationDate != null ||
      (originalPublicationPlace != null &&
          originalPublicationPlace!.isNotEmpty) ||
      (originalPublisher != null && originalPublisher!.isNotEmpty) ||
      (paperType != null && paperType!.isNotEmpty) ||
      (printedBy != null && printedBy!.isNotEmpty) ||
      subjects.isNotEmpty ||
      (dustJacketCondition != null && dustJacketCondition!.isNotEmpty) ||
      dustJacket != null ||
      audiobookAbridged != null ||
      firstEdition != null;
}

typedef CatalogPublishingDetails = CatalogPublishingDetailsDto;
