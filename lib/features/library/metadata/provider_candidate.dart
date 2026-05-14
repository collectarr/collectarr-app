import 'package:collectarr_app/core/models/catalog_item.dart';

class ProviderCandidate {
  const ProviderCandidate({
    required this.provider,
    required this.providerItemId,
    required this.title,
    required this.kind,
    this.summary,
    this.imageUrl,
  });

  final String provider;
  final String providerItemId;
  final String title;
  final String kind;
  final String? summary;
  final String? imageUrl;

  factory ProviderCandidate.fromJson(
    Map<String, dynamic> json, {
    String? fallbackKind,
  }) {
    final kind = json['kind'] as String? ?? fallbackKind;
    if (kind == null || kind.isEmpty) {
      throw const FormatException(
        'Provider candidate response did not include kind',
      );
    }
    return ProviderCandidate(
      provider: json['provider'] as String,
      providerItemId: json['provider_item_id'] as String,
      title: json['title'] as String,
      kind: kind,
      summary: json['summary'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }

  CatalogItem placeholderCatalogItem() {
    return CatalogItem(id: providerItemId, kind: kind, title: title);
  }
}
