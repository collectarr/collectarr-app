import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/providers/domain/models/normalized_provider_envelope_v1.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_descriptor.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_personal_entry.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_search_result.dart';

abstract interface class MetadataCapability {
  Future<List<ProviderSearchResult>> search(
    String query, {
    CatalogMediaKind? kind,
    int limit = 20,
  });

  Future<NormalizedProviderEnvelopeV1> fetchItem(
    String providerItemId, {
    CatalogMediaKind? kind,
  });
}

abstract interface class PersonalListReadCapability {
  Future<List<ProviderPersonalEntry>> readPersonalList({
    required String accountId,
    CatalogMediaKind? kind,
  });
}

abstract interface class PersonalListWriteCapability {
  Future<void> writePersonalEntry({
    required String accountId,
    required ProviderPersonalEntry entry,
  });

  Future<void> deletePersonalEntry({
    required String accountId,
    required String remoteItemId,
    CatalogMediaKind? kind,
  });
}

abstract interface class FileImportCapability {
  Future<List<ProviderPersonalEntry>> parseFile(
    String content, {
    String? filename,
  });
}

abstract interface class ExternalIdResolverCapability {
  Future<String?> resolveRemoteId({
    required CatalogMediaKind kind,
    required Map<String, String> externalIds,
  });
}

final class ProviderConnector {
  const ProviderConnector({
    required this.id,
    required this.descriptor,
    this.metadata,
    this.personalRead,
    this.personalWrite,
    this.fileImport,
    this.identity,
  });

  final ProviderId id;
  final ProviderDescriptor descriptor;
  final MetadataCapability? metadata;
  final PersonalListReadCapability? personalRead;
  final PersonalListWriteCapability? personalWrite;
  final FileImportCapability? fileImport;
  final ExternalIdResolverCapability? identity;

  bool get supportsMetadata => metadata != null;
  bool get supportsPersonalRead => personalRead != null;
  bool get supportsPersonalWrite => personalWrite != null;
  bool get supportsFileImport => fileImport != null;
  bool get supportsBidirectionalSync =>
      personalRead != null && personalWrite != null;
}
