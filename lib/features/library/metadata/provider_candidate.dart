import 'package:collectarr_app/core/models/catalog_item.dart';

class ProviderCandidate {
  const ProviderCandidate({
    required this.provider,
    required this.providerItemId,
    required this.title,
    required this.kind,
    this.summary,
    this.imageUrl,
    this.seriesTitle,
    this.issueNumber,
    this.volumeStartYear,
    this.variantName,
    this.isVariantOverride,
  });

  final String provider;
  final String providerItemId;
  final String title;
  final String kind;
  final String? summary;
  final String? imageUrl;
  final String? seriesTitle;
  final String? issueNumber;
  final int? volumeStartYear;
  final String? variantName;
  final bool? isVariantOverride;

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
      seriesTitle: json['series_title'] as String?,
      issueNumber: json['issue_number'] as String?,
      volumeStartYear: json['volume_start_year'] as int?,
      variantName: json['variant_name'] as String?,
      isVariantOverride: json['is_variant'] as bool?,
    );
  }

  CatalogItem placeholderCatalogItem() {
    return CatalogItem(
      id: localCatalogId,
      kind: kind,
      title: title,
      itemNumber: issueNumber,
      synopsis: summary,
      coverImageUrl: imageUrl,
      thumbnailImageUrl: imageUrl,
      releaseYear: volumeStartYear,
      variant: variantName,
    );
  }

  bool get isStub {
    return providerItemId.startsWith('stub-') ||
        title.toLowerCase().contains(' stub)');
  }

  bool get isVariant {
    final explicit = isVariantOverride;
    if (explicit != null) {
      return explicit;
    }
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
