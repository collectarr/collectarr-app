import 'package:flutter/foundation.dart';

import '../../../core/models/catalog_media_kind.dart';
import '../../library/domain/library_entity_scope.dart';
import 'provider_search_parent_hint.dart';
import 'provider_search_role.dart';

/// Structural provider search record.
///
/// Only identity and presentation data are shared. Provider/kind-specific
/// search attributes stay behind [attributes] and are decoded by the owning
/// kind candidate mapper. This prevents the provider transport from becoming
/// a cross-kind semantic superset.
@immutable
class ProviderSearchResult {
  const ProviderSearchResult({
    required this.provider,
    required this.providerItemId,
    required this.title,
    required this.kind,
    required this.searchRole,
    required this.entityScope,
    this.summary,
    this.imageUrl,
    this.attributes = const {},
    this.parent,
  });

  final String provider;
  final String providerItemId;
  final String title;
  final CatalogMediaKind kind;
  final String? summary;
  final String? imageUrl;
  final ProviderSearchRole searchRole;
  final Map<String, Object?> attributes;
  final ProviderSearchParentHint? parent;
  final LibraryEntityScope entityScope;

  String? attributeString(String key) {
    final value = attributes[key];
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  int? attributeInt(String key) {
    final value = attributes[key];
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  bool? attributeBool(String key) {
    final value = attributes[key];
    if (value is bool) return value;
    if (value == null) return null;
    final normalized = value.toString().trim().toLowerCase();
    if (normalized == 'true') return true;
    if (normalized == 'false') return false;
    return null;
  }

  List<String> attributeStrings(String key) {
    final value = attributes[key];
    if (value is! Iterable) return const [];
    return [
      for (final entry in value)
        if (entry != null && entry.toString().trim().isNotEmpty)
          entry.toString().trim(),
    ];
  }

  factory ProviderSearchResult.fromJson(Map<String, dynamic> json) {
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

    final attributes = <String, Object?>{};
    for (final key in _semanticAttributeKeys) {
      if (json.containsKey(key) && json[key] != null) {
        attributes[key] = json[key];
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
      attributes: attributes,
      parent: parent?.isValid == true ? parent : null,
      entityScope: LibraryEntityScope.fromApiValue(json['entity_scope']),
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
      ...attributes,
      if (parent != null) 'parent': parent!.toJson(),
      'entity_scope': entityScope.apiValue,
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
          mapEquals(attributes, other.attributes) &&
          parent == other.parent &&
          entityScope == other.entityScope;

  @override
  int get hashCode => Object.hash(
        provider,
        providerItemId,
        title,
        kind,
        summary,
        imageUrl,
        searchRole,
        Object.hashAll(attributes.entries),
        parent,
        entityScope,
      );
}

const _semanticAttributeKeys = <String>{
  'artist',
  'series_title',
  'issue_number',
  'volume_start_year',
  'variant_name',
  'issue_count',
  'publisher',
  'medium_types',
  'character_preview',
  'story_arc_preview',
  'external_ids',
};
