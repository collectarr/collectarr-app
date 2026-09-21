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
    this.publisher,
    this.issueCount,
    this.characterPreview = const <String>[],
    this.storyArcPreview = const <String>[],
  });

  final String? issueNumber;
  final ProviderSeriesHint? series;
  final String? variantName;
  final String? publisher;
  final int? issueCount;
  final List<String> characterPreview;
  final List<String> storyArcPreview;

  factory ComicProviderCandidate.fromSearchResult(
    ProviderSearchResult result, {
    String? provider,
  }) {
    final series = ProviderSeriesHint(
      seriesTitle: result.attributeString('series_title'),
      volumeStartYear: result.attributeInt('volume_start_year'),
    );
    final isVariant = result.searchRole.isReleaseLike;
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
        issueNumber: result.attributeString('issue_number'),
        series: series.hasData ? series : null,
        variantName: result.attributeString('variant_name'),
        publisher: result.attributeString('publisher'),
        issueCount: result.attributeInt('issue_count'),
        characterPreview: result.attributeStrings('character_preview'),
        storyArcPreview: result.attributeStrings('story_arc_preview'),
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
      issueNumber: result.attributeString('issue_number'),
      series: series.hasData ? series : null,
      variantName: result.attributeString('variant_name'),
      publisher: result.attributeString('publisher'),
      issueCount: result.attributeInt('issue_count'),
      characterPreview: result.attributeStrings('character_preview'),
      storyArcPreview: result.attributeStrings('story_arc_preview'),
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
      ProviderSearchRole.issue;
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
