// GENERATED CODE - DO NOT MODIFY BY HAND.
// Source: tool/core_contracts/music-catalog-v1.json
// Contract SHA-256: 68bcdc29e4700857d9d675e87a8765cfba128ee583ef189e6cd837fd4bda5eab
part of 'collectarr_api.models.dart';

String _musicRequiredString(Object? value, String field) {
  if (value is String) return value;
  throw FormatException('Missing or invalid Music field: $field');
}

String? _musicOptionalString(Object? value) => value is String ? value : null;

int? _musicOptionalInt(Object? value) => value is int
    ? value
    : value is num
        ? value.toInt()
        : null;

int _musicRequiredInt(Object? value, String field) {
  final parsed = _musicOptionalInt(value);
  if (parsed != null) return parsed;
  throw FormatException('Missing or invalid Music field: $field');
}

bool? _musicOptionalBool(Object? value) => value is bool ? value : null;

bool _musicRequiredBool(Object? value, String field) {
  final parsed = _musicOptionalBool(value);
  if (parsed != null) return parsed;
  throw FormatException('Missing or invalid Music field: $field');
}

PartialDate? _musicOptionalPartialDate(Object? value) =>
    PartialDate.tryParse(value);

List<String> _musicStringList(Object? value) => value is List
    ? [
        for (final entry in value)
          if (entry is String) entry
      ]
    : const <String>[];

List<Map<String, dynamic>> _musicMapList(Object? value) => value is List
    ? [
        for (final entry in value)
          if (entry is Map) Map<String, dynamic>.from(entry),
      ]
    : const <Map<String, dynamic>>[];

List<T> _musicObjectList<T>(
  Object? value,
  T Function(Map<String, dynamic>) decode,
) =>
    value is List
        ? [
            for (final entry in value)
              if (entry is Map) decode(Map<String, dynamic>.from(entry)),
          ]
        : <T>[];

class MusicArtistCreditDto {
  const MusicArtistCreditDto({
    required this.artistId,
    required this.creditedName,
    required this.id,
    required this.joinPhrase,
    required this.sequence,
    required this.source,
  });

  final String? artistId;
  final String creditedName;
  final String id;
  final String? joinPhrase;
  final int? sequence;
  final String? source;

  factory MusicArtistCreditDto.fromJson(Map<String, dynamic> json) {
    return MusicArtistCreditDto(
      artistId: _musicOptionalString(json['artist_id']),
      creditedName:
          _musicRequiredString(json['credited_name'], 'credited_name'),
      id: _musicRequiredString(json['id'], 'id'),
      joinPhrase: _musicOptionalString(json['join_phrase']),
      sequence: _musicOptionalInt(json['sequence']),
      source: _musicOptionalString(json['source']),
    );
  }
}

class MusicContributorDto {
  const MusicContributorDto({
    required this.imageUrl,
    required this.name,
    required this.personId,
    required this.role,
    required this.roleId,
    required this.sequence,
  });

  final String? imageUrl;
  final String name;
  final String personId;
  final String role;
  final String? roleId;
  final int? sequence;

  factory MusicContributorDto.fromJson(Map<String, dynamic> json) {
    return MusicContributorDto(
      imageUrl: _musicOptionalString(json['image_url']),
      name: _musicRequiredString(json['name'], 'name'),
      personId: _musicRequiredString(json['person_id'], 'person_id'),
      role: _musicRequiredString(json['role'], 'role'),
      roleId: _musicOptionalString(json['role_id']),
      sequence: _musicOptionalInt(json['sequence']),
    );
  }
}

class MusicIdentifierDto {
  const MusicIdentifierDto({
    required this.id,
    required this.identifierType,
    required this.isPrimary,
    required this.normalizedValue,
    required this.sourceProvider,
    required this.value,
  });

  final String id;
  final String identifierType;
  final bool isPrimary;
  final String normalizedValue;
  final String? sourceProvider;
  final String value;

