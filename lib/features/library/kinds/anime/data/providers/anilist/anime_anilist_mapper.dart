import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_media.dart';
import 'package:collectarr_app/features/providers/adapters/anilist/models/anilist_media.dart';
import 'package:collectarr_app/features/providers/domain/models/normalized_provider_envelope_v1.dart';

/// Converts AniList's native GraphQL model into the Anime-owned domain graph.
final class AnimeAniListMapper {
  const AnimeAniListMapper._();

  static AnimeMedia fromNative(AniListMedia media) {
    _validateNativeKind(media);
    final id = media.id;
    if (id == null) {
      throw const FormatException('AniList anime is missing an id');
    }

    return AnimeMedia.fromJson(_payloadFromNative(media));
  }

  static AnimeMedia fromEnvelope(NormalizedProviderEnvelopeV1 envelope) {
    _validateEnvelope(envelope);
    final normalized = Map<String, dynamic>.from(envelope.normalized);
    final coverImageUrl = _text(normalized['cover_image_url']) ??
        (envelope.images.isEmpty ? null : envelope.images.first.url);
    return AnimeMedia.fromJson({
      ...normalized,
      'id': envelope.providerItemId,
      'kind': CatalogMediaKind.anime.apiValue,
      'title': _text(normalized['title']) ?? 'Unknown anime',
      if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
    });
  }

  static Map<String, dynamic> _payloadFromNative(AniListMedia media) {
    final id = media.id!;
    final title = _title(media.title) ?? 'Unknown anime';
    final coverImageUrl = _cover(media.coverImage);
    final contributions = [
      for (final staff in media.staff)
        if (_text(staff.name) case final name?)
          {
            'id': _text(staff.siteUrl),
            'person_id': _text(staff.siteUrl),
            'name': name,
            'role': _text(staff.role) ?? 'Creator',
          },
    ];
    final characters = [
      for (final character in media.characters)
        if (_text(character.name) case final name?)
          {
            'id': _characterId(character),
            'character_id': _text(character.siteUrl) ?? name,
            'character_name': name,
            'role': _text(character.role) ?? 'Supporting',
          },
    ];
    final providerIds = <String, String>{
      'anilist': id.toString(),
      if (media.idMal != null) 'mal': media.idMal.toString(),
    };

    return {
      'id': 'anime:$id',
      'kind': CatalogMediaKind.anime.apiValue,
      'title': title,
      if (media.title?.native != null) 'native_title': media.title!.native,
      if (media.title?.romaji != null) 'romaji_title': media.title!.romaji,
      if (media.title?.english != null) 'english_title': media.title!.english,
      if (media.type != null) 'media_type': media.type,
      if (media.format != null) 'anime_type': media.format,
      if (media.status != null) 'status': media.status,
      if (media.status != null) 'airing_status': media.status,
      if (media.description != null)
        'description': _cleanDescription(media.description),
      if (media.episodes != null) 'episode_count': media.episodes,
      if (media.duration != null) 'episode_runtime_minutes': media.duration,
      if (media.startDate != null) 'original_air_date': _date(media.startDate),
      if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      'genres': media.genres,
      'contributions': contributions,
      'character_appearances': characters,
      'provider_ids': providerIds,
      if (media.siteUrl != null)
        'external_links': [
          {'provider': 'anilist', 'url': media.siteUrl},
        ],
      if (media.trailer?.id != null)
        'trailer_urls': [
          {
            'provider': 'anilist',
            'id': media.trailer!.id,
            'site': media.trailer!.site,
            'thumbnail': media.trailer!.thumbnail,
          },
        ],
      'relations': [
        for (final relation in media.relations)
          if (relation.media != null)
            {
              'relation_type': relation.relationType,
              'target_id': relation.media!.id?.toString(),
              'target_title': _title(relation.media!.title),
              'target_format': relation.media!.format,
            },
      ],
    };
  }

  static void _validateEnvelope(NormalizedProviderEnvelopeV1 envelope) {
    if (envelope.provider.trim().toLowerCase() != 'anilist') {
      throw StateError(
        'Anime AniList integration received ${envelope.provider} data',
      );
    }
    if (envelope.kind.trim().toLowerCase() != CatalogMediaKind.anime.apiValue) {
      throw StateError(
        'Anime AniList integration received ${envelope.kind} data',
      );
    }
  }

  static void _validateNativeKind(AniListMedia media) {
    final type = _text(media.type)?.toUpperCase();
    if (type != null && type != 'ANIME') {
      throw StateError('Expected an AniList anime, got ${media.type}');
    }
  }

  static String? _title(AniListTitle? title) =>
      _text(title?.english) ?? _text(title?.romaji) ?? _text(title?.native);

  static String? _cover(AniListCoverImage? cover) =>
      _text(cover?.large) ?? _text(cover?.medium);

  static String? _date(AniListDate? date) {
    if (date?.year == null) return null;
    return DateTime.utc(date!.year!, date.month ?? 1, date.day ?? 1)
        .toIso8601String();
  }

  static String _characterId(AniListCharacterCredit character) {
    final siteUrl = _text(character.siteUrl);
    if (siteUrl != null) return siteUrl;
    return 'anilist-character-${_slug(_text(character.name) ?? 'unknown')}';
  }

  static String _slug(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');

  static String? _cleanDescription(String? value) {
    final text = _text(value)?.replaceAll(RegExp(r'<[^>]+>'), '').trim();
    return text == null || text.isEmpty ? null : text;
  }

  static String? _text(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
