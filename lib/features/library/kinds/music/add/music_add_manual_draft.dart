import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';

/// Editable values for one concrete Music catalog item.
///
/// Add stores album and pressing details on the same item. Disc and track data
/// remains contained by that item and is edited through its child editor.
final class MusicAddManualDraft implements LibraryKindAddDraft {
  MusicAddManualDraft({
    this.artist = '',
    List<String> genres = const [],
    this.coverImageUrl = '',
    this.format = '',
    this.packaging = '',
    this.catalogNumber = '',
    this.barcode = '',
    this.countryCode = '',
    this.releaseDate,
    this.recordLabel = '',
    this.studio = '',
    this.year,
  }) : genres = List<String>.of(genres);

  String artist;
  List<String> genres;
  String coverImageUrl;
  String format;
  String packaging;
  String catalogNumber;
  String barcode;
  String countryCode;
  DateTime? releaseDate;
  String recordLabel;
  String studio;
  int? year;

  @override
  void dispose() {}
}
