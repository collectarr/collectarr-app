import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/providers/domain/models/library_entity_scope.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_identity.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_search_hit.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_parent_hint.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_result.dart';
import 'package:collectarr_app/features/providers/transport/provider_series_hint.dart';
import 'provider_search_candidate.dart';

export 'provider_search_candidate.dart';

final class ProviderCandidate implements ProviderSearchCandidate {
  const ProviderCandidate({
    required this.provider,
    required this.providerItemId,
    required this.title,
    required this.kind,
    this.summary,
    this.imageUrl,
    this.candidateType,
    this.artist,
    this.issueNumber,
    this.series,
    this.variantName,
    this.isVariantOverride,
    this.publisher,
    this.issueCount,
    this.mediumTypes = const <String>[],
    this.characterPreview = const <String>[],
    this.storyArcPreview = const <String>[],
    this.parent,
    this.previewOnly = false,
    this.entityScope = LibraryEntityScope.release,
    this.identity,
  });

  @override
  final String provider;
  @override
  final String providerItemId;
  @override
  final String title;
  @override
  final CatalogMediaKind kind;
  @override
  final String? summary;
  @override
  final String? imageUrl;
  @override
  final String? candidateType;
  final String? artist;
  final String? issueNumber;
  final ProviderSeriesHint? series;
  final String? variantName;
  final bool? isVariantOverride;
  final String? publisher;
  final int? issueCount;
  final List<String> mediumTypes;
  final List<String> characterPreview;
  final List<String> storyArcPreview;
  @override
  final ProviderSearchParentHint? parent;

  /// A structural search node used to preview a parent entity. It cannot be
  /// submitted as a concrete catalog item; the user must select a child.
  @override
  final bool previewOnly;
  @override
  final LibraryEntityScope entityScope;
  @override
  final ProviderEntityIdentity? identity;

  factory ProviderCandidate.fromSearchHit(
    ProviderSearchHit hit, {
    String? provider,
  }) {
    return ProviderCandidate(
      provider: provider ?? hit.providerId.value,
      providerItemId: hit.remoteId,
      title: hit.title,
      kind: hit.kind,
      summary: hit.subtitle,
      imageUrl: hit.imageUrl,
      parent: hit.parent,
      entityScope: LibraryEntityScope.release,
      identity: ProviderEntityIdentity(
        provider: provider ?? hit.providerId.value,
        externalId: hit.remoteId,
        scope: LibraryEntityScope.release,
      ),
    );
  }

  factory ProviderCandidate.fromSearchResult(
    ProviderSearchResult result, {
    String? provider,
    bool previewOnly = false,
  }) {
    final series = result.seriesTitle == null && result.volumeStartYear == null
        ? null
        : ProviderSeriesHint(
            seriesTitle: result.seriesTitle,
            volumeStartYear: result.volumeStartYear,
          );
    return ProviderCandidate(
      provider: provider ?? result.provider,
      providerItemId: result.providerItemId,
      title: result.title,
      kind: result.kind,
      summary: result.summary,
      imageUrl: result.imageUrl,
      candidateType: result.candidateType,
      artist: result.artist,
      issueNumber: result.issueNumber,
      series: series,
      variantName: result.variantName,
      isVariantOverride: result.isVariant,
      publisher: result.publisher,
      issueCount: result.issueCount,
      mediumTypes: result.mediumTypes,
      characterPreview: result.characterPreview,
      storyArcPreview: result.storyArcPreview,
      parent: result.parent,
      previewOnly: previewOnly,
      entityScope: result.entityScope,
      identity: ProviderEntityIdentity(
        provider: provider ?? result.provider,
        externalId: result.providerItemId,
        scope: result.entityScope,
      ),
    );
  }

  factory ProviderCandidate.fromJson(Map<String, dynamic> json) {
    final rawKind = (json['kind'] as String?)?.trim();
    if (rawKind == null || rawKind.isEmpty) {
      throw const FormatException(
        'Provider candidate response did not include kind',
      );
    }
    final kind = catalogMediaKindFromApiValue(rawKind);
    if (kind.isUnknown) {
      throw FormatException('Unsupported provider candidate kind: $rawKind');
    }
    final series = ProviderSeriesHint.fromJson(json);
    return ProviderCandidate(
      provider: json['provider'] as String,
      providerItemId: json['provider_item_id'] as String,
      title: json['title'] as String,
      kind: kind,
      summary: json['summary'] as String?,
      imageUrl: json['image_url'] as String?,
      candidateType: json['candidate_type'] as String?,
      artist: json['artist'] as String?,
      issueNumber: json['issue_number'] as String?,
      series: series.hasData ? series : null,
      variantName: json['variant_name'] as String?,
      isVariantOverride: json['is_variant'] as bool?,
      publisher: json['publisher'] as String?,
      issueCount: json['issue_count'] as int?,
      mediumTypes: _stringListField(json['medium_types']),
      characterPreview: _stringListField(json['character_preview']),
      storyArcPreview: _stringListField(json['story_arc_preview']),
      parent: _parentFromJson(json),
      previewOnly: json['preview_only'] == true,
      entityScope: _scopeFromJson(json['entity_scope']),
      identity: _identityFromJson(json),
    );
  }

  @override
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

  @override
  String get localCatalogId {
    final safeProvider = _safeIdPart(provider);
    final safeKind = _safeIdPart(kind.apiValue);
    final safeProviderItemId = Uri.encodeComponent(providerItemId);
    return 'provider:$safeProvider:$safeKind:$safeProviderItemId';
  }

  ProviderCandidate withMediumTypes(Iterable<String> values) {
    return ProviderCandidate(
      provider: provider,
      providerItemId: providerItemId,
      title: title,
      kind: kind,
      summary: summary,
      imageUrl: imageUrl,
      candidateType: candidateType,
      artist: artist,
      issueNumber: issueNumber,
      series: series,
      variantName: variantName,
      isVariantOverride: isVariantOverride,
      publisher: publisher,
      issueCount: issueCount,
      mediumTypes: values.toList(growable: false),
      characterPreview: characterPreview,
      storyArcPreview: storyArcPreview,
      parent: parent,
      previewOnly: previewOnly,
      entityScope: entityScope,
      identity: identity,
    );
  }
}

LibraryEntityScope _scopeFromJson(Object? value) {
  try {
    return LibraryEntityScope.fromApiValue(value);
  } on FormatException {
    return LibraryEntityScope.release;
  }
}

ProviderEntityIdentity? _identityFromJson(Map<String, dynamic> json) {
  final provider = json['provider']?.toString().trim() ?? '';
  final externalId = json['provider_item_id']?.toString().trim() ?? '';
  if (provider.isEmpty || externalId.isEmpty) return null;
  return ProviderEntityIdentity(
    provider: provider,
    externalId: externalId,
    scope: _scopeFromJson(json['entity_scope']),
  );
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

ProviderSearchParentHint? _parentFromJson(Map<String, dynamic> json) {
  final raw = json['parent'];
  if (raw is Map) {
    final parent = ProviderSearchParentHint.fromJson(
      Map<String, dynamic>.from(raw),
    );
    return parent.isValid ? parent : null;
  }
  return null;
}
