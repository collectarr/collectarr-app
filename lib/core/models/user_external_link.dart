import 'package:collectarr_app/core/models/catalog_entity_ref.dart';

final class UserExternalLink {
  UserExternalLink({
    required this.id,
    required this.catalogRef,
    required this.label,
    required this.url,
    required this.kind,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final CatalogEntityRef catalogRef;
  final String label;
  final String url;
  final String kind;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get itemId => catalogRef.id;

  bool get isTrailer => kind == 'trailer';

  UserExternalLink copyWith({
    String? label,
    String? url,
    String? kind,
    DateTime? updatedAt,
  }) {
    return UserExternalLink(
      id: id,
      catalogRef: catalogRef,
      label: label ?? this.label,
      url: url ?? this.url,
      kind: kind ?? this.kind,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
