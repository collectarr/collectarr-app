import 'package:collectarr_app/features/library/kinds/_shared/video/catalog/video_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class MovieWorkspaceDto extends WorkspaceDtoAdapter {
  MovieWorkspaceDto({
    required this.common,
    required this.personal,
    required this.movie,
    this.metadata,
  });

  @override
  final WorkspaceCommonProjection common;
  @override
  final PersonalCopyProjection personal;
  final VideoCatalogItem movie;
  final MovieCatalogMetadata? metadata;

  VideoCatalogItem get video => movie;

  // Domain convenience getters
  String? get director => metadata?.directors.firstOrNull?.name;
  String? get writer => metadata?.writers.firstOrNull?.name;
  String? get producer => metadata?.producers.firstOrNull?.name;
  String? get studio => metadata?.studio;
  int? get runtimeMinutes =>
      metadata?.runtimeMinutes ?? movie.technical.runtimeMinutes;
  String? get originalTitle => metadata?.originalTitle;
  String? get ageRating => metadata?.ageRating ?? movie.technical.ageRating;
  String? get audienceRating =>
      metadata?.audienceRating ?? movie.technical.audienceRating;
}
