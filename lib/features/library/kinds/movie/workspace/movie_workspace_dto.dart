import 'package:collectarr_app/features/library/kinds/movie/catalog/movie_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

/// Read-only projection of one concrete Movie Catalog Item and its owned copy.
///
/// Edition facts live on [movie]. Contained discs remain children of that item
/// and do not create another workspace node.
final class MovieWorkspaceDto implements LibraryWorkspaceDto {
  const MovieWorkspaceDto({
    required this.common,
    required this.personal,
    required this.movie,
    this.metadata,
  });

  final WorkspaceCommonProjection common;
  final PersonalCopyProjection personal;
  final MovieCatalogItem movie;
  final MovieCatalogMetadata? metadata;

  String get title => common.title;
  String? get coverImageUrl => common.coverImageUrl;
  @override
  String get primaryLabel => title;
  @override
  String? get imageUrl => coverImageUrl;
  @override
  String? get secondaryLabel => null;

  String? get synopsis => common.synopsis;
  String? get currency => common.currency;

  String? get director =>
      metadata?.directors.firstOrNull?.name ?? movie.director;
  String? get writer => metadata?.writers.firstOrNull?.name ?? movie.writer;
  String? get producer =>
      metadata?.producers.firstOrNull?.name ?? movie.producer;
  String? get studio => movie.publisher;
  String? get publisher => movie.publisher;
  String? get seriesTitle => movie.seriesTitle;
  String? get itemNumber => movie.itemNumber;
  DateTime? get releaseDate => movie.releaseDate ?? common.releaseDate;
  String? get country => movie.country;
  String? get language => movie.language;
  String? get identifierCode => movie.barcode;
  String? get barcode => identifierCode;
  String? get variant => movie.variant;
  String? get format => movie.physicalFormat;
  String? get referenceFormatLabel => format;
  int? get runtimeMinutes => movie.runtimeMinutes;
  String? get originalTitle => movie.originalTitle;
  String? get ageRating => movie.ageRating;
  String? get audienceRating => movie.audienceRating;
  List<String> get genres => movie.genres;

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
