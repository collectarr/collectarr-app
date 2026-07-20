class BookRelease {
  const BookRelease({
    required this.id,
    required this.title,
    this.publisher,
    this.isbn,
    this.language,
    this.releaseDate,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.coverImageUrl,
  });

  final String id;
  final String title;
  final String? publisher;
  final String? isbn;
  final String? language;
  final DateTime? releaseDate;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final String? coverImageUrl;
}
