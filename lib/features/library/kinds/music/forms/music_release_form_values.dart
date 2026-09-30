import 'package:collectarr_app/features/library/kinds/music/domain/music_box_set_membership.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';

/// Flutter independent values for one concrete pressing or edition.
final class MusicReleaseFormValues {
  MusicReleaseFormValues({
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

  factory MusicReleaseFormValues.fromRelease(MusicRelease release) =>
      MusicReleaseFormValues(
        title: release.title,
        sortTitle: release.sortTitle ?? '',
        subtitle: release.subtitle ?? '',
        artist: release.artist ?? '',
        originalTitle: release.originalTitle ?? '',
        originalReleaseDate: release.originalReleaseDate,
        recordingDate: release.recordingDate,
        studios: release.studios,
        isLive: release.isLive,
        genres: release.genres,
        releaseType: release.releaseType ?? '',
        releaseStatus: release.releaseStatus ?? '',
        releaseDate: release.releaseDate,
        publisher: release.publisher ?? '',
        countryCode: release.countryCode ?? '',
        language: release.language ?? '',
        barcode: release.barcode ?? '',
        upc: release.upc ?? '',
        catalogNumber: release.catalogNumber ?? '',
        packaging: release.packaging ?? '',
        physicalFormat: release.physicalFormat ?? '',
        physicalFormatLabel: release.physicalFormatLabel ?? '',
        soundTypes: release.soundTypes,
        vinylColor: release.vinylColor ?? '',
        vinylWeight: release.vinylWeight ?? '',
        rpm: release.rpm,
        spars: release.spars ?? '',
        extra: release.extra ?? '',
        boxSetName: release.boxSetName ?? '',
        coverImageUrl: release.coverImageUrl ?? '',
        boxSetMembership: release.boxSetMembership,
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
