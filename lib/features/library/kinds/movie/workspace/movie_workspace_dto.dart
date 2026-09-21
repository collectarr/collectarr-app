import 'package:collectarr_app/features/library/kinds/movie/catalog/movie_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_media.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class MovieWorkspaceDto implements LibraryWorkspaceDto {
  MovieWorkspaceDto({
    required this.common,
    required this.personal,
    required this.movie,
    required this.media,
    this.release,
    this.metadata,
  });

  final WorkspaceCommonProjection common;
  final PersonalCopyProjection personal;
  final MovieCatalogItem movie;
  final MovieMedia media;
  final MovieCatalogRelease? release;
  final MovieCatalogMetadata? metadata;

  @override
  String get title => common.title;
  @override
  String? get coverImageUrl => common.coverImageUrl;

  String? get synopsis => common.synopsis;
  String? get currency => common.currency;

  MovieCatalogItem get video => movie;

  // Domain convenience getters
  String? get director =>
      metadata?.directors.firstOrNull?.name ?? _contributorWithRole('director');
  String? get writer =>
      metadata?.writers.firstOrNull?.name ?? _contributorWithRole('writer');
  String? get producer =>
      metadata?.producers.firstOrNull?.name ?? _contributorWithRole('producer');
  String? get studio => metadata?.studio;
  String? get publisher =>
      release?.publisher ?? (release == null ? studio : null);
  String? get seriesTitle =>
      metadata?.seriesTitle ?? metadata?.series?.seriesTitle;
  String? get itemNumber => metadata?.itemNumber;
  DateTime? get releaseDate =>
      release?.releaseDate ??
      (release == null
          ? metadata?.releaseDate ??
              movie.work.releaseDate ??
              common.releaseDate
          : null);
  String? get country => metadata?.country;
  String? get language => metadata?.language;
  String? get identifierCode => release?.barcode;
  String? get barcode => identifierCode;
  String? get variant => metadata?.variant;
  String? get referenceFormatLabel =>
      release?.formatLabel ??
      (release == null
          ? metadata?.physicalFormatLabel ?? metadata?.physicalFormat
          : null);
  String? get format => referenceFormatLabel;
  int? get runtimeMinutes =>
      release?.videoDetails?.runtimeMinutes ??
      (release == null
          ? media.runtimeMinutes ??
              metadata?.runtimeMinutes ??
              movie.technical.runtimeMinutes
          : null);
  String? get originalTitle => metadata?.originalTitle;
  String? get ageRating => metadata?.ageRating ?? movie.technical.ageRating;
  String? get audienceRating =>
      media.audienceRating ??
      metadata?.audienceRating ??
      movie.technical.audienceRating;
  List<String> get genres => _stringList(media.rawPayload['genres']);

  String? _contributorWithRole(String role) {
    final normalized = role.toLowerCase();
    for (final contributor in media.contributions) {
      if (contributor.role.toLowerCase() == normalized) return contributor.name;
    }
    return null;
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) return const <String>[];
    return [
      for (final entry in value)
        if (entry is String) entry
    ];
  }

  @override
  Iterable<String> get searchTokens => [
        if (publisher != null) publisher!,
        if (identifierCode != null) identifierCode!,
        if (director != null) director!,
        if (writer != null) writer!,
        if (studio != null) studio!,
        if (originalTitle != null) originalTitle!,
        ...genres,
      ];
}
