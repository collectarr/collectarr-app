import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_contents.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album_relations.dart';

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
    this.format = '',
    this.packaging = '',
    this.catalogNumber = '',
    this.barcode = '',
    this.countryCode = '',
    this.releaseDateParts,
    this.originalReleaseDateParts,
    this.recordingDateParts,
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
    List<MusicAddManualNamedCredit> composers = const [],
    List<MusicAddManualNamedCredit> conductors = const [],
    List<MusicAddManualNamedCredit> choruses = const [],
    List<MusicAddManualNamedCredit> compositions = const [],
    List<MusicAddManualNamedCredit> orchestras = const [],
    List<MusicAddManualNamedCredit> songwriters = const [],
    List<MusicAddManualNamedCredit> producers = const [],
    List<MusicAddManualNamedCredit> engineers = const [],
    List<MusicAddManualNamedCredit> musicians = const [],
    List<MusicArtistCredit> artistCredits = const [],
    List<MusicAddManualDisc> discs = const [],
    List<MusicAddManualExternalLink> externalLinks = const [],
  })  : genres = List<String>.of(genres),
        soundTypes = List<String>.of(soundTypes),
        studios = List<String>.of(studios),
        composers = List.of(composers),
        conductors = List.of(conductors),
        choruses = List.of(choruses),
        compositions = List.of(compositions),
        orchestras = List.of(orchestras),
        songwriters = List.of(songwriters),
        producers = List.of(producers),
        engineers = List.of(engineers),
        musicians = List.of(musicians),
        artistCredits = List.of(artistCredits),
        discs = List.of(discs),
        externalLinks = List.of(externalLinks);

  @override
  String catalogTitle = '';
  String artist;
  String sortTitle;
  String subtitle;
  List<String> genres;
  String coverImageUrl;
  String backCoverImageUrl;
  String format;
  String packaging;
  String catalogNumber;
  String barcode;
  String countryCode;
  PartialDate? releaseDateParts;
  PartialDate? originalReleaseDateParts;
  PartialDate? recordingDateParts;
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
  final List<MusicAddManualNamedCredit> composers;
  final List<MusicAddManualNamedCredit> conductors;
  final List<MusicAddManualNamedCredit> choruses;
  final List<MusicAddManualNamedCredit> compositions;
  final List<MusicAddManualNamedCredit> orchestras;
  final List<MusicAddManualNamedCredit> songwriters;
  final List<MusicAddManualNamedCredit> producers;
  final List<MusicAddManualNamedCredit> engineers;
  final List<MusicAddManualNamedCredit> musicians;
  List<MusicArtistCredit> artistCredits;
  final List<MusicAddManualDisc> discs;
  final List<MusicAddManualExternalLink> externalLinks;
}
