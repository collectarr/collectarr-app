import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_connector.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_descriptor.dart';

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
    ProviderDescriptor descriptor,
  ) {
    final name = descriptor.name;
    final displayName = descriptor.displayName;
    final supportedKinds = descriptor.allSupportedKinds.toSet();
    final requiresUserKey = descriptor.requiresUserKey;
    final requiresAttribution = descriptor.requiresAttribution;
    final nonCommercialOnly = descriptor.nonCommercialOnly;
    final cachePolicy = descriptor.cachePolicy;
    final licenseName = descriptor.licenseName;
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
      usagePolicy:
          requiresAttribution || nonCommercialOnly || summary.isNotEmpty
              ? LibraryMetadataProviderUsagePolicy(
                  summary: summary,
                  requiresAttribution: requiresAttribution,
                  nonCommercialOnly: nonCommercialOnly,
                )
              : null,
    );
  }

  factory LibraryMetadataProviderOption.fromConnector(
      ProviderConnector connector) {
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
