class MusicTrackRef {
  const MusicTrackRef({
    required this.title,
    this.position,
    this.durationSeconds,
    this.artist,
    this.discNumber,
  });

  final String title;
  final int? position;
  final int? durationSeconds;
  final String? artist;
  final int? discNumber;
}

class MusicDiscRef {
  const MusicDiscRef({
    required this.discNumber,
    this.discName,
    this.discFormat,
    this.trackCount,
    this.mediaCondition,
    this.tracks = const <MusicTrackRef>[],
  });

  final int discNumber;
  final String? discName;
  final String? discFormat;
  final int? trackCount;
  final String? mediaCondition;
  final List<MusicTrackRef> tracks;
}

class MusicRelease {
  const MusicRelease({
    required this.id,
    required this.title,
    this.artist,
    this.publisher,
    this.catalogNumber,
    this.upc,
    this.releaseDate,
    this.releaseStatus,
    this.releaseType,
    this.coverImageUrl,
    this.discs = const <MusicDiscRef>[],
    this.tracks = const <MusicTrackRef>[],
  });

  final String id;
  final String title;
  final String? artist;
  final String? publisher;
  final String? catalogNumber;
  final String? upc;
  final DateTime? releaseDate;
  final String? releaseStatus;
  final String? releaseType;
  final String? coverImageUrl;
  final List<MusicDiscRef> discs;
  final List<MusicTrackRef> tracks;
}
