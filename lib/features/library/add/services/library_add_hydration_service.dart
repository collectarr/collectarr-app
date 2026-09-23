import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_result_policy.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/bundles/models/library_bundle_detail.dart';
import 'package:collectarr_app/features/library/bundles/models/library_bundle_summary.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/providers/providers_sdk.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_candidate.dart';

typedef LibraryAddProviderGroupChildrenBuilder = List<ProviderSearchCandidate>
    Function({
  required ProviderSearchCandidate groupCandidate,
  required AdminProviderPreview preview,
});

final class LibraryAddProviderGroupPreviewResult {
  const LibraryAddProviderGroupPreviewResult({
    required this.candidate,
    required this.preview,
    required this.searchResults,
  });

  final ProviderSearchCandidate candidate;
  final AdminProviderPreview preview;
  final List<ProviderSearchCandidate> searchResults;
}

final class LibraryAddProviderSubmissionHydrationResult {
  const LibraryAddProviderSubmissionHydrationResult({
    required this.candidates,
    required this.hydratedCandidates,
    required this.hydratedPreviews,
  });

  final List<ProviderSearchCandidate> candidates;
  final Map<String, ProviderSearchCandidate> hydratedCandidates;
  final Map<String, AdminProviderPreview> hydratedPreviews;
}

final class LibraryAddHydrationService {
  const LibraryAddHydrationService();

  Future<CatalogSearchCandidate> hydrateCatalogCandidate({
    required ApiClient api,
    required LibraryKindRegistration type,
    required CatalogSearchCandidate fallback,
    required String itemId,
  }) async {
    final dto = await api.getTypedMetadataItem(
      kind: fallback.summary.kind,
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

  Future<LibraryAddProviderGroupPreviewResult> loadProviderGroupPreview({
    required ProviderConnectorRegistry? registry,
    required LibraryAddSearchCapability capability,
    required LibraryAddResultPolicy resultPolicy,
    required ProviderSearchCandidate candidate,
    required LibraryAddSearchContext searchContext,
    required List<ProviderSearchCandidate> currentResults,
    required LibraryAddProviderGroupChildrenBuilder buildGroupChildren,
  }) async {
    final loaded = await loadProviderPreview(
      registry: registry,
      loader: capability.provider.candidatePreviewLoader,
      candidate: candidate,
    );
    final groupCandidate = loaded.candidate;
    final previewChildren = capability.provider.resultPolicy.filterResults(
      buildGroupChildren(
        groupCandidate: groupCandidate,
        preview: loaded.preview,
      ),
      searchContext,
    );
    final results = List<ProviderSearchCandidate>.from(currentResults);
    final groupIndex = results.indexWhere(
      (value) => value.localCatalogId == candidate.localCatalogId,
    );
    if (groupIndex >= 0) {
      results[groupIndex] = groupCandidate;
    }
    if (capability.provider.resultPolicy.removeGroupsWithoutVisibleChildren &&
        resultPolicy.isProviderGroupCandidate(candidate) &&
        previewChildren.isEmpty) {
      results.removeWhere(
        (value) => value.localCatalogId == candidate.localCatalogId,
      );
    }
    final resultIds = results.map((value) => value.localCatalogId).toSet();
    for (final child in previewChildren) {
      if (resultIds.add(child.localCatalogId)) {
        results.add(child);
      }
    }
    return LibraryAddProviderGroupPreviewResult(
      candidate: groupCandidate,
      preview: loaded.preview,
      searchResults: List<ProviderSearchCandidate>.unmodifiable(results),
    );
  }

  Future<LibraryAddProviderSubmissionHydrationResult>
      hydrateProviderCandidatesForSubmission({
    required ProviderConnectorRegistry? registry,
    required LibraryAddSearchCapability capability,
    required List<ProviderSearchCandidate> candidates,
    required Map<String, ProviderSearchCandidate> existingCandidatesById,
  }) async {
    final prepared = <ProviderSearchCandidate>[];
    final hydratedCandidates = <String, ProviderSearchCandidate>{};
    final hydratedPreviews = <String, AdminProviderPreview>{};
    if (registry == null) {
      return LibraryAddProviderSubmissionHydrationResult(
        candidates: candidates,
        hydratedCandidates: hydratedCandidates,
        hydratedPreviews: hydratedPreviews,
      );
    }

    for (final candidate in candidates) {
      final candidateId = candidate.localCatalogId;
      final effective = existingCandidatesById[candidateId] ?? candidate;
      if (registry.get(effective.provider) == null) {
        prepared.add(effective);
        continue;
      }
      final loaded = await loadProviderPreview(
        registry: registry,
        loader: capability.provider.candidatePreviewLoader,
        candidate: effective,
      );
      prepared.add(loaded.candidate);
      hydratedCandidates[candidateId] = loaded.candidate;
      hydratedPreviews[candidateId] = loaded.preview;
    }
    return LibraryAddProviderSubmissionHydrationResult(
      candidates: List<ProviderSearchCandidate>.unmodifiable(prepared),
      hydratedCandidates: hydratedCandidates,
      hydratedPreviews: hydratedPreviews,
    );
  }
}
