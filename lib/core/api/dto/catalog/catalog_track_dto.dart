class CatalogTrackDto {
  const CatalogTrackDto({
    required this.title,
    this.position,
    this.durationSeconds,
    this.offsetMilliseconds,
    this.bitrateKbps,
    this.fileSizeBytes,
    this.trackHash,
    this.artist,
    this.discNumber,
  });

  final String title;
  final int? position;
  final int? durationSeconds;
  final int? offsetMilliseconds;
  final int? bitrateKbps;
  final int? fileSizeBytes;
  final String? trackHash;
  final String? artist;
  final int? discNumber;

  factory CatalogTrackDto.fromJson(Map<String, dynamic> json) {
    return CatalogTrackDto(
      title: json['title'] as String? ?? 'Untitled track',
      position: json['position'] as int?,
      durationSeconds: json['duration_seconds'] as int?,
      offsetMilliseconds: json['offset_milliseconds'] as int?,
      bitrateKbps: json['bitrate_kbps'] as int?,
      fileSizeBytes: json['file_size_bytes'] as int?,
      trackHash: json['track_hash'] as String?,
      artist: json['artist'] as String?,
      discNumber: json['disc_number'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (position != null) 'position': position,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (offsetMilliseconds != null) 'offset_milliseconds': offsetMilliseconds,
      if (bitrateKbps != null) 'bitrate_kbps': bitrateKbps,
      if (fileSizeBytes != null) 'file_size_bytes': fileSizeBytes,
      if (trackHash != null) 'track_hash': trackHash,
      if (artist != null) 'artist': artist,
      if (discNumber != null) 'disc_number': discNumber,
    };
  }
}