  factory MusicIdentifierDto.fromJson(Map<String, dynamic> json) {
    return MusicIdentifierDto(
      id: _musicRequiredString(json['id'], 'id'),
      identifierType:
          _musicRequiredString(json['identifier_type'], 'identifier_type'),
      isPrimary: _musicRequiredBool(json['is_primary'], 'is_primary'),
      normalizedValue:
          _musicRequiredString(json['normalized_value'], 'normalized_value'),
      sourceProvider: _musicOptionalString(json['source_provider']),
      value: _musicRequiredString(json['value'], 'value'),
    );
  }
}

class MusicMediumDto extends TypedMetadataResponse {
  const MusicMediumDto._(
    super.raw, {
    required this.bpDiscId,
    required this.cddbId,
    required this.expectedTrackCount,
    required this.id,
    required this.leadoutOffset,
    required this.mediumNumber,
    required this.mediumType,
    required this.missingTrackCount,
    required this.missingTrackPositions,
    required this.releaseId,
    required this.rpm,
    required this.soundType,
    required this.spars,
    required this.titleValue,
    required this.toc,
    required this.trackCount,
    required this.tracks,
    required this.vinylColor,
    required this.vinylWeight,
  });

  @override
  final String id;
  final String? bpDiscId;
  final String? cddbId;
  final int? expectedTrackCount;
  final int? leadoutOffset;
  final int mediumNumber;
  final String? mediumType;
  final int? missingTrackCount;
  final List<String> missingTrackPositions;
  final String releaseId;
  final int? rpm;
  final String? soundType;
  final String? spars;
  final String? titleValue;
  final String? toc;
  final int? trackCount;
  final List<MusicTrackDto> tracks;
  final String? vinylColor;
  final String? vinylWeight;

  @override
  String get title => titleValue ?? 'Medium';
  @override
  DateTime? get releaseDate => null;
  @override
  String? get coverImageUrl => null;
  @override
  String? get thumbnailImageUrl => coverImageUrl;
  @override
  String? get barcode => null;
  @override
  String? get kind => 'music';

  factory MusicMediumDto.fromJson(Map<String, dynamic> json) {
    return MusicMediumDto._(
      Map<String, dynamic>.from(json),
      bpDiscId: _musicOptionalString(json['bp_disc_id']),
      cddbId: _musicOptionalString(json['cddb_id']),
      expectedTrackCount: _musicOptionalInt(json['expected_track_count']),
      id: _musicRequiredString(json['id'], 'id'),
      leadoutOffset: _musicOptionalInt(json['leadout_offset']),
      mediumNumber: _musicRequiredInt(json['medium_number'], 'medium_number'),
      mediumType: _musicOptionalString(json['medium_type']),
      missingTrackCount: _musicOptionalInt(json['missing_track_count']),
      missingTrackPositions: _musicStringList(json['missing_track_positions']),
      releaseId: _musicRequiredString(json['release_id'], 'release_id'),
      rpm: _musicOptionalInt(json['rpm']),
      soundType: _musicOptionalString(json['sound_type']),
      spars: _musicOptionalString(json['spars']),
      titleValue: _musicOptionalString(json['title']),
      toc: _musicOptionalString(json['toc']),
      trackCount: _musicOptionalInt(json['track_count']),
      tracks: _musicObjectList<MusicTrackDto>(
          json['tracks'], MusicTrackDto.fromJson),
      vinylColor: _musicOptionalString(json['vinyl_color']),
      vinylWeight: _musicOptionalString(json['vinyl_weight']),
    );
  }
}

class MusicReleaseGroupDto extends TypedMetadataResponse {
  const MusicReleaseGroupDto._(
    super.raw, {
    required this.artist,
    required this.artistCredits,
    required this.coverImageKey,
    required this.coverImageUrlValue,
    required this.externalLinks,
    required this.genres,
    required this.id,
    required this.isLive,
    required this.originalReleaseDateValue,
    required this.originalReleaseDateParts,
    required this.originalTitle,
    required this.recordingDateValue,
    required this.recordingDateParts,
    required this.releases,
    required this.sortTitle,
    required this.studio,
    required this.titleValue,
  });

