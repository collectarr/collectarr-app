class CatalogPhysicalFormat {
  const CatalogPhysicalFormat({
    required this.id,
    required this.label,
    required this.mediaFamily,
    required this.variantType,
    this.aliases = const [],
  });

  final String id;
  final String label;
  final String mediaFamily;
  final String variantType;
  final List<String> aliases;

  factory CatalogPhysicalFormat.fromJson(Map<String, dynamic> json) {
    return CatalogPhysicalFormat(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      mediaFamily: json['media_family'] as String? ?? '',
      variantType: json['variant_type'] as String? ?? '',
      aliases: [
        for (final alias in (json['aliases'] as List<dynamic>? ?? []))
          alias.toString(),
      ],
    );
  }
}

class CatalogMediaType {
  const CatalogMediaType({
    required this.kind,
    required this.singularLabel,
    required this.pluralLabel,
    this.routeSegments = const [],
    this.defaultProvider,
    this.providers = const [],
    this.providerSearchPolicy = 'core_miss_then_configured_providers',
    this.isTopLevel = true,
    this.physicalFormats = const [],
  });

  final String kind;
  final String singularLabel;
  final String pluralLabel;
  final List<String> routeSegments;
  final String? defaultProvider;
  final List<String> providers;
  final String providerSearchPolicy;
  final bool isTopLevel;
  final List<CatalogPhysicalFormat> physicalFormats;

  factory CatalogMediaType.fromJson(Map<String, dynamic> json) {
    return CatalogMediaType(
      kind: json['kind'] as String? ?? '',
      singularLabel: json['singular_label'] as String? ?? '',
      pluralLabel: json['plural_label'] as String? ?? '',
      routeSegments: [
        for (final segment in (json['route_segments'] as List<dynamic>? ?? []))
          segment.toString(),
      ],
      defaultProvider: json['default_provider'] as String?,
      providers: [
        for (final provider in (json['providers'] as List<dynamic>? ?? []))
          provider.toString(),
      ],
      providerSearchPolicy: json['provider_search_policy'] as String? ??
          'core_miss_then_configured_providers',
      isTopLevel: json['is_top_level'] as bool? ?? true,
      physicalFormats: [
        for (final format in (json['physical_formats'] as List<dynamic>? ?? []))
          CatalogPhysicalFormat.fromJson(format as Map<String, dynamic>),
      ],
    );
  }
}

class MetadataNormalizedManifest {
  const MetadataNormalizedManifest({
    required this.schemaVersion,
    required this.commonFields,
    required this.kindFields,
    required this.valueTypes,
  });

  final int schemaVersion;
  final List<String> commonFields;
  final Map<String, List<String>> kindFields;
  final Map<String, String> valueTypes;

  factory MetadataNormalizedManifest.fromJson(Map<String, dynamic> json) {
    final rawKindFields =
        json['kind_fields'] as Map<String, dynamic>? ?? const {};
    final kindFields = <String, List<String>>{
      for (final entry in rawKindFields.entries)
        entry.key: [
          for (final value in (entry.value as List<dynamic>? ?? const []))
            value.toString(),
        ],
    };
    final rawValueTypes =
        json['value_types'] as Map<String, dynamic>? ?? const {};
    final valueTypes = <String, String>{
      for (final entry in rawValueTypes.entries)
        entry.key: entry.value.toString(),
    };
    return MetadataNormalizedManifest(
      schemaVersion: json['schema_version'] as int? ?? 0,
      commonFields: [
        for (final value
            in (json['common_fields'] as List<dynamic>? ?? const []))
          value.toString(),
      ],
      kindFields: kindFields,
      valueTypes: valueTypes,
    );
  }
}
