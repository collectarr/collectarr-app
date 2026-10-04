import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_contents.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album_relations.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_album_form_values.dart';

/// Editable values for one concrete Music catalog item.
///
/// Scalar catalog metadata is held by [values], which is also the Edit form's
/// typed model. Disc, track, credit, and link drafts remain kind-owned children.
final class MusicAddManualDraft implements LibraryKindAddDraft {
  MusicAddManualDraft({
    String catalogTitle = '',
    String artist = '',
    String sortTitle = '',
    String subtitle = '',
    List<String> genres = const [],
    String coverImageUrl = '',
    String backCoverImageUrl = '',
    String format = '',
    String packaging = '',
    String catalogNumber = '',
    String barcode = '',
    String countryCode = '',
    PartialDate? releaseDateParts,
    PartialDate? originalReleaseDateParts,
    PartialDate? recordingDateParts,
    String recordLabel = '',
    List<String> studios = const [],
    bool? isLive,
    List<String> soundTypes = const [],
    String vinylColor = '',
    String vinylWeight = '',
    int? rpm,
    String extra = '',
    String spars = '',
    String boxSet = '',
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
  })  : values = MusicAlbumFormValues(
          title: catalogTitle,
          artist: artist,
          sortTitle: sortTitle,
          subtitle: subtitle,
          artistCredits: artistCredits,
          genres: genres,
          coverImageUrl: coverImageUrl,
          backCoverImageUrl: backCoverImageUrl,
          format: format,
          packaging: packaging,
          catalogNumber: catalogNumber,
          barcode: barcode,
          countryCode: countryCode,
          releaseDateParts: releaseDateParts,
          originalReleaseDateParts: originalReleaseDateParts,
          recordingDateParts: recordingDateParts,
          publisher: recordLabel,
          studios: studios,
          isLive: isLive,
          soundTypes: soundTypes,
          vinylColor: vinylColor,
          vinylWeight: vinylWeight,
          rpm: rpm,
          extra: extra,
          spars: spars,
          boxSet: boxSet,
        ),
        composers = List.of(composers),
        conductors = List.of(conductors),
        choruses = List.of(choruses),
        compositions = List.of(compositions),
        orchestras = List.of(orchestras),
        songwriters = List.of(songwriters),
        producers = List.of(producers),
        engineers = List.of(engineers),
        musicians = List.of(musicians),
        discs = List.of(discs),
        externalLinks = List.of(externalLinks);

  final MusicAlbumFormValues values;

  @override
  String get catalogTitle => values.title;

  @override
  set catalogTitle(String value) => values.title = value;

  String get artist => values.artist;
  set artist(String value) => values.artist = value;

  String get sortTitle => values.sortTitle;
  set sortTitle(String value) => values.sortTitle = value;

  String get subtitle => values.subtitle;
  set subtitle(String value) => values.subtitle = value;

  List<String> get genres => values.genres;
  set genres(List<String> value) => values.genres = List.of(value);

  String get coverImageUrl => values.coverImageUrl;
  set coverImageUrl(String value) => values.coverImageUrl = value;

  String get backCoverImageUrl => values.backCoverImageUrl;
  set backCoverImageUrl(String value) => values.backCoverImageUrl = value;

  String get format => values.format;
  set format(String value) => values.format = value;

  String get packaging => values.packaging;
  set packaging(String value) => values.packaging = value;

  String get catalogNumber => values.catalogNumber;
  set catalogNumber(String value) => values.catalogNumber = value;

  String get barcode => values.barcode;
  set barcode(String value) => values.barcode = value;

  String get countryCode => values.countryCode;
  set countryCode(String value) => values.countryCode = value;

  PartialDate? get releaseDateParts => values.releaseDateParts;
  set releaseDateParts(PartialDate? value) => values.releaseDateParts = value;

  PartialDate? get originalReleaseDateParts => values.originalReleaseDateParts;
  set originalReleaseDateParts(PartialDate? value) =>
      values.originalReleaseDateParts = value;

  PartialDate? get recordingDateParts => values.recordingDateParts;
  set recordingDateParts(PartialDate? value) =>
      values.recordingDateParts = value;

  String get recordLabel => values.publisher;
  set recordLabel(String value) => values.publisher = value;

  List<String> get studios => values.studios;
  set studios(List<String> value) => values.studios = List.of(value);

  bool? get isLive => values.isLive;
  set isLive(bool? value) => values.isLive = value;

  List<String> get soundTypes => values.soundTypes;
  set soundTypes(List<String> value) => values.soundTypes = List.of(value);

  String get vinylColor => values.vinylColor;
  set vinylColor(String value) => values.vinylColor = value;

  String get vinylWeight => values.vinylWeight;
  set vinylWeight(String value) => values.vinylWeight = value;

  int? get rpm => values.rpm;
  set rpm(int? value) => values.rpm = value;

  String get extra => values.extra;
  set extra(String value) => values.extra = value;

  String get spars => values.spars;
  set spars(String value) => values.spars = value;

  String get boxSet => values.boxSet;
  set boxSet(String value) => values.boxSet = value;

  final List<MusicAddManualNamedCredit> composers;
  final List<MusicAddManualNamedCredit> conductors;
  final List<MusicAddManualNamedCredit> choruses;
  final List<MusicAddManualNamedCredit> compositions;
  final List<MusicAddManualNamedCredit> orchestras;
  final List<MusicAddManualNamedCredit> songwriters;
  final List<MusicAddManualNamedCredit> producers;
  final List<MusicAddManualNamedCredit> engineers;
  final List<MusicAddManualNamedCredit> musicians;
  List<MusicArtistCredit> get artistCredits => values.artistCredits;
  set artistCredits(List<MusicArtistCredit> value) =>
      values.artistCredits = List.of(value);
  final List<MusicAddManualDisc> discs;
  final List<MusicAddManualExternalLink> externalLinks;
}
