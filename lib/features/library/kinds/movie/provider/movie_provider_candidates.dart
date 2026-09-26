import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_identity.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_candidate.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_result.dart';
import 'package:collectarr_app/features/providers/transport/provider_series_hint.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_connector.dart';
import 'package:collectarr_app/features/providers/transport/provider_preview_common.dart';
import 'package:collectarr_app/features/providers/transport/provider_raw_envelope.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_role.dart';
import 'package:collectarr_app/features/providers/runtime/provider_runtime.dart';

Future<LibraryAddProviderCandidatePreview?> loadMovieProviderCandidatePreview(
  ProviderConnector provider,
  ProviderSearchCandidate candidate,
) async {
  if (candidate is! MovieProviderCandidate) return null;
  final envelope = await provider.fetchItem(
    candidate.providerItemId,
    kind: candidate.kind,
  );
  return LibraryAddProviderCandidatePreview(
    candidate: candidate,
    preview: providerPreviewFromMovieEnvelope(envelope),
  );
}

AdminProviderPreview providerPreviewFromMovieEnvelope(
    ProviderRawEnvelope envelope) {
  final runtime = _movieInt(envelope.payload['runtime_minutes']);
  return ProviderPreviewCommon.fromEnvelope(envelope).toPreview(
    itemNumber: providerPreviewText(envelope.payload['item_number']),
    synopsis: providerPreviewText(envelope.payload['synopsis']),
    publisher: providerPreviewText(envelope.payload['publisher']),
    editionTitle: providerPreviewText(envelope.payload['edition_title']),
    editionFormat: providerPreviewText(envelope.payload['edition_format']),
    physicalFormat: providerPreviewText(envelope.payload['physical_format']),
    physicalFormatLabel:
        providerPreviewText(envelope.payload['physical_format_label']),
    releaseDate: providerPreviewDate(
      envelope.payload['release_date'] ??
          envelope.payload['original_release_date'],
    ),
    barcode: providerPreviewText(envelope.payload['barcode']),
    isbn: providerPreviewText(envelope.payload['isbn']),
    variantName: providerPreviewText(
      envelope.payload['variant_name'] ?? envelope.payload['variant'],
    ),
    video: runtime == null ? null : {'runtime_minutes': runtime},
    country: providerPreviewText(envelope.payload['country']),
    language: providerPreviewText(envelope.payload['language']),
    ageRating: providerPreviewText(envelope.payload['age_rating']),
    audienceRating: providerPreviewText(envelope.payload['audience_rating']),
    creators: providerPreviewCredits(envelope.payload['creators']),
    characters: providerPreviewStrings(envelope.payload['characters']),
    storyArcs: providerPreviewStrings(envelope.payload['story_arcs']),
    genres: providerPreviewStrings(envelope.payload['genres']),
  );
}

int? _movieInt(Object? value) =>
    value is num ? value.toInt() : int.tryParse(value?.toString() ?? '');

Future<List<MovieProviderCandidate>> searchMovieProviderCandidates(
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
        MovieProviderCandidate.fromSearchResult(
          result,
          provider: provider.name,
        ),
  ];
}

sealed class MovieProviderCandidate extends ProviderSearchCandidateBase {
  const MovieProviderCandidate({
    required super.provider,
    required super.providerItemId,
    required super.title,
    required super.kind,
    super.summary,
    super.imageUrl,
    super.parent,
    super.previewOnly,
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

  factory MovieProviderCandidate.fromSearchResult(
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
    );
    if (result.searchRole == ProviderSearchRole.catalogItem) {
      return MovieCatalogItemCandidate(
        provider: provider ?? result.provider,
        providerItemId: result.providerItemId,
        title: result.title,
        summary: result.summary,
        imageUrl: result.imageUrl,
        parent: result.parent,
        identity: common,
      );
    }
    return MovieEditionCandidate(
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

final class MovieCatalogItemCandidate extends MovieProviderCandidate {
  const MovieCatalogItemCandidate({
    required super.provider,
    required super.providerItemId,
    required super.title,
    super.summary,
    super.imageUrl,
    super.parent,
    super.previewOnly,
    super.identity,
  }) : super(
          kind: CatalogMediaKind.movie,
        );

  @override
  ProviderSearchRole get searchRole => ProviderSearchRole.catalogItem;
}

final class MovieEditionCandidate extends MovieProviderCandidate {
  const MovieEditionCandidate({
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
          kind: CatalogMediaKind.movie,
        );

  @override
  ProviderSearchRole get searchRole => ProviderSearchRole.edition;
}
