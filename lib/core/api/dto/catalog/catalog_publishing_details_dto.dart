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
    this.subjects = const <String>[],
    this.dustJacketCondition,
    this.dustJacket,
    this.audiobookAbridged,
    this.firstEdition,
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

  bool get hasData =>
      pageCount != null ||
      coverPriceCents != null ||
      currency != null ||
      imprint != null ||
      subtitle != null ||
      seriesGroup != null ||
      publicationPlace != null ||
      originalCountry != null ||
      originalLanguage != null ||
      originalPublicationDate != null ||
      originalPublicationPlace != null ||
      originalPublisher != null ||
      paperType != null ||
      printedBy != null ||
      subjects.isNotEmpty ||
      dustJacketCondition != null ||
      dustJacket != null ||
      audiobookAbridged != null ||
      firstEdition != null;
}
