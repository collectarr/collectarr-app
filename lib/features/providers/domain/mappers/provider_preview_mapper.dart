import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/features/providers/domain/models/normalized_provider_envelope_v1.dart';

/// Converts a [NormalizedProviderEnvelopeV1] into an [AdminProviderPreview]
/// for UI presentation and draft ingestion without calling Core preview endpoints.
AdminProviderPreview providerPreviewFromEnvelope(
  NormalizedProviderEnvelopeV1 envelope,
) {
  final norm = envelope.normalized;
  final title = norm['title']?.toString() ?? 'Unknown';
  final synopsis = norm['synopsis']?.toString();
  final publisher = norm['publisher']?.toString();
  final editionTitle = norm['edition_title']?.toString();
  final editionFormat = norm['edition_format']?.toString();
  final coverImageUrl = norm['cover_image_url']?.toString() ??
      (envelope.images.isNotEmpty ? envelope.images.first.url : null);
  final audienceRating = norm['audience_rating']?.toString();
  final ageRating = norm['age_rating']?.toString();

  DateTime? releaseDate;
  final rawDate = norm['release_date'];
  if (rawDate != null) {
    releaseDate = DateTime.tryParse(rawDate.toString());
  }

  final genres = <String>[];
  if (norm['genres'] is List) {
    for (final g in norm['genres'] as List) {
      if (g != null) genres.add(g.toString());
    }
  }

  final creators = <ProviderPreviewCredit>[];
  if (norm['creators'] is List) {
    for (final c in norm['creators'] as List) {
      if (c is Map) {
        creators.add(
          ProviderPreviewCredit(
            name: c['name']?.toString() ?? '',
            role: c['role']?.toString(),
            imageUrl: c['image_url']?.toString(),
          ),
        );
      } else if (c != null) {
        creators.add(ProviderPreviewCredit(name: c.toString()));
      }
    }
  }

  final characters = <String>[];
  if (norm['characters'] is List) {
    for (final ch in norm['characters'] as List) {
      if (ch != null) characters.add(ch.toString());
    }
  }

  final storyArcs = <String>[];
  if (norm['story_arcs'] is List) {
    for (final sa in norm['story_arcs'] as List) {
      if (sa != null) storyArcs.add(sa.toString());
    }
  }

  // Handle kind-specific details
  CatalogSeriesDetailsDto? series;
  if (norm.containsKey('series_title') || norm.containsKey('volume_name')) {
    series = CatalogSeriesDetailsDto(
      seriesTitle: norm['series_title']?.toString(),
      volumeName: norm['volume_name']?.toString(),
      volumeStartYear: norm['volume_start_year'] is num
          ? (norm['volume_start_year'] as num).toInt()
          : null,
      seasonNumber: norm['season_number'] is num
          ? (norm['season_number'] as num).toInt()
          : null,
      episodeNumber: norm['episode_number'] is num
          ? (norm['episode_number'] as num).toInt()
          : null,
    );
  }

  CatalogPublishingDetailsDto? publishing;
  if (norm.containsKey('page_count') || norm.containsKey('isbn')) {
    publishing = CatalogPublishingDetailsDto(
      pageCount: norm['page_count'] is num
          ? (norm['page_count'] as num).toInt()
          : null,
    );
  }

  Map<String, dynamic>? game;
  if (norm.containsKey('platforms') && norm['platforms'] is List) {
    final platforms = (norm['platforms'] as List)
        .map((p) => p?.toString() ?? '')
        .where((p) => p.isNotEmpty)
        .toList();
    game = {
      'platforms': platforms,
    };
  }

  Map<String, dynamic>? music;
  if (norm.containsKey('tracks') && norm['tracks'] is List) {
    final tracks = <CatalogTrackDto>[];
    for (final t in norm['tracks'] as List) {
      if (t is Map) {
        tracks.add(
          CatalogTrackDto(
            title: t['title']?.toString() ?? '',
            position: t['position'] is num ? (t['position'] as num).toInt() : 1,
            durationSeconds: t['duration_seconds'] is num
                ? (t['duration_seconds'] as num).toInt()
                : null,
          ),
        );
      }
    }
    music = {
      'track_count': tracks.length,
      'tracks': tracks.map((e) => e.toJson()).toList(),
    };
  }

  Map<String, dynamic>? video;
  if (norm.containsKey('runtime_minutes')) {
    video = {
      if (norm['runtime_minutes'] is num)
        'runtime_minutes': (norm['runtime_minutes'] as num).toInt(),
    };
  }

  return AdminProviderPreview(
    provider: envelope.provider,
    providerItemId: envelope.providerItemId,
    kind: envelope.kind,
    title: title,
    itemNumber: norm['item_number']?.toString(),
    synopsis: synopsis,
    publisher: publisher,
    editionTitle: editionTitle,
    editionFormat: editionFormat,
    releaseDate: releaseDate,
    coverImageUrl: coverImageUrl,
    audienceRating: audienceRating,
    ageRating: ageRating,
    genres: genres,
    creators: creators,
    characters: characters,
    storyArcs: storyArcs,
    series: series,
    publishing: publishing,
    game: game,
    music: music,
    video: video,
  );
}
