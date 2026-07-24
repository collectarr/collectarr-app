class CatalogTrackDto {
  const CatalogTrackDto({
    this.title,
    this.trackNumber,
    this.duration,
    this.artist,
    Object? position,
    this.durationSeconds,
    this.discNumber,
  }) : position = position == null ? null : '$position';

  final String? title;
  final String? trackNumber;
  final String? duration;
  final String? artist;
  final String? position;
  final int? durationSeconds;
  final int? discNumber;

  factory CatalogTrackDto.fromJson(Map<String, dynamic> json) {
    return CatalogTrackDto(
      title: json['title'] as String?,
      trackNumber: json['track_number']?.toString(),
      duration: json['duration'] as String?,
      artist: json['artist'] as String?,
      position: json['position'],
      durationSeconds: json['duration_seconds'] as int?,
      discNumber: json['disc_number'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (title != null) 'title': title,
      if (trackNumber != null) 'track_number': trackNumber,
      if (duration != null) 'duration': duration,
      if (artist != null) 'artist': artist,
      if (position != null) 'position': position,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (discNumber != null) 'disc_number': discNumber,
    };
  }
}

typedef CatalogTrack = CatalogTrackDto;
