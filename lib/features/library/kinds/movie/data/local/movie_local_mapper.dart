import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_ids.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_media.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_release.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details.dart';
import 'package:drift/drift.dart';

final class MovieLocalMapper {
  const MovieLocalMapper._();

  static MovieMediaRowsCompanion toMediaRow(MovieMedia media) {
    if (media.id.value.isEmpty) {
      throw StateError('Cannot persist MovieMedia without an id');
    }

    return MovieMediaRowsCompanion.insert(
      id: media.id.value,
      title: media.title,
      sortTitle: Value(media.sortTitle),
      description: Value(media.description),
      releaseDate: Value(media.releaseDate),
      originalLanguage: Value(media.originalLanguage),
      ageRating: Value(media.ageRating),
      audienceRating: Value(media.audienceRating),
      runtimeMinutes: Value(media.runtimeMinutes),
      subtitle: Value(media.subtitle),
      characterAppearancesJson: Value(_encodeList(media.characterAppearances)),
      contributionsJson: Value(_encodeList(media.contributions)),
      externalLinksJson: Value(_encodeList(media.externalLinks)),
      identifiersJson: Value(_encodeList(media.identifiers)),
      trailerUrlsJson: Value(_encodeList(media.trailerUrls)),
      rawPayloadJson: Value(jsonEncode(media.rawPayload)),
    );
  }

  static MovieMedia fromMediaRow(
    MovieMediaRow row, {
    List<MovieRelease> releases = const <MovieRelease>[],
  }) {
    return MovieMedia(
      id: MovieMediaId(row.id),
      title: row.title,
      sortTitle: row.sortTitle,
      description: row.description,
      releaseDate: row.releaseDate,
      originalLanguage: row.originalLanguage,
      ageRating: row.ageRating,
      audienceRating: row.audienceRating,
      runtimeMinutes: row.runtimeMinutes,
      subtitle: row.subtitle,
      characterAppearances: _decodeCharacters(row.characterAppearancesJson),
      contributions: _decodeContributors(row.contributionsJson),
      externalLinks: _decodeExternalLinks(row.externalLinksJson),
      identifiers: _decodeIdentifiers(row.identifiersJson),
      releases: releases,
      trailerUrls: _decodeTrailerLinks(row.trailerUrlsJson),
      rawPayload: _decodeMap(row.rawPayloadJson),
    );
  }

  static MovieReleaseRowsCompanion toReleaseRow(
    MovieMediaId mediaId,
    MovieRelease release,
  ) {
    if (mediaId.value.isEmpty || release.id.value.isEmpty) {
      throw StateError('Cannot persist MovieRelease without an id');
    }

    return MovieReleaseRowsCompanion.insert(
      mediaId: mediaId.value,
      id: release.id.value,
      title: release.title,
      workId: Value(release.workId),
      coverImageKey: Value(release.coverImageKey),
      coverImageUrl: Value(release.coverImageUrl),
      description: Value(release.description),
      distributor: Value(release.distributor),
      externalLinksJson: Value(_encodeList(release.externalLinks)),
      format: Value(release.format),
      language: Value(release.language),
      mediaJson: Value(_encodeList(release.media)),
      region: Value(release.region),
      releaseDate: Value(release.releaseDate),
      trailerUrlsJson: Value(_encodeList(release.trailerUrls)),
      rawPayloadJson: Value(jsonEncode(release.rawPayload)),
    );
  }

  static MovieRelease fromReleaseRow(MovieReleaseRow row) {
    return MovieRelease(
      id: MovieReleaseId(row.id),
      title: row.title,
      workId: row.workId,
      coverImageKey: row.coverImageKey,
      coverImageUrl: row.coverImageUrl,
      description: row.description,
      distributor: row.distributor,
      externalLinks: _decodeExternalLinks(row.externalLinksJson),
      format: row.format,
      language: row.language,
      media: _decodeMedia(row.mediaJson),
      region: row.region,
      releaseDate: row.releaseDate,
      trailerUrls: _decodeTrailerLinks(row.trailerUrlsJson),
      rawPayload: _decodeMap(row.rawPayloadJson),
    );
  }

