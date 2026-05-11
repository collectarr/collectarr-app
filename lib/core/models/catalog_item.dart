class CatalogItem {
  const CatalogItem({
    required this.id,
    required this.kind,
    required this.title,
    this.itemNumber,
    this.synopsis,
    this.coverImageUrl,
  });

  final String id;
  final String kind;
  final String title;
  final String? itemNumber;
  final String? synopsis;
  final String? coverImageUrl;

  factory CatalogItem.fromJson(Map<String, dynamic> json) {
    return CatalogItem(
      id: json['id'] as String,
      kind: json['kind'] as String,
      title: json['title'] as String,
      itemNumber: json['item_number'] as String?,
      synopsis: json['synopsis'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
    );
  }
}
