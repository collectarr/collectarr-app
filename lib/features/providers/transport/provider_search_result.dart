import 'package:flutter/foundation.dart';

import '../../../core/models/catalog_media_kind.dart';
import '../domain/models/provider_value_semantics.dart';
import 'provider_search_parent_hint.dart';
import 'provider_search_role.dart';

/// Structural provider search record.
///
/// Only identity and presentation data are shared. Provider/kind-specific
/// search attributes stay behind [payload] and are decoded by the owning
/// kind candidate mapper. This prevents the provider transport from becoming
/// a cross-kind semantic superset.
@immutable
class ProviderSearchResult {
  ProviderSearchResult({
    required this.provider,
    required this.providerItemId,
    required this.title,
    required this.kind,
    required this.searchRole,
    this.summary,
    this.imageUrl,
    Map<String, Object?> payload = const {},
    this.parent,
  }) : payload = immutableProviderPayload(payload);

  final String provider;
  final String providerItemId;
  final String title;
  final CatalogMediaKind kind;
  final String? summary;
  final String? imageUrl;
  final ProviderSearchRole searchRole;

  /// Opaque provider payload. It is intentionally not interpreted here;
  /// selected kind integrations own its schema and decoding.
  final Map<String, Object?> payload;
  final ProviderSearchParentHint? parent;

  factory ProviderSearchResult.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('entity_scope')) {
      throw const FormatException(
        'Provider search results cannot declare a generic entity scope.',
      );
    }
    final rawKind = json['kind']?.toString().trim() ?? '';
    if (rawKind.isEmpty) {
      throw const FormatException(
          'Provider search result did not include kind');
    }
    final kind = catalogMediaKindFromApiValue(rawKind);
    if (kind.isUnknown) {
      throw FormatException(
        'Provider search result has unsupported kind: $rawKind',
      );
    }

    final payload = <String, Object?>{};
    for (final entry in json.entries) {
      if (!_structuralKeys.contains(entry.key) && entry.value != null) {
        payload[entry.key] = entry.value;
      }
    }

    final rawParent = json['parent'];
    final parent = rawParent is Map
        ? ProviderSearchParentHint.fromJson(
            Map<String, dynamic>.from(rawParent),
          )
        : null;

    return ProviderSearchResult(
      provider: json['provider']?.toString() ?? '',
      providerItemId: json['provider_item_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      kind: kind,
      summary: json['summary']?.toString(),
      imageUrl: json['image_url']?.toString(),
      searchRole: providerSearchRoleFromApiValue(json['search_role']),
      payload: payload,
      parent: parent?.isValid == true ? parent : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'provider_item_id': providerItemId,
      'title': title,
      'kind': kind.apiValue,
      'summary': summary,
      'image_url': imageUrl,
      'search_role': searchRole.apiValue,
      ...mutableProviderPayloadCopy(payload),
      if (parent != null) 'parent': parent!.toJson(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProviderSearchResult &&
          runtimeType == other.runtimeType &&
          provider == other.provider &&
          providerItemId == other.providerItemId &&
          title == other.title &&
          kind == other.kind &&
          summary == other.summary &&
          imageUrl == other.imageUrl &&
          searchRole == other.searchRole &&
          providerValueEquals(payload, other.payload) &&
          parent == other.parent;

  @override
  int get hashCode => Object.hash(
        provider,
        providerItemId,
        title,
        kind,
        summary,
        imageUrl,
        searchRole,
        providerValueHashCode(payload),
        parent,
      );
}

const _structuralKeys = <String>{
  'provider',
  'provider_item_id',
  'title',
  'kind',
  'summary',
  'image_url',
  'search_role',
  'parent',
};
