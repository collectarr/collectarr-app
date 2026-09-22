import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_identity.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_candidate.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_result.dart';
import 'package:collectarr_app/features/providers/transport/provider_series_hint.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_connector.dart';
import 'package:collectarr_app/features/providers/transport/provider_preview_common.dart';
import 'package:collectarr_app/features/providers/transport/provider_raw_envelope.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_role.dart';

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
    preview: providerPreviewFromMangaEnvelope(envelope),
  );
}

final providerPreviewFromMangaEnvelope = (ProviderRawEnvelope envelope) {
  final payload = envelope.payload.toJson();
  return ProviderPreviewCommon.fromEnvelope(envelope).toPreview(
    itemNumber: providerPreviewText(payload['item_number']),
    series: _mangaSeries(payload),
    publishing: _mangaPublishing(payload),
  );
};

CatalogSeriesDetailsDto? _mangaSeries(Map<String, dynamic> payload) {
  if (!payload.containsKey('series_title') &&
      !payload.containsKey('volume_name') &&
      !payload.containsKey('volume_number') &&
      !payload.containsKey('volume_start_year')) {
    return null;
  }
  return CatalogSeriesDetailsDto(
    seriesTitle: providerPreviewText(payload['series_title']),
    volumeName: providerPreviewText(payload['volume_name']),
    volumeNumber: providerPreviewText(payload['volume_number']),
    volumeStartYear: _mangaInt(payload['volume_start_year']),
  );
}

CatalogPublishingDetailsDto? _mangaPublishing(Map<String, dynamic> payload) {
  if (!payload.containsKey('page_count') &&
      !payload.containsKey('imprint') &&
      !payload.containsKey('subtitle') &&
      !payload.containsKey('series_group')) {
    return null;
  }
  return CatalogPublishingDetailsDto(
    pageCount: _mangaInt(payload['page_count']),
    imprint: providerPreviewText(payload['imprint']),
    subtitle: providerPreviewText(payload['subtitle']),
    seriesGroup: providerPreviewText(payload['series_group']),
  );
}

int? _mangaInt(Object? value) =>
    value is num ? value.toInt() : int.tryParse(value?.toString() ?? '');

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

  factory MangaProviderCandidate.fromSearchResult(
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
      return MangaVolumeCandidate(
        provider: provider ?? result.provider,
        providerItemId: result.providerItemId,
        title: result.title,
        summary: result.summary,
        imageUrl: result.imageUrl,
        parent: result.parent,
        identity: common,
      );
    }
    return MangaEditionCandidate(
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

final class MangaVolumeCandidate extends MangaProviderCandidate {
  const MangaVolumeCandidate({
    required super.provider,
    required super.providerItemId,
    required super.title,
    super.summary,
    super.imageUrl,
    super.parent,
    super.previewOnly,
    super.identity,
  }) : super(
            kind: CatalogMediaKind.manga, entityScope: LibraryEntityScope.work);

  @override
  ProviderSearchRole get searchRole => ProviderSearchRole.volume;
}

final class MangaEditionCandidate extends MangaProviderCandidate {
  const MangaEditionCandidate({
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
            kind: CatalogMediaKind.manga,
            entityScope: LibraryEntityScope.release);

  @override
  ProviderSearchRole get searchRole => ProviderSearchRole.edition;
}
