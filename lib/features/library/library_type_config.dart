import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';

class LibraryMetadataProviderOption {
  const LibraryMetadataProviderOption({
    required this.id,
    required this.label,
    this.description,
    this.supportedKinds = const {},
    this.requiresApiKey = false,
    this.usagePolicy,
  });

  final String id;
  final String label;
  final String? description;
  final Set<String> supportedKinds;
  final bool requiresApiKey;
  final LibraryMetadataProviderUsagePolicy? usagePolicy;

  bool supportsKind(String kind) {
    final normalized = kind.trim().toLowerCase();
    return supportedKinds.isEmpty || supportedKinds.contains(normalized);
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

class LibraryTypeConfig {
  const LibraryTypeConfig({
    required this.workspace,
    required this.singularLabel,
    required this.pluralLabel,
    required this.defaultMetadataProvider,
    required this.metadataProviders,
    required this.trackingProfile,
  });

  final LibraryWorkspaceConfig workspace;
  final String singularLabel;
  final String pluralLabel;
  final String defaultMetadataProvider;
  final List<LibraryMetadataProviderOption> metadataProviders;
  final MediaTrackingProfile trackingProfile;

  List<LibraryMetadataProviderOption> get supportedMetadataProviders {
    return [
      for (final provider in metadataProviders)
        if (provider.supportsKind(workspace.kind)) provider,
    ];
  }

  String get defaultSupportedMetadataProvider {
    return defaultSupportedMetadataProviderOption?.id ??
        defaultMetadataProvider;
  }

  LibraryMetadataProviderOption? get defaultSupportedMetadataProviderOption {
    final options = supportedMetadataProviders;
    for (final option in options) {
      if (option.id == defaultMetadataProvider) {
        return option;
      }
    }
    return options.isEmpty ? null : options.first;
  }

  LibraryMetadataProviderOption? get defaultMetadataProviderOption {
    for (final option in supportedMetadataProviders) {
      if (option.id == defaultMetadataProvider) {
        return option;
      }
    }
    return null;
  }

  bool supportsMetadataProvider(String providerId) {
    return supportedMetadataProviders.any((option) => option.id == providerId);
  }

  String countLabel(int count) {
    return count == 1 ? singularLabel : pluralLabel;
  }

  String metadataProviderLabel(String providerId) {
    for (final option in metadataProviders) {
      if (option.id == providerId) {
        return option.label;
      }
    }
    return providerId;
  }
}
