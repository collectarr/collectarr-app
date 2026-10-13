import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_kind_data.dart';

final class MovieWorkspaceData implements LibraryWorkspaceKindData {
  MovieWorkspaceData({
    required this.metadata,
  });

  factory MovieWorkspaceData.fromTransport(CatalogItemDto item) {
    return MovieWorkspaceData(
      metadata: MovieCatalogMetadata.fromJson(item.kindData),
    );
  }

  final MovieCatalogMetadata metadata;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.movie;
  @override
  String get displayLabel => metadata.title;
}
