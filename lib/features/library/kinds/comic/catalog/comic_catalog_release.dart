class ComicRelease {
  const ComicRelease({
    required this.id,
    required this.title,
    this.publisher,
    this.imprint,
    this.isbn,
    this.upc,
    this.releaseDate,
    this.coverImageUrl,
  });

  final String id;
  final String title;
  final String? publisher;
  final String? imprint;
  final String? isbn;
  final String? upc;
  final DateTime? releaseDate;
  final String? coverImageUrl;
}