  @override
  final String id;
  final String? artist;
  final List<MusicArtistCreditDto> artistCredits;
  final String? coverImageKey;
  final String? coverImageUrlValue;
  final List<Map<String, dynamic>> externalLinks;
  final List<String> genres;
  final bool? isLive;
  final PartialDate? originalReleaseDateValue;
  final PartialDate? originalReleaseDateParts;
  final String? originalTitle;
  final PartialDate? recordingDateValue;
  final PartialDate? recordingDateParts;
  final List<MusicReleaseSummaryDto> releases;
  final String? sortTitle;
  final String? studio;
  final String titleValue;

  @override
  String get title => titleValue;
  @override
  DateTime? get releaseDate =>
      (originalReleaseDateParts ?? originalReleaseDateValue)?.asDateTime;
  @override
  String? get coverImageUrl => coverImageUrlValue;
  @override
  String? get thumbnailImageUrl => coverImageUrl;
  @override
  String? get barcode => null;
  @override
  String? get kind => 'music';

  factory MusicReleaseGroupDto.fromJson(Map<String, dynamic> json) {
    return MusicReleaseGroupDto._(
      Map<String, dynamic>.from(json),
      artist: _musicOptionalString(json['artist']),
      artistCredits: _musicObjectList<MusicArtistCreditDto>(
          json['artist_credits'], MusicArtistCreditDto.fromJson),
      coverImageKey: _musicOptionalString(json['cover_image_key']),
      coverImageUrlValue: _musicOptionalString(json['cover_image_url']),
      externalLinks: _musicMapList(json['external_links']),
      genres: _musicStringList(json['genres']),
      id: _musicRequiredString(json['id'], 'id'),
      isLive: _musicOptionalBool(json['is_live']),
      originalReleaseDateValue:
          _musicOptionalPartialDate(json['original_release_date']),
      originalReleaseDateParts:
          _musicOptionalPartialDate(json['original_release_date_parts']),
      originalTitle: _musicOptionalString(json['original_title']),
      recordingDateValue: _musicOptionalPartialDate(json['recording_date']),
      recordingDateParts:
          _musicOptionalPartialDate(json['recording_date_parts']),
      releases: _musicObjectList<MusicReleaseSummaryDto>(
          json['releases'], MusicReleaseSummaryDto.fromJson),
      sortTitle: _musicOptionalString(json['sort_title']),
      studio: _musicOptionalString(json['studio']),
      titleValue: _musicRequiredString(json['title'], 'title'),
    );
  }
}

class MusicReleaseLabelDto {
  const MusicReleaseLabelDto({
    required this.catalogNumber,
    required this.id,
    required this.labelId,
    required this.labelName,
    required this.sequence,
    required this.source,
  });

  final String? catalogNumber;
  final String id;
  final String? labelId;
  final String labelName;
  final int? sequence;
  final String? source;

  factory MusicReleaseLabelDto.fromJson(Map<String, dynamic> json) {
    return MusicReleaseLabelDto(
      catalogNumber: _musicOptionalString(json['catalog_number']),
      id: _musicRequiredString(json['id'], 'id'),
      labelId: _musicOptionalString(json['label_id']),
      labelName: _musicRequiredString(json['label_name'], 'label_name'),
      sequence: _musicOptionalInt(json['sequence']),
      source: _musicOptionalString(json['source']),
    );
  }
}

class MusicReleaseSummaryDto {
  const MusicReleaseSummaryDto({
    required this.barcodeValue,
    required this.catalogNumber,
    required this.coverImageUrlValue,
    required this.id,
    required this.mediumTypes,
    required this.publisher,
    required this.releaseDateValue,
    required this.releaseDateParts,
    required this.releaseGroupId,
    required this.releaseStatus,
    required this.releaseType,
    required this.title,
  });

