import 'package:flutter/foundation.dart';

/// Structural provider reference shared by transport-backed projections.
///
/// A provider link identifies a remote entity; it does not carry catalog
/// metadata or kind-specific mapping behavior.
@immutable
final class ProviderLink {
  const ProviderLink({
    required this.provider,
    required this.entityType,
    required this.providerItemId,
    this.siteUrl,
    this.apiUrl,
  });

  final String provider;
  final String entityType;
  final String providerItemId;
  final String? siteUrl;
  final String? apiUrl;

  factory ProviderLink.fromJson(Map<String, dynamic> json) {
    return ProviderLink(
      provider: json['provider'] as String? ?? '',
      entityType: json['entity_type'] as String? ?? '',
      providerItemId: json['provider_item_id'] as String? ?? '',
      siteUrl: json['site_url'] as String?,
      apiUrl: json['api_url'] as String?,
    );
  }
}
