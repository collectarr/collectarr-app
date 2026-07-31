/// Shared book domain types used by the workspace entry model and
/// the book catalog. Living here keeps them importable by boundary
/// files (workspace/entry/) without violating the kind-boundary rule.

/// A reference to a single edition/variant of a book release.
class BookVariantRef {
  const BookVariantRef({
    required this.id,
    required this.name,
    this.variantType,
    this.sku,
    this.barcode,
    this.isbn,
    this.region,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.isPrimary = false,
  });

  final String id;
  final String name;
  final String? variantType;
  final String? sku;
  final String? barcode;
  final String? isbn;
  final String? region;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final bool isPrimary;
  String? get description => null;
}

/// A single release (edition) of a book work.
class BookRelease {
  const BookRelease({
    required this.id,
    required this.title,
    this.publisher,
    this.distributor,
    this.isbn,
    this.upc,
    this.language,
    this.region,
    this.releaseDate,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.dimensions,
    this.firstEdition,
    this.variants = const <BookVariantRef>[],
  });

  final String id;
  final String title;
  final String? publisher;
  final String? distributor;
  final String? isbn;
  final String? upc;
  final String? language;
  final String? region;
  final DateTime? releaseDate;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? dimensions;
  final bool? firstEdition;
  final List<BookVariantRef> variants;
}

/// Optional local-storage paths for physical book cover images.
class BookPhysicalDetails {
  const BookPhysicalDetails({
    this.coverImagePath,
    this.thumbnailImagePath,
    this.backImagePath,
    this.dimensions,
    this.printing,
    this.firstEdition,
    this.dustJacket,
    this.numberLine,
  });

  final String? coverImagePath;
  final String? thumbnailImagePath;
  final String? backImagePath;
  final String? dimensions;
  final String? printing;
  final bool? firstEdition;
  final bool? dustJacket;
  final String? numberLine;
}

/// Original publication details carried on a book catalog item.
class BookOriginalDetails {
  const BookOriginalDetails({
    this.originalTitle,
    this.originalPublisher,
    this.originalLanguage,
    this.originalCountry,
    this.originalPublicationDate,
    this.originalPublicationPlace,
    this.dewey,
    this.lccn,
    this.locControlNumber,
  });

  final String? originalTitle;
  final String? originalPublisher;
  final String? originalLanguage;
  final String? originalCountry;
  final DateTime? originalPublicationDate;
  final String? originalPublicationPlace;
  final String? dewey;
  final String? lccn;
  final String? locControlNumber;

  String? get publisher => originalPublisher;
}
