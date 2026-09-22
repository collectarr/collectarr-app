import 'package:collectarr_app/core/api/dto/admin_metadata.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_publishing_details_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_series_details_dto.dart';
import 'package:collectarr_app/features/providers/transport/provider_raw_envelope.dart';

/// Presentation-neutral values shared by provider preview projections.
///
/// This decoder intentionally stops at fields that are common to the preview
/// chrome. Release, issue, season, platform, music and other details are
/// supplied by the selected kind mapper through [toPreview].
final class ProviderPreviewCommon {
  const ProviderPreviewCommon({
    required this.provider,
    required this.providerItemId,
    required this.kind,
    required this.title,
    this.synopsis,
    this.publisher,
    this.editionTitle,
    this.editionFormat,
    this.physicalFormat,
    this.physicalFormatLabel,
    this.releaseDate,
    this.barcode,
    this.isbn,
    this.variantName,
    this.coverImageUrl,
    this.country,
    this.language,
    this.ageRating,
    this.audienceRating,
    this.creators = const [],
    this.characters = const [],
    this.storyArcs = const [],
    this.genres = const [],
  });

  factory ProviderPreviewCommon.fromEnvelope(ProviderRawEnvelope envelope) {
    final payload = envelope.payload;
    return ProviderPreviewCommon(
      provider: envelope.provider,
      providerItemId: envelope.providerItemId,
      kind: envelope.kind.apiValue,
      title: payload['title']?.toString() ?? 'Unknown',
      synopsis: _text(payload['synopsis']),
      publisher: _text(payload['publisher']),
      editionTitle: _text(payload['edition_title']),
      editionFormat: _text(payload['edition_format']),
      physicalFormat: _text(payload['physical_format']),
      physicalFormatLabel: _text(payload['physical_format_label']),
      releaseDate:
          _date(payload['release_date'] ?? payload['original_release_date']),
      barcode: _text(payload['barcode']),
      isbn: _text(payload['isbn']),
      variantName: _text(payload['variant_name'] ?? payload['variant']),
      coverImageUrl: _text(payload['cover_image_url']) ??
          (envelope.images.isNotEmpty ? envelope.images.first.url : null),
      country: _text(payload['country']),
      language: _text(payload['language']),
      ageRating: _text(payload['age_rating']),
      audienceRating: _text(payload['audience_rating']),
      creators: _credits(payload['creators']),
      characters: _strings(payload['characters']),
      storyArcs: _strings(payload['story_arcs']),
      genres: _strings(payload['genres']),
    );
  }

  final String provider;
  final String providerItemId;
  final String kind;
  final String title;
  final String? synopsis;
  final String? publisher;
  final String? editionTitle;
  final String? editionFormat;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final DateTime? releaseDate;
  final String? barcode;
  final String? isbn;
  final String? variantName;
  final String? coverImageUrl;
  final String? country;
  final String? language;
  final String? ageRating;
  final String? audienceRating;
  final List<ProviderPreviewCredit> creators;
  final List<String> characters;
  final List<String> storyArcs;
  final List<String> genres;

  AdminProviderPreview toPreview({
    String? itemNumber,
    CatalogSeriesDetailsDto? series,
    CatalogPublishingDetailsDto? publishing,
    Map<String, dynamic>? video,
    Map<String, dynamic>? music,
    Map<String, dynamic>? game,
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

String? _text(Object? value) => providerPreviewText(value);

DateTime? _date(Object? value) => providerPreviewDate(value);

List<String> _strings(Object? value) => providerPreviewStrings(value);

List<ProviderPreviewCredit> _credits(Object? value) =>
    providerPreviewCredits(value);
