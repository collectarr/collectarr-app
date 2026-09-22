import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_identity.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_candidate.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_result.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_role.dart';
import 'package:collectarr_app/features/providers/transport/provider_series_hint.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_connector.dart';
import 'package:collectarr_app/features/providers/transport/provider_preview_common.dart';
import 'package:collectarr_app/features/providers/transport/provider_raw_envelope.dart';

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
    preview: providerPreviewFromComicEnvelope(envelope),
  );
}

AdminProviderPreview providerPreviewFromComicEnvelope(
    ProviderRawEnvelope envelope) {
  final payload = envelope.payload.toJson();
  return ProviderPreviewCommon.fromEnvelope(envelope).toPreview(
    itemNumber: providerPreviewText(
      payload['issue_number'] ?? payload['item_number'],
    ),
    series: _comicSeries(payload),
    publishing: _comicPublishing(payload),
  );
}

CatalogSeriesDetailsDto? _comicSeries(Map<String, dynamic> payload) {
  if (!payload.containsKey('series_title') &&
      !payload.containsKey('volume_start_year')) {
    return null;
  }
  return CatalogSeriesDetailsDto(
    seriesTitle: providerPreviewText(payload['series_title']),
    volumeStartYear: _comicInt(payload['volume_start_year']),
  );
}

CatalogPublishingDetailsDto? _comicPublishing(Map<String, dynamic> payload) {
  if (!payload.containsKey('page_count') &&
      !payload.containsKey('imprint') &&
      !payload.containsKey('subtitle') &&
      !payload.containsKey('series_group')) {
    return null;
  }
  return CatalogPublishingDetailsDto(
    pageCount: _comicInt(payload['page_count']),
    imprint: providerPreviewText(payload['imprint']),
    subtitle: providerPreviewText(payload['subtitle']),
    seriesGroup: providerPreviewText(payload['series_group']),
  );
}

int? _comicInt(Object? value) =>
    value is num ? value.toInt() : int.tryParse(value?.toString() ?? '');

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
    final payload = result.payload;
    final series = ProviderSeriesHint(
      seriesTitle: _payloadString(payload['series_title']),
      volumeStartYear: _payloadInt(payload['volume_start_year']),
    );
    final isVariant = result.searchRole == ProviderSearchRole.variant;
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
        issueNumber: _payloadString(payload['issue_number']),
        series: series.hasData ? series : null,
        variantName: _payloadString(payload['variant_name']),
        publisher: _payloadString(payload['publisher']),
        issueCount: _payloadInt(payload['issue_count']),
        characterPreview: _payloadStrings(payload['character_preview']),
        storyArcPreview: _payloadStrings(payload['story_arc_preview']),
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
      issueNumber: _payloadString(payload['issue_number']),
      series: series.hasData ? series : null,
      variantName: _payloadString(payload['variant_name']),
      publisher: _payloadString(payload['publisher']),
      issueCount: _payloadInt(payload['issue_count']),
      characterPreview: _payloadStrings(payload['character_preview']),
      storyArcPreview: _payloadStrings(payload['story_arc_preview']),
      parent: result.parent,
      identity: common,
      searchRoleOverride: result.searchRole,
    );
  }
}

String? _payloadString(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

int? _payloadInt(Object? value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

List<String> _payloadStrings(Object? value) {
  if (value is! Iterable) return const [];
  return [
    for (final entry in value)
      if (entry != null && entry.toString().trim().isNotEmpty)
        entry.toString().trim(),
  ];
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
      searchRoleOverride ?? ProviderSearchRole.issue;
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
