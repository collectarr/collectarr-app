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
import 'package:collectarr_app/features/providers/runtime/provider_runtime.dart';

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
    preview: providerPreviewFromAnimeEnvelope(envelope),
  );
}

AdminProviderPreview providerPreviewFromAnimeEnvelope(
    ProviderRawEnvelope envelope) {
  final payload = envelope.payload.toJson();
  final series = _animeSeries(payload);
  final runtime = _animeInt(payload['runtime_minutes']);
  return ProviderPreviewCommon.fromEnvelope(envelope).toPreview(
    itemNumber: providerPreviewText(payload['item_number']),
    synopsis: providerPreviewText(payload['synopsis']),
    publisher: providerPreviewText(payload['publisher']),
    editionTitle: providerPreviewText(payload['edition_title']),
    editionFormat: providerPreviewText(payload['edition_format']),
    physicalFormat: providerPreviewText(payload['physical_format']),
    physicalFormatLabel: providerPreviewText(payload['physical_format_label']),
    releaseDate: providerPreviewDate(
      payload['release_date'] ?? payload['original_release_date'],
    ),
    barcode: providerPreviewText(payload['barcode']),
    isbn: providerPreviewText(payload['isbn']),
    variantName: providerPreviewText(
      payload['variant_name'] ?? payload['variant'],
    ),
    series: series,
    video: runtime == null ? null : {'runtime_minutes': runtime},
    country: providerPreviewText(payload['country']),
    language: providerPreviewText(payload['language']),
    ageRating: providerPreviewText(payload['age_rating']),
    audienceRating: providerPreviewText(payload['audience_rating']),
    creators: providerPreviewCredits(payload['creators']),
    characters: providerPreviewStrings(payload['characters']),
    storyArcs: providerPreviewStrings(payload['story_arcs']),
    genres: providerPreviewStrings(payload['genres']),
  );
}

CatalogSeriesDetailsDto? _animeSeries(Map<String, dynamic> payload) {
  if (!payload.containsKey('series_title') &&
      !payload.containsKey('volume_name') &&
      !payload.containsKey('season_number') &&
      !payload.containsKey('episode_number')) {
    return null;
  }
  return CatalogSeriesDetailsDto(
    seriesTitle: providerPreviewText(payload['series_title']),
    volumeName: providerPreviewText(payload['volume_name']),
    volumeStartYear: _animeInt(payload['volume_start_year']),
    seasonNumber: _animeInt(payload['season_number']),
    episodeNumber: _animeInt(payload['episode_number']),
  );
}

int? _animeInt(Object? value) =>
    value is num ? value.toInt() : int.tryParse(value?.toString() ?? '');

Future<List<AnimeProviderCandidate>> searchAnimeProviderCandidates(
  ProviderConnector provider, {
  required String query,
  required CatalogMediaKind kind,
  required int limit,
  ProviderCancellationToken? cancellationToken,
}) async {
  final results = await provider.search(
    query,
    kind: kind,
    limit: limit,
    cancellationToken: cancellationToken,
  );
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
    this.publisher,
    this.issueCount,
  });

  final String? issueNumber;
  final ProviderSeriesHint? series;
  final String? variantName;
  final String? publisher;
  final int? issueCount;

  factory AnimeProviderCandidate.fromSearchResult(
    ProviderSearchResult result, {
    String? provider,
  }) {
    final payload = result.payload;
    final series = ProviderSeriesHint(
      seriesTitle: _payloadString(payload['series_title']),
      volumeStartYear: _payloadInt(payload['volume_start_year']),
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
      issueNumber: _payloadString(payload['issue_number']),
      series: series.hasData ? series : null,
      variantName: _payloadString(payload['variant_name']),
      publisher: _payloadString(payload['publisher']),
      issueCount: _payloadInt(payload['issue_count']),
      parent: result.parent,
      identity: common,
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
    super.publisher,
    super.issueCount,
  }) : super(
          kind: CatalogMediaKind.anime,
          entityScope: LibraryEntityScope.release,
        );

  @override
  ProviderSearchRole get searchRole => ProviderSearchRole.release;
}
