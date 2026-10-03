import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album_relations.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';

/// Flutter independent values for one concrete pressing or edition.
final class MusicAlbumFormValues {
  MusicAlbumFormValues({
    this.title = '',
    this.sortTitle = '',
    this.subtitle = '',
    this.artist = '',
    this.artistCredits = const [],
    this.originalTitle = '',
    this.originalReleaseDateParts,
    this.recordingDateParts,
    List<String> studios = const [],
    this.isLive,
    List<String> genres = const [],
    this.releaseType = '',
    this.releaseStatus = '',
    this.releaseDateParts,
    this.publisher = '',
    this.countryCode = '',
    this.language = '',
    this.barcode = '',
    this.upc = '',
    this.catalogNumber = '',
    this.packaging = '',
    this.format = '',
    List<String> soundTypes = const [],
    this.vinylColor = '',
    this.vinylWeight = '',
    this.rpm,
    this.spars = '',
    this.extra = '',
    this.boxSet = '',
    this.coverImageUrl = '',
    this.backCoverImageUrl = '',
  })  : studios = List.of(studios),
        genres = List.of(genres),
        soundTypes = List.of(soundTypes);

  factory MusicAlbumFormValues.fromAlbum(MusicAlbum album) =>
      MusicAlbumFormValues(
        title: album.title,
        sortTitle: album.sortTitle ?? '',
        subtitle: album.subtitle ?? '',
        artist: album.artist ?? '',
        artistCredits: List.of(album.artistCredits),
        originalTitle: album.originalTitle ?? '',
        originalReleaseDateParts: album.originalReleaseDateParts,
        recordingDateParts: album.recordingDateParts,
        studios: album.studios,
        isLive: album.isLive,
        genres: album.genres,
        releaseType: album.releaseType ?? '',
        releaseStatus: album.releaseStatus ?? '',
        releaseDateParts: album.releaseDateParts,
        publisher: album.publisher ?? '',
        countryCode: album.countryCode ?? '',
        language: album.language ?? '',
        barcode: album.barcode ?? '',
        upc: album.upc ?? '',
        catalogNumber: album.catalogNumber ?? '',
        packaging: album.packaging ?? '',
        format: album.format ?? '',
        soundTypes: album.soundTypes,
        vinylColor: album.vinylColor ?? '',
        vinylWeight: album.vinylWeight ?? '',
        rpm: album.rpm,
        spars: album.spars ?? '',
        extra: album.extra ?? '',
        boxSet: album.boxSet ?? '',
        coverImageUrl: album.coverImageUrl ?? '',
        backCoverImageUrl: album.backCoverImageUrl ?? '',
      );

  String title;
  String sortTitle;
  String subtitle;
  String artist;
  List<MusicArtistCredit> artistCredits;
  String originalTitle;
  PartialDate? originalReleaseDateParts;
  PartialDate? recordingDateParts;
  List<String> studios;
  bool? isLive;
  List<String> genres;
  String releaseType;
  String releaseStatus;
  PartialDate? releaseDateParts;
  String publisher;
  String countryCode;
  String language;
  String barcode;
  String upc;
  String catalogNumber;
  String packaging;
  String format;
  List<String> soundTypes;
  String vinylColor;
  String vinylWeight;
  int? rpm;
  String spars;
  String extra;
  String boxSet;
  String coverImageUrl;
  String backCoverImageUrl;
}
