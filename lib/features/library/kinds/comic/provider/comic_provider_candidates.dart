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
    if (searchRole == ProviderSearchRole.variant) {
      return true;
    }
    if (searchRole == ProviderSearchRole.issue ||
        searchRole == ProviderSearchRole.series) {
      return false;
    }
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
    final isVariant = result.searchRole == ProviderSearchRole.variant ||
        result.isVariant == true;
    final common = ProviderEntityIdentity(
      provider: provider ?? result.provider,
      externalId: result.providerItemId,
      scope: isVariant ? LibraryEntityScope.release : LibraryEntityScope.work,
    );
    if (isVariant) {
      return ComicVariantCandidate(
        provider: provider ?? result.provider,
        providerItemId: result.providerItemId,
        title: result.title,
        summary: result.summary,
        imageUrl: result.imageUrl,
        issueNumber: result.issueNumber,
        series: series.hasData ? series : null,
        variantName: result.variantName,
        isVariantOverride: true,
        publisher: result.publisher,
        issueCount: result.issueCount,
        characterPreview: result.characterPreview,
        storyArcPreview: result.storyArcPreview,
        parent: result.parent,
        identity: common,
      );
    }
    return ComicIssueCandidate(
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
      characterPreview: result.characterPreview,
      storyArcPreview: result.storyArcPreview,
      parent: result.parent,
      identity: common,
      searchRoleOverride: result.searchRole,
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
    this.searchRoleOverride,
  }) : super(
            kind: CatalogMediaKind.comic, entityScope: LibraryEntityScope.work);

  final ProviderSearchRole? searchRoleOverride;

  @override
  ProviderSearchRole get searchRole =>
      searchRoleOverride ??
      (isVariantOverride == true
          ? ProviderSearchRole.variant
          : ProviderSearchRole.issue);
}

final class ComicVariantCandidate extends ComicProviderCandidate {
  const ComicVariantCandidate({
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
    super.characterPreview,
    super.storyArcPreview,
  }) : super(
            kind: CatalogMediaKind.comic,
            entityScope: LibraryEntityScope.release);

  @override
  ProviderSearchRole get searchRole => ProviderSearchRole.variant;
}
