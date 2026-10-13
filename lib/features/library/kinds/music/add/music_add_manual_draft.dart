import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_contents.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_artist_credit.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_album_form_values.dart';

/// Editable values for one Music catalog item and its contained discs.
final class MusicAddManualDraft implements LibraryKindAddDraft {
  MusicAddManualDraft({
    String catalogTitle = '',
    String artist = '',
    String sortTitle = '',
    String subtitle = '',
    List<String> genres = const [],
    String coverImageUrl = '',
    String backCoverImageUrl = '',
    String packaging = '',
    String catalogNumber = '',
    String barcode = '',
    String countryCode = '',
    PartialDate? releaseDateParts,
    PartialDate? originalReleaseDateParts,
    String recordLabel = '',
    List<String> extra = const [],
    String boxSet = '',
    List<MusicArtistCredit> artistCredits = const [],
    List<MusicAddManualCredit> credits = const [],
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
          packaging: packaging,
          catalogNumber: catalogNumber,
          barcode: barcode,
          countryCode: countryCode,
          releaseDateParts: releaseDateParts,
          originalReleaseDateParts: originalReleaseDateParts,
          publisher: recordLabel,
          extra: extra,
          boxSet: boxSet,
        ),
        credits = List.of(credits),
        discs = List.of(discs),
        externalLinks = List.of(externalLinks);

  final MusicAlbumFormValues values;
  final List<MusicAddManualCredit> credits;

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
  String get recordLabel => values.publisher;
  set recordLabel(String value) => values.publisher = value;
  List<String> get extra => values.extra;
  set extra(List<String> value) => values.extra = List.of(value);
  String get boxSet => values.boxSet;
  set boxSet(String value) => values.boxSet = value;

  List<MusicArtistCredit> get artistCredits => values.artistCredits;
  set artistCredits(List<MusicArtistCredit> value) =>
      values.artistCredits = List.of(value);
  final List<MusicAddManualDisc> discs;
  final List<MusicAddManualExternalLink> externalLinks;
}
