import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_artist_credit.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_credit.dart';

/// Flutter-independent form values for album-level edition metadata.
/// Recording properties belong to [MusicDisc] and are edited per disc.
final class MusicAlbumFormValues {
  MusicAlbumFormValues({
    this.title = '',
    this.sortTitle = '',
    this.subtitle = '',
    this.artist = '',
    List<MusicArtistCredit> artistCredits = const [],
    this.originalReleaseDateParts,
    List<String> genres = const [],
    this.releaseDateParts,
    this.publisher = '',
    this.countryCode = '',
    this.barcode = '',
    this.catalogNumber = '',
    this.packaging = '',
    List<String> extra = const [],
    this.boxSet = '',
    this.coverImageUrl = '',
    this.backCoverImageUrl = '',
    List<MusicCredit> credits = const [],
  })  : artistCredits = List.of(artistCredits),
        genres = List.of(genres),
        extra = List.of(extra),
        credits = List.of(credits);

  factory MusicAlbumFormValues.fromAlbum(MusicAlbum album) =>
      MusicAlbumFormValues(
        title: album.title,
        sortTitle: album.sortTitle ?? '',
        subtitle: album.subtitle ?? '',
        artist: album.artist ?? '',
        artistCredits: album.artistCredits,
        originalReleaseDateParts: album.originalReleaseDateParts,
        genres: album.genres,
        releaseDateParts: album.releaseDateParts,
        publisher: album.publisher ?? '',
        countryCode: album.countryCode ?? '',
        barcode: album.barcode ?? '',
        catalogNumber: album.catalogNumber ?? '',
        packaging: album.packaging ?? '',
        extra: album.extra,
        boxSet: album.boxSet ?? '',
        coverImageUrl: album.coverImageUrl ?? '',
        backCoverImageUrl: album.backCoverImageUrl ?? '',
        credits: album.credits,
      );

  String title;
  String sortTitle;
  String subtitle;
  String artist;
  List<MusicArtistCredit> artistCredits;
  PartialDate? originalReleaseDateParts;
  List<String> genres;
  PartialDate? releaseDateParts;
  String publisher;
  String countryCode;
  String barcode;
  String catalogNumber;
  String packaging;
  List<String> extra;
  String boxSet;
  String coverImageUrl;
  String backCoverImageUrl;
  List<MusicCredit> credits;
}
