import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/providers/domain/models/library_entity_scope.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_identity.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_candidate.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_result.dart';
import 'package:collectarr_app/features/providers/transport/provider_series_hint.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_connector.dart';
import 'package:collectarr_app/features/providers/transport/provider_preview_mapper.dart';

Future<LibraryAddProviderCandidatePreview?> loadMangaProviderCandidatePreview(
  ProviderConnector provider,
  ProviderSearchCandidate candidate,
) async {
  if (candidate is! MangaProviderCandidate) return null;
  final envelope = await provider.fetchItem(
    candidate.providerItemId,
    kind: candidate.kind,
  );
  return LibraryAddProviderCandidatePreview(
    candidate: candidate,
    preview: providerPreviewFromEnvelope(envelope),
  );
}

Future<List<MangaProviderCandidate>> searchMangaProviderCandidates(
  ProviderConnector provider, {
  required String query,
  required CatalogMediaKind kind,
  required int limit,
}) async {
  final results = await provider.search(query, kind: kind, limit: limit);
  return [
    for (final result in results)
      if (result.providerItemId.trim().isNotEmpty && result.kind == kind)
        MangaProviderCandidate.fromSearchResult(
          result,
          provider: provider.name,
        ),
  ];
}

sealed class MangaProviderCandidate extends ProviderSearchCandidateBase {
  const MangaProviderCandidate({
    required super.provider,
    required super.providerItemId,
    required super.title,
    required super.kind,
    super.summary,
    super.imageUrl,
    super.candidateType,
    super.parent,
    super.previewOnly,
    super.entityScope,
    super.identity,
    this.issueNumber,
    this.series,
    this.variantName,
    this.isVariantOverride,
    this.publisher,
    this.issueCount,
  });

  final String? issueNumber;
  final ProviderSeriesHint? series;
  final String? variantName;
  final bool? isVariantOverride;
  final String? publisher;
  final int? issueCount;

  bool get isVariant => isVariantOverride ?? false;

  factory MangaProviderCandidate.fromSearchResult(
    ProviderSearchResult result, {
    String? provider,
  }) {
    final series = ProviderSeriesHint(
      seriesTitle: result.seriesTitle,
      volumeStartYear: result.volumeStartYear,
    );
    return MangaEditionCandidate(
      provider: provider ?? result.provider,
      providerItemId: result.providerItemId,
      title: result.title,
      summary: result.summary,
      imageUrl: result.imageUrl,
      candidateType: result.candidateType,
      issueNumber: result.issueNumber,
      series: series.hasData ? series : null,
      variantName: result.variantName,
      isVariantOverride: result.isVariant,
      publisher: result.publisher,
      issueCount: result.issueCount,
      parent: result.parent,
      identity: ProviderEntityIdentity(
        provider: provider ?? result.provider,
        externalId: result.providerItemId,
        scope: result.entityScope,
      ),
    );
  }
}

final class MangaVolumeCandidate extends MangaProviderCandidate {
  const MangaVolumeCandidate({
    required super.provider,
    required super.providerItemId,
    required super.title,
    super.summary,
    super.imageUrl,
    super.candidateType,
    super.parent,
    super.previewOnly,
    super.identity,
  }) : super(
            kind: CatalogMediaKind.manga, entityScope: LibraryEntityScope.work);
}

final class MangaEditionCandidate extends MangaProviderCandidate {
  const MangaEditionCandidate({
    required super.provider,
    required super.providerItemId,
    required super.title,
    super.summary,
    super.imageUrl,
    super.candidateType,
    super.parent,
    super.previewOnly,
    super.identity,
    super.issueNumber,
    super.series,
    super.variantName,
    super.isVariantOverride,
    super.publisher,
    super.issueCount,
  }) : super(
            kind: CatalogMediaKind.manga,
            entityScope: LibraryEntityScope.release);
}
