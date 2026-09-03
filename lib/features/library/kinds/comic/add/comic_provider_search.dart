import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_connector.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_search_result.dart';

Future<List<ProviderCandidate>> searchComicProvider(
  ProviderConnector provider, {
  required String query,
  required String kind,
  required int limit,
}) async {
  final results = await provider.search(query, kind: kind, limit: limit);
  return [
    for (final result in results)
      if (result.providerItemId.trim().isNotEmpty)
        _comicCandidateFromSearchResult(
          result,
          provider: provider.descriptor.name,
          fallbackKind: kind,
        ),
  ];
}

ProviderCandidate _comicCandidateFromSearchResult(
  ProviderSearchResult result, {
  required String provider,
  required String fallbackKind,
}) {
  final series = CatalogSeriesDetailsDto(
    seriesTitle: result.seriesTitle,
    volumeStartYear: result.volumeStartYear,
  );
  return ProviderCandidate(
    provider: provider,
    providerItemId: result.providerItemId,
    title: result.title,
    kind: result.kind.trim().isEmpty ? fallbackKind : result.kind,
    summary: result.summary,
    imageUrl: result.imageUrl,
    candidateType: result.candidateType,
    issueNumber: result.issueNumber,
    series: series.hasData ? series : null,
    variantName: result.variantName,
    isVariantOverride: result.isVariant,
    publisher: result.publisher,
    issueCount: result.issueCount,
    characterPreview: result.characterPreview,
    storyArcPreview: result.storyArcPreview,
  );
}
