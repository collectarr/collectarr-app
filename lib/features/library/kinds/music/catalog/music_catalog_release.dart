import 'package:collectarr_app/core/api/dto/catalog/catalog_disc_dto.dart';

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
    this.genres = const <String>[],
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
  final List<String> genres;
  final List<MusicDiscRef> discs;
  final List<MusicTrackRef> tracks;

  // Extended getters for compatibility with inspector and server compare
  bool? get isLive => null;
  String? get frontCoverUrl => coverImageUrl;
  String? get backCoverUrl => null;
  String? get sortTitle => null;
  String? get subtitle => null;
  DateTime? get originalReleaseDate => null;
  DateTime? get recordingDate => null;
  String? get countryCode => null;
  String? get language => null;
  String? get instrument => null;
  String? get composition => null;
  String? get spars => null;
  String? get soundType => null;
  String? get vinylColor => null;
  String? get vinylWeight => null;
  String? get mediaCondition => null;
  int? get rpm => null;
  List<MusicDiscRef> get media => discs;
  List<Map<String, dynamic>> get creators => const <Map<String, dynamic>>[];
  List<CatalogDisc> get discsAsCatalog => const <CatalogDisc>[];
}
