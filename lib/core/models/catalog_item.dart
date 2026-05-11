class CatalogItem {
  const CatalogItem({
    required this.id,
    required this.kind,
    required this.title,
    this.itemNumber,
    this.synopsis,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.publisher,
    this.releaseYear,
  });

  final String id;
  final String kind;
  final String title;
  final String? itemNumber;
  final String? synopsis;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? publisher;
  final int? releaseYear;

  String? get displayCoverUrl => thumbnailImageUrl ?? coverImageUrl;

  factory CatalogItem.fromJson(Map<String, dynamic> json) {
    return CatalogItem(
      id: json['id'] as String,
      kind: json['kind'] as String,
      title: json['title'] as String,
      itemNumber: json['item_number'] as String?,
      synopsis: json['synopsis'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      thumbnailImageUrl: json['thumbnail_image_url'] as String?,
      publisher: json['publisher'] as String?,
      releaseYear: json['release_year'] as int?,
    );
  }
}
