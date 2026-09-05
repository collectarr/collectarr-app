import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_provider_contract.dart';
import 'package:collectarr_app/features/providers/domain/models/normalized_provider_envelope_v1.dart';

/// Maps normalized provider data directly into the TV-owned domain graph.
final class TvProviderTypedMapper {
  const TvProviderTypedMapper._();

  static TvSeries fromEnvelope(NormalizedProviderEnvelopeV1 envelope) {
    final payload = payloadFromEnvelope(envelope);
    return TvSeries.fromJson(payload);
  }

  static Map<String, dynamic> payloadFromEnvelope(
    NormalizedProviderEnvelopeV1 envelope,
  ) {
    validateLibraryKindProviderEnvelope(
      envelope: envelope,
      expectedKind: CatalogMediaKind.tv,
    );
    final normalized = Map<String, dynamic>.from(envelope.normalized);
    final title = _text(normalized['title']) ?? 'Unknown';
    final coverImageUrl = _text(normalized['cover_image_url']) ??
        (envelope.images.isEmpty ? null : envelope.images.first.url);
    return {
      ...normalized,
      'id': envelope.providerItemId,
      'kind': CatalogMediaKind.tv.apiValue,
      'title': title,
      if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      if (coverImageUrl != null) 'thumbnail_image_url': coverImageUrl,
    };
  }

  static String? _text(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
