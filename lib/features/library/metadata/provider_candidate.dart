import 'package:collectarr_app/core/models/catalog_item.dart';

class ProviderCandidate {
  const ProviderCandidate({
    required this.provider,
    required this.providerItemId,
    required this.title,
    required this.kind,
    this.summary,
    this.imageUrl,
    this.candidateType,
    this.seriesTitle,
    this.issueNumber,
    this.volumeStartYear,
    this.variantName,
    this.isVariantOverride,
    this.publisher,
    this.issueCount,
    this.characterPreview = const <String>[],
    this.storyArcPreview = const <String>[],
  });

  final String provider;
  final String providerItemId;
  final String title;
  final String kind;
  final String? summary;
  final String? imageUrl;
  final String? candidateType;
  final String? seriesTitle;
  final String? issueNumber;
  final int? volumeStartYear;
  final String? variantName;
  final bool? isVariantOverride;
  final String? publisher;
  final int? issueCount;
  final List<String> characterPreview;
  final List<String> storyArcPreview;

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
      candidateType: json['candidate_type'] as String?,
      seriesTitle: json['series_title'] as String?,
      issueNumber: json['issue_number'] as String?,
      volumeStartYear: json['volume_start_year'] as int?,
      variantName: json['variant_name'] as String?,
      isVariantOverride: json['is_variant'] as bool?,
      publisher: json['publisher'] as String?,
      issueCount: json['issue_count'] as int?,
      characterPreview: _stringListField(json['character_preview']),
      storyArcPreview: _stringListField(json['story_arc_preview']),
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
    if (candidateType == 'variant') {
      return true;
    }
    if (candidateType == 'series' || candidateType == 'issue') {
      return false;
    }
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

List<String> _stringListField(Object? value) {
  if (value is! List) {
    return const <String>[];
  }
  return value
      .whereType<String>()
      .map((entry) => entry.trim())
      .where((entry) => entry.isNotEmpty)
      .toList(growable: false);
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
