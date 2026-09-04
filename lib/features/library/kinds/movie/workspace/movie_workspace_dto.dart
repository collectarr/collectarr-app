import 'package:collectarr_app/features/library/kinds/_shared/video/catalog/video_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_media.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class MovieWorkspaceDto extends WorkspaceDtoAdapter {
  MovieWorkspaceDto({
    required this.common,
    required this.personal,
    required this.movie,
    required this.media,
    this.metadata,
  });

  @override
  final WorkspaceCommonProjection common;
  @override
  final PersonalCopyProjection personal;
  final VideoCatalogItem movie;
  final MovieMedia media;
  final MovieCatalogMetadata? metadata;

  VideoCatalogItem get video => movie;

  // Domain convenience getters
  String? get director =>
      metadata?.directors.firstOrNull?.name ?? _contributorWithRole('director');
  String? get writer =>
      metadata?.writers.firstOrNull?.name ?? _contributorWithRole('writer');
  String? get producer =>
      metadata?.producers.firstOrNull?.name ?? _contributorWithRole('producer');
  String? get studio => metadata?.studio;
  int? get runtimeMinutes =>
      media.runtimeMinutes ??
      metadata?.runtimeMinutes ??
      movie.technical.runtimeMinutes;
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
}
