import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';

/// Editable values for one concrete Music catalog item.
///
/// Add stores album and pressing details on the same item. Disc and track data
/// remains contained by that item and is edited through its child editor.
final class MusicAddManualDraft implements LibraryKindAddDraft {
  MusicAddManualDraft({
    this.artist = '',
    this.sortTitle = '',
    this.subtitle = '',
    List<String> genres = const [],
    this.coverImageUrl = '',
    this.backCoverImageUrl = '',
    this.thumbnailImageUrl = '',
    this.format = '',
    this.packaging = '',
    this.catalogNumber = '',
    this.barcode = '',
    this.countryCode = '',
    this.releaseDate,
    this.originalReleaseDate,
    this.recordingDate,
    this.recordLabel = '',
    List<String> studios = const [],
    this.isLive,
    List<String> soundTypes = const [],
    this.vinylColor = '',
    this.vinylWeight = '',
    this.rpm,
    this.extra = '',
    this.spars = '',
    this.boxSet = '',
  })  : genres = List<String>.of(genres),
        soundTypes = List<String>.of(soundTypes),
        studios = List<String>.of(studios);

  String artist;
  String sortTitle;
  String subtitle;
  List<String> genres;
  String coverImageUrl;
  String backCoverImageUrl;
  String thumbnailImageUrl;
  String format;
  String packaging;
  String catalogNumber;
  String barcode;
  String countryCode;
  DateTime? releaseDate;
  DateTime? originalReleaseDate;
  DateTime? recordingDate;
  String recordLabel;
  List<String> studios;
  bool? isLive;
  List<String> soundTypes;
  String vinylColor;
  String vinylWeight;
  int? rpm;
  String extra;
  String spars;
  String boxSet;

  @override
  void dispose() {}
}
