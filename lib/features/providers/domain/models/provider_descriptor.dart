import 'package:flutter/foundation.dart';

@immutable
class ProviderDescriptor {
  const ProviderDescriptor({
    required this.name,
    required this.displayName,
    required this.kind,
    this.supportedKinds = const [],
    this.supportsSearch = true,
    this.supportsIngest = true,
    this.requiresUserKey = false,
    this.nonCommercialOnly = false,
    this.allowsRedistribution = false,
    this.allowsImageMirroring = false,
    this.requiresAttribution = false,
    this.licenseName,
    this.termsUrl,
    this.attributionUrl,
    this.rateLimit,
    this.cachePolicy,
  });

  final String name;
  final String displayName;
  final String kind;
  final List<String> supportedKinds;
  final bool supportsSearch;
  final bool supportsIngest;
  final bool requiresUserKey;
  final bool nonCommercialOnly;
  final bool allowsRedistribution;
  final bool allowsImageMirroring;
  final bool requiresAttribution;
  final String? licenseName;
  final String? termsUrl;
  final String? attributionUrl;
  final String? rateLimit;
  final String? cachePolicy;

  List<String> get allSupportedKinds =>
      supportedKinds.isNotEmpty ? supportedKinds : [kind];

  bool supportsKind(String targetKind) =>
      allSupportedKinds.contains(targetKind);

  factory ProviderDescriptor.fromJson(Map<String, dynamic> json) {
    final rawKinds = json['supportedKinds'] ?? json['supported_kinds'];
    final supportedKinds = <String>[];
    if (rawKinds is List) {
      for (final k in rawKinds) {
        if (k != null) {
          supportedKinds.add(k.toString());
        }
      }
    }

    return ProviderDescriptor(
      name: json['name']?.toString() ?? '',
      displayName: json['displayName']?.toString() ??
          json['display_name']?.toString() ??
          '',
      kind: json['kind']?.toString() ?? '',
      supportedKinds: supportedKinds,
      supportsSearch: (json['supportsSearch'] ?? json['supports_search']) as bool? ?? true,
      supportsIngest: (json['supportsIngest'] ?? json['supports_ingest']) as bool? ?? true,
      requiresUserKey:
          (json['requiresUserKey'] ?? json['requires_user_key']) as bool? ?? false,
      nonCommercialOnly:
          (json['nonCommercialOnly'] ?? json['non_commercial_only']) as bool? ?? false,
      allowsRedistribution: (json['allowsRedistribution'] ??
          json['allows_redistribution']) as bool? ??
          false,
      allowsImageMirroring: (json['allowsImageMirroring'] ??
          json['allows_image_mirroring']) as bool? ??
          false,
      requiresAttribution:
          (json['requiresAttribution'] ?? json['requires_attribution']) as bool? ?? false,
      licenseName:
          json['licenseName']?.toString() ?? json['license_name']?.toString(),
      termsUrl: json['termsUrl']?.toString() ?? json['terms_url']?.toString(),
      attributionUrl: json['attributionUrl']?.toString() ??
          json['attribution_url']?.toString(),
      rateLimit:
          json['rateLimit']?.toString() ?? json['rate_limit']?.toString(),
      cachePolicy:
          json['cachePolicy']?.toString() ?? json['cache_policy']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'displayName': displayName,
      'kind': kind,
      'supportedKinds': supportedKinds,
      'supportsSearch': supportsSearch,
      'supportsIngest': supportsIngest,
      'requiresUserKey': requiresUserKey,
      'nonCommercialOnly': nonCommercialOnly,
      'allowsRedistribution': allowsRedistribution,
      'allowsImageMirroring': allowsImageMirroring,
      'requiresAttribution': requiresAttribution,
      'licenseName': licenseName,
      'termsUrl': termsUrl,
      'attributionUrl': attributionUrl,
      'rateLimit': rateLimit,
      'cachePolicy': cachePolicy,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProviderDescriptor &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          displayName == other.displayName &&
          kind == other.kind &&
          listEquals(supportedKinds, other.supportedKinds) &&
          supportsSearch == other.supportsSearch &&
          supportsIngest == other.supportsIngest &&
          requiresUserKey == other.requiresUserKey &&
          nonCommercialOnly == other.nonCommercialOnly &&
          allowsRedistribution == other.allowsRedistribution &&
          allowsImageMirroring == other.allowsImageMirroring &&
          requiresAttribution == other.requiresAttribution &&
          licenseName == other.licenseName &&
          termsUrl == other.termsUrl &&
          attributionUrl == other.attributionUrl &&
          rateLimit == other.rateLimit &&
          cachePolicy == other.cachePolicy;

  @override
  int get hashCode => Object.hash(
        name,
        displayName,
        kind,
        Object.hashAll(supportedKinds),
        supportsSearch,
        supportsIngest,
        requiresUserKey,
        nonCommercialOnly,
        allowsRedistribution,
        allowsImageMirroring,
        requiresAttribution,
        licenseName,
        termsUrl,
        attributionUrl,
        rateLimit,
        cachePolicy,
      );
}
