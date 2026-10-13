import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/kinds/movie/forms/movie_format_value.dart';

/// Flutter and domain independent values shared by Movie Add and catalog Edit.
final class MovieCatalogFormValues {
  MovieCatalogFormValues({
    this.title = '',
    this.displayTitle = '',
    this.sortTitle = '',
    this.originalTitle = '',
    this.localizedTitle = '',
    this.searchAliases = '',
    this.synopsis = '',
    this.genres = const [],
    this.originalLanguage = '',
    this.ageRating = '',
    this.audienceRating = '',
    this.runtimeMinutes,
    this.subtitle = '',
    this.audioTracks = const [],
    this.subtitles = const [],
    this.screenRatio = '',
    this.layers = '',
    this.color = '',
    this.nrDiscs,
    this.editionTitle = '',
    this.format = '',
    this.region = '',
    this.releaseDate,
    this.releaseMonth,
    this.releaseDay,
    this.distributor = '',
    this.language = '',
    this.coverImageUrl = '',
    this.barcode = '',
    this.itemNumber = '',
    this.variant = '',
    this.releaseYear,
    this.characters = const [],
  });

  factory MovieCatalogFormValues.fromMetadata(MovieCatalogMetadata metadata) =>
      MovieCatalogFormValues(
        title: metadata.title,
        displayTitle: metadata.displayTitle ?? '',
        sortTitle: metadata.sortTitle ?? '',
        originalTitle: metadata.originalTitle ?? '',
        localizedTitle: metadata.localizedTitle ?? '',
        searchAliases: metadata.searchAliases.join(', '),
        synopsis: metadata.synopsis ?? '',
        genres: List<String>.of(metadata.genres),
        originalLanguage: metadata.originalLanguage ?? '',
        ageRating: metadata.ageRating ?? '',
        audienceRating: metadata.audienceRating ?? '',
        runtimeMinutes: metadata.runtimeMinutes,
        subtitle: metadata.subtitle ?? '',
        audioTracks: _splitValues(metadata.audioTracks),
        subtitles: _splitValues(metadata.subtitles),
        screenRatio: metadata.screenRatio ?? '',
        layers: metadata.layers ?? '',
        color: metadata.color ?? '',
        nrDiscs: metadata.nrDiscs,
        editionTitle: metadata.editionTitle ?? '',
        format: moviePhysicalFormatLabel(metadata.physicalFormat),
        region: metadata.country ?? '',
        releaseDate: metadata.releaseDate,
        releaseMonth: metadata.releaseDateParts?.month,
        releaseDay: metadata.releaseDateParts?.day,
        distributor: metadata.publisher ?? metadata.studio ?? '',
        language: metadata.language ?? metadata.originalLanguage ?? '',
        coverImageUrl: metadata.coverImageUrl ?? '',
        barcode: metadata.barcode ?? '',
        itemNumber: metadata.itemNumber ?? '',
        variant: metadata.variant ?? '',
        releaseYear: metadata.releaseYear,
        characters: List<MovieCharacter>.of(metadata.characters),
      );

  String sortTitle;
  String title;
  String displayTitle;
  String originalTitle;
  String localizedTitle;
  String searchAliases;
  String synopsis;
  List<String> genres;
  String originalLanguage;
  String ageRating;
  String audienceRating;
  int? runtimeMinutes;
  String subtitle;
  List<String> audioTracks;
  List<String> subtitles;
  String screenRatio;
  String layers;
  String color;
  int? nrDiscs;

  String editionTitle;
  String format;
  String region;
  DateTime? releaseDate;
  int? releaseMonth;
  int? releaseDay;
  String distributor;
  String language;
  String coverImageUrl;
  String barcode;
  String itemNumber;
  String variant;
  int? releaseYear;
  List<MovieCharacter> characters;

  PartialDate? get releaseDateParts {
    final date = releaseDate;
    final year = releaseYear;
    if (date == null && (year == null || year < 1)) return null;
    if (date == null) {
      return PartialDate(year: year, month: releaseMonth, day: releaseDay);
    }
    return PartialDate(
      year: year != null && year > 0 ? year : date.year,
      month: date.month,
      day: date.day,
    );
  }
}

List<String> _splitValues(String? value) => value == null
    ? const []
    : value
        .split(RegExp(r'[,;\r\n]+'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
