import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/bundles/models/library_bundle_detail.dart';
import 'package:collectarr_app/features/library/bundles/models/library_bundle_summary.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/providers/providers_sdk.dart';

final class LibraryAddHydrationService {
  const LibraryAddHydrationService();

  Future<CatalogSearchCandidate> hydrateCatalogCandidate({
    required ApiClient api,
    required LibraryKindRegistration type,
    required CatalogSearchCandidate fallback,
    required String itemId,
  }) async {
    final dto = await api.getTypedMetadataItem(
      kind: fallback.mediaKind,
      id: itemId,
    );
    final hydrated = CatalogSearchCandidate.fromJson({
      ...dto.raw,
      'id': dto.id,
      'title': dto.title,
      'kind': dto.kind,
    });
    final merged = libraryPresentationForKind(type.kind)
        .builder
        .mergeHydratedAddItem(hydrated: hydrated, fallback: fallback);
    return libraryAddForKind(type.kind).catalogCandidateFromCoreItem(merged);
  }

  Future<List<LibraryBundleSummary>> loadBundleReleases({
    required ApiClient api,
    required String itemId,
  }) async {
    final releases = await api.getItemBundleReleases(itemId);
    return List<LibraryBundleSummary>.unmodifiable(
      releases.map(LibraryBundleSummary.fromTransport),
    );
  }

  Future<LibraryBundleDetail> loadBundleReleaseDetail({
    required ApiClient api,
    required String bundleReleaseId,
  }) async {
    final detail = await api.getBundleRelease(bundleReleaseId);
    return LibraryBundleDetail.fromTransport(detail);
  }

  Future<LibraryAddProviderCandidatePreview> loadProviderPreview({
    required ProviderConnectorRegistry? registry,
    required LibraryAddTypedProviderCandidatePreviewLoader? loader,
    required ProviderSearchCandidate candidate,
  }) async {
    final provider = registry?.get(candidate.provider);
    if (provider != null && loader != null) {
      final loaded = await loader(provider, candidate);
      if (loaded != null) return loaded;
    }
    throw ProviderNotFoundException(
      provider: candidate.provider,
      message:
          'No preview available for ${candidate.provider}:${candidate.providerItemId}',
    );
  }
}
