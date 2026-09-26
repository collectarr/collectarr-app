import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:flutter/foundation.dart';

import 'music_ids.dart';

@immutable
final class MusicAlbumArtist {
  const MusicAlbumArtist({required this.name, this.sortName});
  final String name;
  final String? sortName;

  Map<String, dynamic> toJson() => {
        'name': name,
        if (sortName != null) 'sort_name': sortName,
      };
}

@immutable
final class MusicAlbumLabel {
  const MusicAlbumLabel({required this.name, this.catalogNumber});
  final String name;
  final String? catalogNumber;

  Map<String, dynamic> toJson() => {
        'name': name,
        if (catalogNumber != null) 'catalog_number': catalogNumber,
      };
}

@immutable
final class MusicAlbumDiscTitle {
  const MusicAlbumDiscTitle({required this.discNumber, required this.title})
      : assert(discNumber > 0);
  final int discNumber;
  final String title;

  Map<String, dynamic> toJson() => {'disc_number': discNumber, 'title': title};
}

@immutable
final class MusicAlbumCredit {
  const MusicAlbumCredit({
    required this.role,
    required this.sequence,
    required this.creditedName,
    this.joinPhrase,
    this.instrument,
  });
  final String role;
  final int sequence;
  final String creditedName;
  final String? joinPhrase;
  final String? instrument;

  Map<String, dynamic> toJson() => {
        'role': role,
        'sequence': sequence,
        'credited_name': creditedName,
        if (joinPhrase != null) 'join_phrase': joinPhrase,
        if (instrument != null) 'instrument': instrument,
      };
}

@immutable
final class MusicAlbumLink {
  const MusicAlbumLink({
    required this.position,
    required this.url,
    this.title,
    this.description,
  });
  final int position;
  final String url;
  final String? title;
  final String? description;

  Map<String, dynamic> toJson() => {
        'position': position,
        'url': url,
        if (title != null) 'title': title,
        if (description != null) 'description': description,
      };
}

/// One CLZ-style Music edition with its ordered disc titles and tracks.
/// Discs and tracks are contained values and have no separately addressable ID.
@immutable
final class MusicAlbum {
  const MusicAlbum({
    required this.id,
    required this.title,
    this.sortTitle,
    this.subtitle,
    this.artists = const [],
    this.releaseDate,
    this.originalReleaseDate,
    this.recordingDate,
    this.labels = const [],
    this.format,
    this.barcode,
    this.catalogNumber,
    this.genres = const [],
    this.packaging,
    this.studio = const [],
    this.country,
    this.isLive,
    this.soundTypes = const [],
    this.vinylColor,
    this.vinylWeight,
    this.rpm,
    this.extras = const [],
    this.sparsCode,
    this.boxSet,
    this.matrixNumberSideA,
    this.matrixNumberSideB,
    this.coverImageUrl,
    this.backCoverImageUrl,
    this.discTitles = const [],
    this.tracks = const [],
    this.credits = const [],
    this.links = const [],
    this.createdAt,
    this.updatedAt,
  });

  final MusicAlbumId id;
  final String title;
  final String? sortTitle;
  final String? subtitle;
  final List<MusicAlbumArtist> artists;
  final PartialDate? releaseDate;
  final PartialDate? originalReleaseDate;
  final PartialDate? recordingDate;
  final List<MusicAlbumLabel> labels;
  final String? format;
  final String? barcode;
  final String? catalogNumber;
  final List<String> genres;
  final String? packaging;
  final List<String> studio;
  final String? country;
  final bool? isLive;
  final List<String> soundTypes;
  final String? vinylColor;
  final double? vinylWeight;
  final int? rpm;
  final List<String> extras;
  final String? sparsCode;
  final String? boxSet;
  final String? matrixNumberSideA;
  final String? matrixNumberSideB;
  final String? coverImageUrl;
  final String? backCoverImageUrl;
  final List<MusicAlbumDiscTitle> discTitles;
  final List<MusicAlbumTrack> tracks;
  final List<MusicAlbumCredit> credits;
  final List<MusicAlbumLink> links;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DateTime? get releaseDateTime => releaseDate?.asDateTime;
  String? get artistDisplay => artists.map((artist) => artist.name).join(', ');
  CatalogItemRef get catalogItemRef =>
      CatalogItemRef(kind: CatalogMediaKind.music, id: id.value);

  Map<String, dynamic> toJson() => {
        'id': id.value,
        'title': title,
        if (sortTitle != null) 'sort_title': sortTitle,
        if (subtitle != null) 'subtitle': subtitle,
        'artists': artists.map((value) => value.toJson()).toList(),
        if (releaseDate != null) 'release_date': releaseDate!.toJson(),
        if (originalReleaseDate != null)
          'original_release_date': originalReleaseDate!.toJson(),
        if (recordingDate != null) 'recording_date': recordingDate!.toJson(),
        'labels': labels.map((value) => value.toJson()).toList(),
        if (format != null) 'format': format,
        if (barcode != null) 'barcode': barcode,
        if (catalogNumber != null) 'catalog_number': catalogNumber,
        'genres': genres,
        if (packaging != null) 'packaging': packaging,
        'studio': studio,
        if (country != null) 'country': country,
        if (isLive != null) 'is_live': isLive,
        'sound_types': soundTypes,
        if (vinylColor != null) 'vinyl_color': vinylColor,
        if (vinylWeight != null) 'vinyl_weight': vinylWeight,
        if (rpm != null) 'rpm': rpm,
        'extras': extras,
        if (sparsCode != null) 'spars_code': sparsCode,
        if (boxSet != null) 'box_set': boxSet,
        if (matrixNumberSideA != null)
          'matrix_number_side_a': matrixNumberSideA,
        if (matrixNumberSideB != null)
          'matrix_number_side_b': matrixNumberSideB,
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
        if (backCoverImageUrl != null)
          'back_cover_image_url': backCoverImageUrl,
        'disc_titles': discTitles.map((value) => value.toJson()).toList(),
        'tracks': tracks.map((value) => value.toJson()).toList(),
        'credits': credits.map((value) => value.toJson()).toList(),
        'links': links.map((value) => value.toJson()).toList(),
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      };
}

@immutable
final class MusicAlbumTrack {
  const MusicAlbumTrack({
    required this.albumId,
    required this.discNumber,
    required this.position,
    required this.title,
    this.artist,
    this.durationMs,
  })  : assert(discNumber > 0),
        assert(position > 0);

  final MusicAlbumId albumId;
  final int discNumber;
  final int position;
  final String title;
  final String? artist;
  final int? durationMs;

  Map<String, dynamic> toJson() => {
        'album_id': albumId.value,
        'disc_number': discNumber,
        'position': position,
        'title': title,
        if (artist != null) 'artist': artist,
        if (durationMs != null) 'duration_ms': durationMs,
      };
}