  final String? barcodeValue;
  final String? catalogNumber;
  final String? coverImageUrlValue;
  final String id;
  final List<String> mediumTypes;
  final String? publisher;
  final PartialDate? releaseDateValue;
  final PartialDate? releaseDateParts;
  final String releaseGroupId;
  final String? releaseStatus;
  final String? releaseType;
  final String title;

  factory MusicReleaseSummaryDto.fromJson(Map<String, dynamic> json) {
    return MusicReleaseSummaryDto(
      barcodeValue: _musicOptionalString(json['barcode']),
      catalogNumber: _musicOptionalString(json['catalog_number']),
      coverImageUrlValue: _musicOptionalString(json['cover_image_url']),
      id: _musicRequiredString(json['id'], 'id'),
      mediumTypes: _musicStringList(json['medium_types']),
      publisher: _musicOptionalString(json['publisher']),
      releaseDateValue: _musicOptionalPartialDate(json['release_date']),
      releaseDateParts: _musicOptionalPartialDate(json['release_date_parts']),
      releaseGroupId:
          _musicRequiredString(json['release_group_id'], 'release_group_id'),
      releaseStatus: _musicOptionalString(json['release_status']),
      releaseType: _musicOptionalString(json['release_type']),
      title: _musicRequiredString(json['title'], 'title'),
    );
  }
}

class MusicReleaseDto extends TypedMetadataResponse {
  const MusicReleaseDto._(
    super.raw, {
    required this.artistCredits,
    required this.barcodeValue,
    required this.catalogNumber,
    required this.contributions,
    required this.countryCode,
    required this.coverImageKey,
    required this.coverImageUrlValue,
    required this.id,
    required this.identifiers,
    required this.kind,
    required this.labels,
    required this.language,
    required this.mediums,
    required this.packaging,
    required this.publisher,
    required this.releaseDateValue,
    required this.releaseDateParts,
    required this.releaseGroupId,
    required this.releaseStatus,
    required this.releaseType,
    required this.sortTitle,
    required this.subtitle,
    required this.titleValue,
    required this.upc,
  });

  @override
  final String id;
  final List<MusicArtistCreditDto> artistCredits;
  final String? barcodeValue;
  final String? catalogNumber;
  final List<MusicContributorDto> contributions;
  final String? countryCode;
  final String? coverImageKey;
  final String? coverImageUrlValue;
  final List<MusicIdentifierDto> identifiers;
  @override
  final String kind;
  final List<MusicReleaseLabelDto> labels;
  final String? language;
  final List<MusicMediumDto> mediums;
  final String? packaging;
  final String? publisher;
  final PartialDate? releaseDateValue;
  final PartialDate? releaseDateParts;
  final String releaseGroupId;
  final String? releaseStatus;
  final String? releaseType;
  final String? sortTitle;
  final String? subtitle;
  final String titleValue;
  final String? upc;

  @override
  String get title => titleValue;
  @override
  DateTime? get releaseDate =>
      (releaseDateParts ?? releaseDateValue)?.asDateTime;
  @override
  String? get coverImageUrl => coverImageUrlValue;
  @override
  String? get thumbnailImageUrl => coverImageUrl;
  @override
  String? get barcode => barcodeValue;

