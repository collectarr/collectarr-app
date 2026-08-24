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

  factory CatalogPublishingDetailsDto.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? raw) {
      if (raw == null || raw.trim().isEmpty) return null;
      return DateTime.tryParse(raw.trim());
    }

    final subjects = (json['subjects'] as List<dynamic>?)
            ?.whereType<String>()
            .toList(growable: false) ??
        (json['subject'] as List<dynamic>?)
            ?.whereType<String>()
            .toList(growable: false) ??
        ((json['subject'] as String?)?.trim().isNotEmpty == true
            ? <String>[(json['subject'] as String).trim()]
            : const <String>[]);

    return CatalogPublishingDetailsDto(
      pageCount: json['page_count'] as int?,
      coverPriceCents: json['cover_price_cents'] as int?,
      currency: json['currency'] as String?,
      imprint: json['imprint'] as String?,
      subtitle: json['subtitle'] as String?,
      seriesGroup: json['series_group'] as String?,
      publicationPlace: json['publication_place'] as String?,
      originalCountry: json['original_country'] as String?,
      originalLanguage: json['original_language'] as String?,
      originalPublicationDate:
          parseDate(json['original_publication_date'] as String?),
      originalPublicationPlace: json['original_publication_place'] as String?,
      originalPublisher: json['original_publisher'] as String?,
      paperType: json['paper_type'] as String?,
      printedBy: json['printed_by'] as String?,
      subjects: subjects,
      dustJacketCondition: json['dust_jacket_condition'] as String?,
      dustJacket: json['dust_jacket'] as bool?,
      audiobookAbridged: json['audiobook_abridged'] as bool?,
      firstEdition: json['first_edition'] as bool?,
      dewey: json['dewey'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (pageCount != null) 'page_count': pageCount,
        if (coverPriceCents != null) 'cover_price_cents': coverPriceCents,
        if (currency != null) 'currency': currency,
        if (imprint != null) 'imprint': imprint,
        if (subtitle != null) 'subtitle': subtitle,
        if (seriesGroup != null) 'series_group': seriesGroup,
        if (publicationPlace != null) 'publication_place': publicationPlace,
        if (originalCountry != null) 'original_country': originalCountry,
        if (originalLanguage != null) 'original_language': originalLanguage,
        if (originalPublicationDate != null)
          'original_publication_date':
              originalPublicationDate!.toUtc().toIso8601String(),
        if (originalPublicationPlace != null)
          'original_publication_place': originalPublicationPlace,
        if (originalPublisher != null) 'original_publisher': originalPublisher,
        if (paperType != null) 'paper_type': paperType,
        if (printedBy != null) 'printed_by': printedBy,
        if (subjects.isNotEmpty) 'subjects': subjects,
        if (dustJacketCondition != null)
          'dust_jacket_condition': dustJacketCondition,
        if (dustJacket != null) 'dust_jacket': dustJacket,
        if (audiobookAbridged != null) 'audiobook_abridged': audiobookAbridged,
        if (firstEdition != null) 'first_edition': firstEdition,
        if (dewey != null) 'dewey': dewey,
      };
}

typedef CatalogPublishingDetails = CatalogPublishingDetailsDto;

