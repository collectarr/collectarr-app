final class UserExternalLink {
  UserExternalLink({
    required this.id,
    required this.itemId,
    required this.label,
    required this.url,
    required this.kind,
    required this.createdAt,
    required this.updatedAt,
    this.editionId,
    this.variantId,
  });

  final String id;
  final String itemId;
  final String? editionId;
  final String? variantId;
  final String label;
  final String url;
  final String kind;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isTrailer => kind == 'trailer';

  UserExternalLink copyWith({
    String? label,
    String? url,
    String? kind,
    String? editionId,
    String? variantId,
    DateTime? updatedAt,
  }) {
    return UserExternalLink(
      id: id,
      itemId: itemId,
      editionId: editionId ?? this.editionId,
      variantId: variantId ?? this.variantId,
      label: label ?? this.label,
      url: url ?? this.url,
      kind: kind ?? this.kind,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
