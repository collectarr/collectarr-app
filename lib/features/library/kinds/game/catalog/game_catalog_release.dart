class GameRelease {
  const GameRelease({
    required this.id,
    required this.title,
    this.platform,
    this.publisher,
    this.catalogNumber,
    this.barcode,
    this.releaseDate,
    this.regionCode,
    this.format,
    this.coverImageUrl,
  });

  final String id;
  final String title;
  final String? platform;
  final String? publisher;
  final String? catalogNumber;
  final String? barcode;
  final DateTime? releaseDate;
  final String? regionCode;
  final String? format;
  final String? coverImageUrl;
}
