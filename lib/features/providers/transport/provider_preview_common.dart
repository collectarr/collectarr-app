import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_publishing_details_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_series_details_dto.dart';
import 'package:collectarr_app/features/providers/transport/provider_raw_envelope.dart';

/// Structural identity and presentation fields shared by provider previews.
///
/// Kind mappers read semantic values from [ProviderRawEnvelope.payload] and
/// pass their projections to [toPreview]. This type deliberately does not
/// interpret release, publishing, credit, genre, or rating fields.
final class ProviderPreviewCommon {
  const ProviderPreviewCommon({
    required this.provider,
    required this.providerItemId,
    required this.kind,
    required this.title,
    this.coverImageUrl,
  });

  factory ProviderPreviewCommon.fromEnvelope(ProviderRawEnvelope envelope) {
    final payload = envelope.payload;
    return ProviderPreviewCommon(
      provider: envelope.provider,
      providerItemId: envelope.providerItemId,
      kind: envelope.kind.apiValue,
      title: payload['title']?.toString() ?? 'Unknown',
      coverImageUrl: providerPreviewText(payload['cover_image_url']) ??
          (envelope.images.isNotEmpty ? envelope.images.first.url : null),
    );
  }

  final String provider;
  final String providerItemId;
  final String kind;
  final String title;
  final String? coverImageUrl;

  AdminProviderPreview toPreview({
    String? itemNumber,
    String? synopsis,
    String? publisher,
    String? editionTitle,
    String? editionFormat,
    String? physicalFormat,
    String? physicalFormatLabel,
    DateTime? releaseDate,
    String? barcode,
    String? isbn,
    String? variantName,
    CatalogSeriesDetailsDto? series,
    CatalogPublishingDetailsDto? publishing,
    Map<String, dynamic>? video,
    Map<String, dynamic>? music,
    Map<String, dynamic>? game,
    String? country,
    String? language,
    String? ageRating,
    String? audienceRating,
    List<ProviderPreviewCredit> creators = const [],
    List<String> characters = const [],
    List<String> storyArcs = const [],
    List<String> genres = const [],
  }) {
    return AdminProviderPreview(
      provider: provider,
      providerItemId: providerItemId,
      kind: kind,
      title: title,
      itemNumber: itemNumber,
      synopsis: synopsis,
      publisher: publisher,
      editionTitle: editionTitle,
      editionFormat: editionFormat,
      physicalFormat: physicalFormat,
      physicalFormatLabel: physicalFormatLabel,
      releaseDate: releaseDate,
      barcode: barcode,
      isbn: isbn,
      variantName: variantName,
      coverImageUrl: coverImageUrl,
      series: series,
      publishing: publishing,
      video: video,
      music: music,
      game: game,
      country: country,
      language: language,
      ageRating: ageRating,
      audienceRating: audienceRating,
      creators: creators,
      characters: characters,
      storyArcs: storyArcs,
      genres: genres,
    );
  }
}

String? providerPreviewText(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

DateTime? providerPreviewDate(Object? value) =>
    DateTime.tryParse(value?.toString().trim() ?? '');

List<String> providerPreviewStrings(Object? value) {
  if (value is! Iterable) return const [];
  return [
    for (final entry in value)
      if (providerPreviewText(entry) case final text?) text,
  ];
}

List<ProviderPreviewCredit> providerPreviewCredits(Object? value) {
  if (value is! Iterable) return const [];
  return [
    for (final entry in value)
      if (entry is Map)
        ProviderPreviewCredit(
          name: entry['name']?.toString() ?? '',
          role: providerPreviewText(entry['role']),
          imageUrl: providerPreviewText(entry['image_url']),
        )
      else if (providerPreviewText(entry) case final text?)
        ProviderPreviewCredit(name: text),
  ];
}
