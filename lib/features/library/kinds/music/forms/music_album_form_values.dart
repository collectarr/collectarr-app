import 'package:collectarr_app/features/library/kinds/music/domain/music_box_set_membership.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';

/// Flutter independent values for one concrete pressing or edition.
final class MusicAlbumFormValues {
  MusicAlbumFormValues({
    this.title = '',
    this.sortTitle = '',
    this.subtitle = '',
    this.artist = '',
    this.originalTitle = '',
    this.originalReleaseDate,
    this.recordingDate,
    List<String> studios = const [],
    this.isLive,
    List<String> genres = const [],
    this.releaseType = '',
    this.releaseStatus = '',
    this.releaseDate,
    this.publisher = '',
    this.countryCode = '',
    this.language = '',
    this.barcode = '',
    this.upc = '',
    this.catalogNumber = '',
    this.packaging = '',
    this.physicalFormat = '',
    this.physicalFormatLabel = '',
    List<String> soundTypes = const [],
    this.vinylColor = '',
    this.vinylWeight = '',
    this.rpm,
    this.spars = '',
    this.extra = '',
    this.boxSetName = '',
    this.coverImageUrl = '',
    this.boxSetMembership,
  })  : studios = List.of(studios),
        genres = List.of(genres),
        soundTypes = List.of(soundTypes);

  factory MusicAlbumFormValues.fromAlbum(MusicAlbum album) =>
      MusicAlbumFormValues(
        title: album.title,
        sortTitle: album.sortTitle ?? '',
        subtitle: album.subtitle ?? '',
        artist: album.artist ?? '',
        originalTitle: album.originalTitle ?? '',
        originalReleaseDate: album.originalReleaseDate,
        recordingDate: album.recordingDate,
        studios: album.studios,
        isLive: album.isLive,
        genres: album.genres,
        releaseType: album.releaseType ?? '',
        releaseStatus: album.releaseStatus ?? '',
        releaseDate: album.releaseDate,
        publisher: album.publisher ?? '',
        countryCode: album.countryCode ?? '',
        language: album.language ?? '',
        barcode: album.barcode ?? '',
        upc: album.upc ?? '',
        catalogNumber: album.catalogNumber ?? '',
        packaging: album.packaging ?? '',
        physicalFormat: album.physicalFormat ?? '',
        physicalFormatLabel: album.physicalFormatLabel ?? '',
        soundTypes: album.soundTypes,
        vinylColor: album.vinylColor ?? '',
        vinylWeight: album.vinylWeight ?? '',
        rpm: album.rpm,
        spars: album.spars ?? '',
        extra: album.extra ?? '',
        boxSetName: album.boxSetName ?? '',
        coverImageUrl: album.coverImageUrl ?? '',
        boxSetMembership: album.boxSetMembership,
      );

  String title;
  String sortTitle;
  String subtitle;
  String artist;
  String originalTitle;
  DateTime? originalReleaseDate;
  DateTime? recordingDate;
  List<String> studios;
  bool? isLive;
  List<String> genres;
  String releaseType;
  String releaseStatus;
  DateTime? releaseDate;
  String publisher;
  String countryCode;
  String language;
  String barcode;
  String upc;
  String catalogNumber;
  String packaging;
  String physicalFormat;
  String physicalFormatLabel;
  List<String> soundTypes;
  String vinylColor;
  String vinylWeight;
  int? rpm;
  String spars;
  String extra;
  String boxSetName;
  String coverImageUrl;
  MusicBoxSetMembership? boxSetMembership;
}
