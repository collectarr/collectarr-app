import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_identity.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_candidate.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_result.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_role.dart';
import 'package:collectarr_app/features/providers/transport/provider_series_hint.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_connector.dart';
import 'package:collectarr_app/features/providers/transport/provider_preview_mapper.dart';

Future<LibraryAddProviderCandidatePreview?> loadAnimeProviderCandidatePreview(
  ProviderConnector provider,
  ProviderSearchCandidate candidate,
) async {
  if (candidate is! AnimeProviderCandidate) return null;
  final envelope = await provider.fetchItem(
    candidate.providerItemId,
    kind: candidate.kind,
  );
  return LibraryAddProviderCandidatePreview(
    candidate: candidate,
    preview: providerPreviewFromEnvelope(envelope),
  );
}

Future<List<AnimeProviderCandidate>> searchAnimeProviderCandidates(
  ProviderConnector provider, {
  required String query,
  required CatalogMediaKind kind,
  required int limit,
}) async {
  final results = await provider.search(query, kind: kind, limit: limit);
  return [
    for (final result in results)
      if (result.providerItemId.trim().isNotEmpty && result.kind == kind)
        AnimeProviderCandidate.fromSearchResult(
          result,
          provider: provider.name,
        ),
  ];
}

sealed class AnimeProviderCandidate extends ProviderSearchCandidateBase {
  const AnimeProviderCandidate({
    required super.provider,
    required super.providerItemId,
    required super.title,
    required super.kind,
    super.summary,
    super.imageUrl,
    super.parent,
    super.previewOnly,
    required super.entityScope,
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

  bool get isVariant {
    if (searchRole == ProviderSearchRole.variant) {
      return true;
    }
    if (searchRole == ProviderSearchRole.series ||
        searchRole == ProviderSearchRole.issue) {
      return false;
    }
    return isVariantOverride ?? false;
  }

  factory AnimeProviderCandidate.fromSearchResult(
    ProviderSearchResult result, {
    String? provider,
  }) {
    final series = ProviderSeriesHint(
      seriesTitle: result.seriesTitle,
      volumeStartYear: result.volumeStartYear,
    );
    final common = ProviderEntityIdentity(
      provider: provider ?? result.provider,
      externalId: result.providerItemId,
      scope: result.entityScope,
    );
    if (result.entityScope == LibraryEntityScope.work) {
      return AnimeWorkCandidate(
        provider: provider ?? result.provider,
        providerItemId: result.providerItemId,
        title: result.title,
        summary: result.summary,
        imageUrl: result.imageUrl,
        parent: result.parent,
        identity: common,
      );
    }
    return AnimeReleaseCandidate(
      provider: provider ?? result.provider,
      providerItemId: result.providerItemId,
      title: result.title,
      summary: result.summary,
      imageUrl: result.imageUrl,
      issueNumber: result.issueNumber,
      series: series.hasData ? series : null,
      variantName: result.variantName,
      isVariantOverride: result.isVariant,
      publisher: result.publisher,
      issueCount: result.issueCount,
      parent: result.parent,
      identity: common,
    );
  }
}

final class AnimeWorkCandidate extends AnimeProviderCandidate {
  const AnimeWorkCandidate({
    required super.provider,
    required super.providerItemId,
    required super.title,
    super.summary,
    super.imageUrl,
    super.parent,
    super.previewOnly,
    super.identity,
  }) : super(
          kind: CatalogMediaKind.anime,
          entityScope: LibraryEntityScope.work,
        );

  @override
  ProviderSearchRole get searchRole => ProviderSearchRole.work;
}

final class AnimeReleaseCandidate extends AnimeProviderCandidate {
  const AnimeReleaseCandidate({
    required super.provider,
    required super.providerItemId,
    required super.title,
    super.summary,
    super.imageUrl,
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
          kind: CatalogMediaKind.anime,
          entityScope: LibraryEntityScope.release,
        );

  @override
  ProviderSearchRole get searchRole => ProviderSearchRole.release;
}
