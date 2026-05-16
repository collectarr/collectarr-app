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
    return CatalogItem(
      id: localCatalogId,
      kind: kind,
      title: title,
      synopsis: summary,
      coverImageUrl: imageUrl,
      thumbnailImageUrl: imageUrl,
    );
  }

  bool get isStub {
    return providerItemId.startsWith('stub-') ||
        title.toLowerCase().contains(' stub)');
  }

  bool get isVariant {
    return _looksLikeVariant(summary) || _looksLikeVariant(title);
  }

  String get localCatalogId {
    final safeProvider = _safeIdPart(provider);
    final safeKind = _safeIdPart(kind);
    final safeProviderItemId = Uri.encodeComponent(providerItemId);
    return 'provider:$safeProvider:$safeKind:$safeProviderItemId';
  }
}

String _safeIdPart(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9_-]+'), '-');
}

bool _looksLikeVariant(String? value) {
  final text = value?.trim().toLowerCase();
  if (text == null || text.isEmpty) {
    return false;
  }
  return text.contains('variant') ||
      text.contains('virgin') ||
      text.contains('foil') ||
      text.contains('exclusive') ||
      text.contains('incentive') ||
      text.contains('ratio') ||
      text.contains('second printing') ||
      text.contains('third printing');
}
