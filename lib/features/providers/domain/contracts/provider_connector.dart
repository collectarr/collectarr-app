import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/providers/domain/models/normalized_provider_envelope_v1.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_descriptor.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_image_ref.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_personal_entry.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_search_result.dart';

abstract interface class MetadataCapability {
  Future<List<ProviderSearchResult>> search(
    String query, {
    covariant Object? kind,
    int limit = 25,
  });

  Future<NormalizedProviderEnvelopeV1> fetchItem(
    String providerItemId, {
    covariant Object? kind,
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

abstract interface class IdentityCapability {
  Future<String?> resolveRemoteId({
    required CatalogMediaKind kind,
    required Map<String, String> externalIds,
  });
}

typedef ExternalIdResolverCapability = IdentityCapability;

abstract interface class ImageCapability {
  Future<List<ProviderImageRef>> fetchImages(
    String remoteItemId, {
    CatalogMediaKind? kind,
  });
}

abstract interface class BarcodeCapability {
  Future<NormalizedProviderEnvelopeV1?> lookupByBarcode(
    String barcode, {
    CatalogMediaKind? kind,
  });
}

final class ProviderConnector implements MetadataCapability {
  const ProviderConnector({
    required this.id,
    required this.descriptor,
    this.metadata,
    this.personalRead,
    this.personalWrite,
    this.fileImport,
    this.identity,
    this.images,
    this.barcode,
  });

  final ProviderId id;
  final ProviderDescriptor descriptor;
  final MetadataCapability? metadata;
  final PersonalListReadCapability? personalRead;
  final PersonalListWriteCapability? personalWrite;
  final FileImportCapability? fileImport;
  final IdentityCapability? identity;
  final ImageCapability? images;
  final BarcodeCapability? barcode;

  String get name => id.value;
  bool get isConfigured => !descriptor.requiresUserKey;
  String get statusMessage =>
      descriptor.requiresUserKey ? 'Requires API Key' : 'Ready';

  bool get supportsMetadata => metadata != null;
  bool get supportsPersonalRead => personalRead != null;
  bool get supportsPersonalWrite => personalWrite != null;
  bool get supportsFileImport => fileImport != null;
  bool get supportsIdentity => identity != null;
  bool get supportsImages => images != null;
  bool get supportsBarcode => barcode != null;
  bool get supportsBidirectionalSync =>
      personalRead != null && personalWrite != null;

  @override
  Future<List<ProviderSearchResult>> search(
    String query, {
    Object? kind,
    int limit = 25,
  }) {
    final meta = metadata;
    if (meta == null) {
      return Future.value(const []);
    }
    final effectiveKind = kind is CatalogMediaKind ? kind.apiValue : kind;
    return meta.search(query, kind: effectiveKind, limit: limit);
  }

  @override
  Future<NormalizedProviderEnvelopeV1> fetchItem(
    String providerItemId, {
    Object? kind,
  }) {
    final meta = metadata;
    if (meta == null) {
      throw StateError('Provider $id does not support metadata capability');
    }
    final effectiveKind = kind is CatalogMediaKind ? kind.apiValue : kind;
    return meta.fetchItem(providerItemId, kind: effectiveKind);
  }
}
