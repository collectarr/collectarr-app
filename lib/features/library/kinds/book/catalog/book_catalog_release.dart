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
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final bool isPrimary;

  String? get thumbnailImageUrl => coverImageUrl;
  String? get description => null;
}

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
  final List<BookVariantRef> variants;
}