  factory MusicReleaseDto.fromJson(Map<String, dynamic> json) {
    return MusicReleaseDto._(
      Map<String, dynamic>.from(json),
      artistCredits: _musicObjectList<MusicArtistCreditDto>(
          json['artist_credits'], MusicArtistCreditDto.fromJson),
      barcodeValue: _musicOptionalString(json['barcode']),
      catalogNumber: _musicOptionalString(json['catalog_number']),
      contributions: _musicObjectList<MusicContributorDto>(
          json['contributions'], MusicContributorDto.fromJson),
      countryCode: _musicOptionalString(json['country_code']),
      coverImageKey: _musicOptionalString(json['cover_image_key']),
      coverImageUrlValue: _musicOptionalString(json['cover_image_url']),
      id: _musicRequiredString(json['id'], 'id'),
      identifiers: _musicObjectList<MusicIdentifierDto>(
          json['identifiers'], MusicIdentifierDto.fromJson),
      kind: _musicOptionalString(json['kind']) ?? 'music',
      labels: _musicObjectList<MusicReleaseLabelDto>(
          json['labels'], MusicReleaseLabelDto.fromJson),
      language: _musicOptionalString(json['language']),
      mediums: _musicObjectList<MusicMediumDto>(
          json['mediums'], MusicMediumDto.fromJson),
      packaging: _musicOptionalString(json['packaging']),
      publisher: _musicOptionalString(json['publisher']),
      releaseDateValue: _musicOptionalPartialDate(json['release_date']),
      releaseDateParts: _musicOptionalPartialDate(json['release_date_parts']),
      releaseGroupId:
          _musicRequiredString(json['release_group_id'], 'release_group_id'),
      releaseStatus: _musicOptionalString(json['release_status']),
      releaseType: _musicOptionalString(json['release_type']),
      sortTitle: _musicOptionalString(json['sort_title']),
      subtitle: _musicOptionalString(json['subtitle']),
      titleValue: _musicRequiredString(json['title'], 'title'),
      upc: _musicOptionalString(json['upc']),
    );
  }
}

class MusicTrackDto extends TypedMetadataResponse {
  const MusicTrackDto._(
    super.raw, {
    required this.artist,
    required this.bitrateKbps,
    required this.composition,
    required this.durationMs,
    required this.fileSizeBytes,
    required this.id,
    required this.indentLevel,
    required this.instrument,
    required this.isHeader,
    required this.mediumId,
    required this.offsetMs,
    required this.parentHeaderId,
    required this.position,
    required this.recordingId,
    required this.titleValue,
    required this.trackHash,
  });

  @override
  final String id;
  final String? artist;
  final int? bitrateKbps;
  final String? composition;
  final int? durationMs;
  final int? fileSizeBytes;
  final int indentLevel;
  final String? instrument;
  final bool isHeader;
  final String mediumId;
  final int? offsetMs;
  final String? parentHeaderId;
  final String position;
  final String? recordingId;
  final String titleValue;
  final String? trackHash;

  @override
  String get title => titleValue;
  @override
  DateTime? get releaseDate => null;
  @override
  String? get coverImageUrl => null;
  @override
  String? get thumbnailImageUrl => coverImageUrl;
  @override
  String? get barcode => null;
  @override
  String? get kind => 'music';

  factory MusicTrackDto.fromJson(Map<String, dynamic> json) {
    return MusicTrackDto._(
      Map<String, dynamic>.from(json),
      artist: _musicOptionalString(json['artist']),
      bitrateKbps: _musicOptionalInt(json['bitrate_kbps']),
      composition: _musicOptionalString(json['composition']),
      durationMs: _musicOptionalInt(json['duration_ms']),
      fileSizeBytes: _musicOptionalInt(json['file_size_bytes']),
      id: _musicRequiredString(json['id'], 'id'),
      indentLevel: _musicOptionalInt(json['indent_level']) ?? 0,
      instrument: _musicOptionalString(json['instrument']),
      isHeader: _musicOptionalBool(json['is_header']) ?? false,
      mediumId: _musicRequiredString(json['medium_id'], 'medium_id'),
      offsetMs: _musicOptionalInt(json['offset_ms']),
      parentHeaderId: _musicOptionalString(json['parent_header_id']),
      position: _musicRequiredString(json['position'], 'position'),
      recordingId: _musicOptionalString(json['recording_id']),
      titleValue: _musicRequiredString(json['title'], 'title'),
      trackHash: _musicOptionalString(json['track_hash']),
    );
  }
}