  static MovieOwnedDetailsRowsCompanion toOwnedDetailsRow(
    String ownedItemId,
    MovieOwnedDetails details,
  ) {
    if (ownedItemId.isEmpty) {
      throw StateError('Cannot persist MovieOwnedDetails without an id');
    }

    return MovieOwnedDetailsRowsCompanion.insert(
      ownedItemId: ownedItemId,
      features: Value(details.features),
      hdrFormatsJson: Value(jsonEncode(details.hdrFormats)),
      boxSetId: Value(details.boxSetId),
      boxSetName: Value(details.boxSetName),
      region: Value(details.region),
      packaging: Value(details.packaging),
      distributor: Value(details.distributor),
    );
  }

  static MovieOwnedDetails fromOwnedDetailsRow(MovieOwnedDetailsRow row) {
    return MovieOwnedDetails(
      features: row.features,
      hdrFormats: _decodeStringList(row.hdrFormatsJson),
      boxSetId: row.boxSetId,
      boxSetName: row.boxSetName,
      region: row.region,
      packaging: row.packaging,
      distributor: row.distributor,
    );
  }

  static String _encodeList(Iterable<dynamic> values) => jsonEncode([
        for (final value in values)
          value is Map<String, dynamic> ? value : _toJson(value),
      ]);

  static Map<String, dynamic> _toJson(dynamic value) {
    if (value is MovieCharacterAppearance) return value.toJson();
    if (value is MovieContributor) return value.toJson();
    if (value is MovieExternalLink) return value.toJson();
    if (value is MovieIdentifier) return value.toJson();
    if (value is MovieTrailerLink) return value.toJson();
    if (value is MovieReleaseMedia) return value.toJson();
    throw StateError('Unsupported Movie JSON value: ${value.runtimeType}');
  }

  static dynamic _decodeJson(String raw) {
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
  }

  static List<Map<String, dynamic>> _decodeMaps(String raw) {
    final decoded = _decodeJson(raw);
    if (decoded is! List) return const <Map<String, dynamic>>[];
    return [
      for (final entry in decoded)
        if (entry is Map<Object?, Object?>) Map<String, dynamic>.from(entry),
    ];
  }

  static List<MovieCharacterAppearance> _decodeCharacters(String raw) => [
        for (final entry in _decodeMaps(raw))
          MovieCharacterAppearance.fromJson(entry),
      ];

  static List<MovieContributor> _decodeContributors(String raw) => [
        for (final entry in _decodeMaps(raw)) MovieContributor.fromJson(entry),
      ];

  static List<MovieExternalLink> _decodeExternalLinks(String raw) => [
        for (final entry in _decodeMaps(raw)) MovieExternalLink.fromJson(entry),
      ];

  static List<MovieIdentifier> _decodeIdentifiers(String raw) => [
        for (final entry in _decodeMaps(raw)) MovieIdentifier.fromJson(entry),
      ];

  static List<MovieReleaseMedia> _decodeMedia(String raw) => [
        for (final entry in _decodeMaps(raw)) MovieReleaseMedia.fromJson(entry),
      ];

  static List<MovieTrailerLink> _decodeTrailerLinks(String raw) => [
        for (final entry in _decodeMaps(raw)) MovieTrailerLink.fromJson(entry),
      ];

  static List<String> _decodeStringList(String raw) {
    final decoded = _decodeJson(raw);
    if (decoded is! List) return const <String>[];
    return decoded.whereType<String>().toList(growable: false);
  }

  static Map<String, dynamic> _decodeMap(String raw) {
    final decoded = _decodeJson(raw);
    if (decoded is! Map<Object?, Object?>) return const <String, dynamic>{};
    return Map<String, dynamic>.from(decoded);
  }
}
