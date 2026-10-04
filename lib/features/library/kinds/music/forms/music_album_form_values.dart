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
    List<MusicArtistCredit> artistCredits = const [],
    this.originalReleaseDateParts,
    this.recordingDateParts,
    List<String> studios = const [],
    this.isLive,
    List<String> genres = const [],
    this.releaseDateParts,
    this.publisher = '',
    this.countryCode = '',
    this.barcode = '',
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
        soundTypes = List.of(soundTypes),
        artistCredits = List.of(artistCredits);

  factory MusicAlbumFormValues.fromAlbum(MusicAlbum album) =>
      MusicAlbumFormValues(
        title: album.title,
        sortTitle: album.sortTitle ?? '',
        subtitle: album.subtitle ?? '',
        artist: album.artist ?? '',
        artistCredits: List.of(album.artistCredits),
        originalReleaseDateParts: album.originalReleaseDateParts,
        recordingDateParts: album.recordingDateParts,
        studios: album.studios,
        isLive: album.isLive,
        genres: album.genres,
        releaseDateParts: album.releaseDateParts,
        publisher: album.publisher ?? '',
        countryCode: album.countryCode ?? '',
        barcode: album.barcode ?? '',
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
  PartialDate? originalReleaseDateParts;
  PartialDate? recordingDateParts;
  List<String> studios;
  bool? isLive;
  List<String> genres;
  PartialDate? releaseDateParts;
  String publisher;
  String countryCode;
  String barcode;
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
