import 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class ComicWorkspaceDto extends WorkspaceDtoAdapter {
  ComicWorkspaceDto({
    required this.common,
    required this.personal,
    required this.comic,
    this.metadata,
  });

  @override
  final WorkspaceCommonProjection common;
  @override
  final PersonalCopyProjection personal;
  final ComicCatalogItem comic;
  final ComicCatalogMetadata? metadata;

  // Domain convenience getters
  String? get writer => metadata?.writers.firstOrNull;
  String? get artist => metadata?.artists.firstOrNull;
  String? get coverArtist => metadata?.coverArtists.firstOrNull;
  String? get imprint => metadata?.imprint ?? comic.publishing.imprint;
  @override
  String? get variant => metadata?.variant ?? comic.variant;
  int? get pageCount => metadata?.pageCount ?? comic.publishing.pageCount;
}
