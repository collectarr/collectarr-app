import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/providers/domain/models/library_entity_scope.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_identity.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_candidate.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_result.dart';
import 'package:collectarr_app/features/providers/transport/provider_series_hint.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_connector.dart';
import 'package:collectarr_app/features/providers/transport/provider_preview_mapper.dart';

Future<LibraryAddProviderCandidatePreview?> loadComicProviderCandidatePreview(
  ProviderConnector provider,
  ProviderSearchCandidate candidate,
) async {
  if (candidate is! ComicProviderCandidate) return null;
  final envelope = await provider.fetchItem(
    candidate.providerItemId,
    kind: candidate.kind,
  );
  return LibraryAddProviderCandidatePreview(
    candidate: candidate,
    preview: providerPreviewFromEnvelope(envelope),
  );
}

sealed class ComicProviderCandidate extends ProviderSearchCandidateBase {
  const ComicProviderCandidate({
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
    this.characterPreview = const <String>[],
    this.storyArcPreview = const <String>[],
  });

  final String? issueNumber;
  final ProviderSeriesHint? series;
  final String? variantName;
  final bool? isVariantOverride;
  final String? publisher;
  final int? issueCount;
  final List<String> characterPreview;
  final List<String> storyArcPreview;

  bool get isVariant {
    final type = candidateType?.trim().toLowerCase();
    if (type == 'variant') return true;
    if (type == 'issue' || type == 'series') return false;
    return isVariantOverride ?? false;
  }

  factory ComicProviderCandidate.fromSearchResult(
    ProviderSearchResult result, {
    String? provider,
  }) {
    final series = ProviderSeriesHint(
      seriesTitle: result.seriesTitle,
      volumeStartYear: result.volumeStartYear,
    );
    return ComicIssueCandidate(
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
      characterPreview: result.characterPreview,
      storyArcPreview: result.storyArcPreview,
      parent: result.parent,
      identity: ProviderEntityIdentity(
        provider: provider ?? result.provider,
        externalId: result.providerItemId,
        scope: result.entityScope,
      ),
    );
  }
}

final class ComicIssueCandidate extends ComicProviderCandidate {
  const ComicIssueCandidate({
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
    super.characterPreview,
    super.storyArcPreview,
  }) : super(
            kind: CatalogMediaKind.comic, entityScope: LibraryEntityScope.work);
}

final class ComicVariantCandidate extends ComicProviderCandidate {
  const ComicVariantCandidate({
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
    super.characterPreview,
    super.storyArcPreview,
  }) : super(
            kind: CatalogMediaKind.comic,
            entityScope: LibraryEntityScope.release);
}
