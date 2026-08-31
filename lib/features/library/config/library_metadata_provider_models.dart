import 'package:collectarr_app/core/models/catalog_media_kind.dart';

class LibraryMetadataProviderOption {
  const LibraryMetadataProviderOption({
    required this.id,
    required this.label,
    this.description,
    this.supportedKinds = const {},
    this.requiresApiKey = false,
    this.usagePolicy,
  });

  factory LibraryMetadataProviderOption.fromDescriptor(
    dynamic descriptor,
  ) {
    // Supports ProviderDescriptor or any object with equivalent properties
    final name = descriptor.name?.toString() ?? '';
    final displayName = descriptor.displayName?.toString() ?? name;
    final supportedKinds = (descriptor.allSupportedKinds as List?)
            ?.map((e) => e.toString())
            .toSet() ??
        <String>{};
    final requiresUserKey = descriptor.requiresUserKey == true;
    final requiresAttribution = descriptor.requiresAttribution == true;
    final nonCommercialOnly = descriptor.nonCommercialOnly == true;
    final cachePolicy = descriptor.cachePolicy?.toString();
    final licenseName = descriptor.licenseName?.toString();
    final summary = cachePolicy ??
        (licenseName != null
            ? '$licenseName metadata with attribution requirements'
            : (requiresAttribution ? 'Attribution required' : ''));

    return LibraryMetadataProviderOption(
      id: name,
      label: displayName,
      description: cachePolicy ?? licenseName,
      supportedKinds: supportedKinds,
      requiresApiKey: requiresUserKey,
      usagePolicy: requiresAttribution || nonCommercialOnly || summary.isNotEmpty
          ? LibraryMetadataProviderUsagePolicy(
              summary: summary,
              requiresAttribution: requiresAttribution,
              nonCommercialOnly: nonCommercialOnly,
            )
          : null,
    );
  }

  factory LibraryMetadataProviderOption.fromConnector(dynamic connector) {
    return LibraryMetadataProviderOption.fromDescriptor(connector.descriptor);
  }

  final String id;
  final String label;
  final String? description;
  final Set<String> supportedKinds;
  final bool requiresApiKey;
  final LibraryMetadataProviderUsagePolicy? usagePolicy;

  bool supportsKind(CatalogMediaKind kind) {
    return supportedKinds.isEmpty || supportedKinds.contains(kind.apiValue);
  }

  bool supportsRawKind(String kind) {
    return supportedKinds.isEmpty ||
        supportedKinds.contains(kind.trim().toLowerCase());
  }
}

class LibraryMetadataProviderUsagePolicy {
  const LibraryMetadataProviderUsagePolicy({
    required this.summary,
    this.requiresAttribution = false,
    this.nonCommercialOnly = false,
  });

  final String summary;
  final bool requiresAttribution;
  final bool nonCommercialOnly;
}
